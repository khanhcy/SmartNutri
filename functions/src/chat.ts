import * as admin from "firebase-admin";
import {onRequest} from "firebase-functions/v2/https";
import {GoogleGenerativeAI} from "@google/generative-ai";

interface ChatContextInput {
  displayName?: string;
  age?: number;
  heightCm?: number;
  weightKg?: number;
  gender?: string;
  activityLevel?: string;
  calorieTarget?: number;
  proteinG?: number;
  carbG?: number;
  fatG?: number;
  todayConsumedKcal?: number;
  todayMeals?: string[];
}

interface ConversationTurn {
  role: "user" | "assistant";
  content: string;
}

function buildSystemPrompt(ctx: ChatContextInput): string {
  const name = ctx.displayName ? `- Tên: ${ctx.displayName}` : "";
  const age = ctx.age ? `- Tuổi: ${ctx.age}` : "";
  const height = ctx.heightCm ? `- Chiều cao: ${ctx.heightCm} cm` : "";
  const weight = ctx.weightKg ? `- Cân nặng: ${ctx.weightKg} kg` : "";
  const gender = ctx.gender
    ? `- Giới tính: ${ctx.gender === "male" ? "Nam" : ctx.gender === "female" ? "Nữ" : ctx.gender}`
    : "";
  const activity = ctx.activityLevel
    ? `- Mức độ vận động: ${ctx.activityLevel}`
    : "";

  const goals: string[] = [];
  if (ctx.calorieTarget) goals.push(`Calo mục tiêu: ${ctx.calorieTarget} kcal`);
  if (ctx.proteinG) goals.push(`Protein: ${ctx.proteinG}g`);
  if (ctx.carbG) goals.push(`Carb: ${ctx.carbG}g`);
  if (ctx.fatG) goals.push(`Fat: ${ctx.fatG}g`);

  const consumed = ctx.todayConsumedKcal !== undefined
    ? `- Đã nạp hôm nay: ${ctx.todayConsumedKcal} kcal`
    : "";
  const remaining = ctx.calorieTarget && ctx.todayConsumedKcal !== undefined
    ? `- Còn lại: ${Math.max(0, ctx.calorieTarget - ctx.todayConsumedKcal)} kcal`
    : "";
  const meals = ctx.todayMeals && ctx.todayMeals.length > 0
    ? `- Đã ăn hôm nay: ${ctx.todayMeals.join(", ")}`
    : "- Chưa ghi nhận bữa ăn nào hôm nay";

  const profileSection = [name, age, height, weight, gender, activity]
    .filter(Boolean)
    .join("\n");

  const goalSection = goals.length > 0
    ? `Mục tiêu dinh dưỡng:\n${goals.map((g) => `- ${g}`).join("\n")}`
    : "";

  const todaySection = [consumed, remaining, meals].filter(Boolean).join("\n");

  const contextBlock = [
    profileSection && `Thông tin người dùng:\n${profileSection}`,
    goalSection,
    todaySection && `Tình trạng hôm nay:\n${todaySection}`,
  ].filter(Boolean).join("\n\n");

  return `Bạn là SmartNutri AI — trợ lý dinh dưỡng thông minh và thân thiện cho người Việt Nam.

Nguyên tắc trả lời:
- Luôn dùng tiếng Việt, ngôn ngữ thân thiện, gần gũi như người bạn quan tâm đến sức khỏe.
- Tư vấn dựa trên thông tin profile và dữ liệu thực tế của người dùng (nếu có).
- Khi hỏi về thực phẩm: cung cấp calo, protein, carb, fat trên 100g một cách rõ ràng.
- Khi gợi ý bữa ăn: ưu tiên món Việt Nam, phù hợp macro còn lại.
- Câu trả lời ngắn gọn, súc tích (tối đa 150 từ), dùng emoji hợp lý để sinh động.
- Không đưa lời khuyên y tế chuyên sâu — nếu cần, hướng dẫn gặp chuyên gia.
- Không bịa đặt số liệu — nếu không chắc, hãy nói rõ đây là ước tính.

${contextBlock || "Chưa có thông tin profile của người dùng."}`;
}

function geminiChatModel() {
  const key = process.env.GEMINI_API_KEY;
  if (!key) throw new Error("Thiếu GEMINI_API_KEY");
  return new GoogleGenerativeAI(key).getGenerativeModel({
    model: "gemini-2.5-flash",
  });
}

async function verifyAuthOptional(request: any): Promise<string | null> {
  try {
    const authHeader = request.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) return null;
    const token = await admin.auth().verifyIdToken(authHeader.split(" ")[1]);
    return token.uid;
  } catch {
    return null;
  }
}

export const chatNutrition = onRequest(async (request, response) => {
  response.set("Access-Control-Allow-Origin", "*");
  if (request.method === "OPTIONS") {
    response.set("Access-Control-Allow-Methods", "POST");
    response.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    response.status(204).send("");
    return;
  }

  try {
    const uid = await verifyAuthOptional(request);

    const body = request.body ?? {};
    const message = body.message as string | undefined;
    if (!message || !message.trim()) {
      response.status(400).json({error: "missing_message"});
      return;
    }

    const history = (body.conversationHistory as ConversationTurn[]) ?? [];
    const ctx = (body.context as ChatContextInput) ?? {};

    const systemPrompt = buildSystemPrompt(ctx);
    const model = geminiChatModel();

    // Build Gemini chat history from conversation turns
    const geminiHistory = history.slice(-10).map((turn) => ({
      role: turn.role === "user" ? "user" : "model",
      parts: [{text: turn.content}],
    }));

    const chat = model.startChat({
      history: [
        {role: "user", parts: [{text: systemPrompt}]},
        {
          role: "model",
          parts: [{
            text: "Xin chào! Tôi là SmartNutri AI 🥗 Tôi sẽ giúp bạn tư vấn dinh dưỡng cá nhân hóa. Bạn cần hỏi gì?",
          }],
        },
        ...geminiHistory,
      ],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 512,
      },
    });

    const result = await chat.sendMessage(message.trim());
    const reply = result.response.text().trim();

    // Generate suggestion questions from Gemini
    const suggestResult = await model.generateContent(
      `Dựa vào câu trả lời sau, tạo ra ĐÚNG 3 câu hỏi tiếp theo ngắn gọn (tối đa 8 từ mỗi câu) mà người dùng có thể muốn hỏi thêm về dinh dưỡng. Chỉ trả về JSON array 3 string, không thêm gì khác.

Câu trả lời: "${reply}"

Ví dụ output: ["Phở bò bao nhiêu calo?", "Cách giảm calo hiệu quả?", "Protein từ nguồn nào?"]`
    );
    let suggestions: string[] = [];
    try {
      const suggestText = suggestResult.response.text().trim();
      const start = suggestText.indexOf("[");
      const end = suggestText.lastIndexOf("]");
      if (start !== -1 && end !== -1) {
        suggestions = JSON.parse(suggestText.substring(start, end + 1));
      }
    } catch {
      suggestions = [];
    }

    // Save to Firestore if authenticated
    if (uid) {
      try {
        const db = admin.firestore();
        const chatRef = db.collection("users").doc(uid)
          .collection("chat_history");
        const batch = db.batch();

        // Save user message
        batch.set(chatRef.doc(), {
          role: "user",
          content: message.trim(),
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Save assistant reply
        batch.set(chatRef.doc(), {
          role: "assistant",
          content: reply,
          suggestions,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

        await batch.commit();
      } catch (saveErr) {
        console.warn("⚠️ Không thể lưu chat vào Firestore:", saveErr);
      }
    }

    response.status(200).json({reply, suggestions});
  } catch (e: any) {
    console.error("❌ chatNutrition error:", e.message ?? e);
    response.status(500).json({error: "chat_failed"});
  }
});
