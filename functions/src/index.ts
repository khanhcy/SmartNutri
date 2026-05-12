import * as admin from "firebase-admin";
import {onRequest, onCall} from "firebase-functions/v2/https";
import {GoogleGenerativeAI} from "@google/generative-ai";

admin.initializeApp();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");

// Helper: convert image base64 to a Gemini Part
function base64ToPart(base64: string, mimeType: string) {
  return {inlineData: {mimeType, data: base64}};
}

// ── Health check ──────────────────────────────────────────────────────────
export const health = onRequest((request, response) => {
  response.status(200).json({
    service: "smartnutri-functions",
    method: request.method,
    ok: true,
    timestamp: Date.now(),
  });
});

// ── Admin role management ─────────────────────────────────────────────────
// Called by existing admin to grant admin claims to another user.
// Bootstrap: first admin sets their own claim via Firebase Console
// (Authentication → Custom Claims → {"admin": true}).
export const setAdminRole = onCall(async (request) => {
  const callerUid = request.auth?.uid;
  if (!callerUid) {
    throw new Error("unauthenticated");
  }

  const caller = await admin.auth().getUser(callerUid);
  if (!caller.customClaims?.admin) {
    throw new Error("not_an_admin");
  }

  const targetUid = request.data?.targetUid as string | undefined;
  if (!targetUid) {
    throw new Error("missing_target_uid");
  }

  await admin.auth().setCustomUserClaims(targetUid, {admin: true});
  // Force token refresh so new claims take effect immediately
  await admin.auth().revokeRefreshTokens(targetUid);

  return {success: true, targetUid};
});

// ── Seed foods into Firestore ─────────────────────────────────────────────
// POST JSON body: { foods: [{id: "...", name: "...", ...}, ...] }
// Requires admin auth (caller must have admin custom claim).
export const seedFoods = onRequest(async (request, response) => {
  // Parse auth token from Authorization header
  const authHeader = request.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    response.status(401).json({error: "missing_token"});
    return;
  }

  try {
    const token = await admin.auth().verifyIdToken(authHeader.split(" ")[1]);
    if (!token.admin) {
      response.status(403).json({error: "not_an_admin"});
      return;
    }
  } catch {
    response.status(401).json({error: "invalid_token"});
    return;
  }

  const foods = request.body?.foods as any[] | undefined;
  if (!foods || !Array.isArray(foods) || foods.length === 0) {
    response.status(400).json({error: "missing_foods_array"});
    return;
  }

  const db = admin.firestore();
  let batch = db.batch();
  let count = 0;
  let total = 0;

  for (const food of foods) {
    const ref = db.collection("foods").doc(food.id);
    batch.set(ref, food);
    count++;
    total++;
    if (count >= 500) {
      await batch.commit();
      batch = db.batch();
      count = 0;
    }
  }
  if (count > 0) {
    await batch.commit();
  }

  response.status(200).json({ok: true, count: total});
});

// ── AI: Identify food from photo ──────────────────────────────────────────
export const identifyFoodImage = onCall(async (request) => {
  const imageBase64 = request.data?.imageBase64 as string | undefined;
  if (!imageBase64) throw new Error("missing_image");

  const model = genAI.getGenerativeModel({model: "gemini-2.0-flash"});

  const prompt = `Phân tích ảnh món ăn Việt Nam này. Trả về danh sách JSON array các món ăn có trong ảnh, mỗi món gồm:
- "name": tên món (tiếng Việt)
- "estimatedKcal": calo ước tính trên 100g (số nguyên)
- "confidence": độ tự tin 0-1

Chỉ trả về JSON array, không thêm text khác.
Ví dụ: [{"name":"Phở bò","estimatedKcal":200,"confidence":0.9}]`;

  const result = await model.generateContent([
    prompt,
    base64ToPart(imageBase64, "image/jpeg"),
  ]);

  const text = result.response.text();
  // Parse JSON from response (strip possible markdown fences)
  const jsonStr = text.replace(/```json|```/g, "").trim();
  const items = JSON.parse(jsonStr);

  return {items};
});

// ── AI: Suggest meals based on remaining macros ──────────────────────────
export const suggestMeals = onCall(async (request) => {
  const {remainingKcal, proteinG, carbG, fatG} = request.data as Record<string, number>;
  const recentFoodNames = (request.data?.recentFoodNames as string[]) ?? [];
  const mealTime = (request.data?.mealTime as string) ?? "bất kỳ";

  // Fetch all foods from Firestore to provide as context
  const foodsSnap = await admin.firestore().collection("foods").get();
  const foodList = foodsSnap.docs.map((d) => {
    const data = d.data();
    return {
      id: d.id,
      name: data.name,
      calorieKcal: data.calories ?? 0,
      proteinG: data.protein ?? 0,
      carbG: data.carbs ?? 0,
      fatG: data.fat ?? 0,
      category: data.category ?? "",
    };
  });

  if (foodList.length === 0) return {suggestions: []};

  const avoidSet = new Set(recentFoodNames.map((n) => n.toLowerCase()));
  const available = foodList.filter(
    (f) => !avoidSet.has(f.name.toLowerCase())
  );

  const model = genAI.getGenerativeModel({model: "gemini-2.0-flash"});

  const prompt = `Bạn là chuyên gia dinh dưỡng. Chọn 3-5 món từ danh sách thực phẩm bên dưới phù hợp nhất với:
- Calo còn lại: ${remainingKcal} kcal
- Protein còn: ${proteinG}g
- Carb còn: ${carbG}g
- Béo còn: ${fatG}g
- Bữa: ${mealTime}

Danh sách thực phẩm (JSON):
${JSON.stringify(available)}

Chỉ trả về JSON array, mỗi phần tử:
- "foodId": id của món
- "reason": lý do chọn (tiếng Việt, 1 câu ngắn)

Ví dụ: [{"foodId":"abc123","reason":"Giàu protein, phù hợp bữa sáng"}]
Chỉ trả JSON array, không thêm text khác.`;

  const result = await model.generateContent(prompt);
  const text = result.response.text();
  const jsonStr = text.replace(/```json|```/g, "").trim();
  const suggestions = JSON.parse(jsonStr);

  return {suggestions};
});

// ── Barcode lookup via OpenFoodFacts ──────────────────────────────────────
export const barcodeLookup = onCall(async (request) => {
  const barcode = request.data?.barcode as string | undefined;
  if (!barcode) throw new Error("missing_barcode");

  const url = `https://world.openfoodfacts.org/api/v2/product/${barcode}`;
  const res = await fetch(url, {
    headers: {"User-Agent": "SmartNutri/1.0"},
  });

  if (!res.ok) return {product: null};

  const json = (await res.json()) as any;
  if (json.status !== 1 || !json.product) return {product: null};

  const p = json.product;
  const nutriments = p.nutriments ?? {};

  return {
    product: {
      name: p.product_name ?? p.brands ?? "",
      brand: p.brands ?? "",
      calorieKcal: Math.round(nutriments["energy-kcal_100g"] ?? 0),
      proteinG: +(nutriments.proteins_100g ?? 0).toFixed(1),
      carbG: +(nutriments.carbohydrates_100g ?? 0).toFixed(1),
      fatG: +(nutriments.fat_100g ?? 0).toFixed(1),
      portionG: +(p.product_quantity ?? 100),
    },
  };
});
