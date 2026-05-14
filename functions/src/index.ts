import * as admin from "firebase-admin";
import {onRequest} from "firebase-functions/v2/https";
import {GoogleGenerativeAI} from "@google/generative-ai";

export {onMealEntryChanged} from "./meal_triggers.js";
export {chatNutrition} from "./chat.js";

admin.initializeApp();

function geminiModel() {
  const key = process.env.GEMINI_API_KEY;
  if (!key) throw new Error("Thiếu GEMINI_API_KEY trong .env");
  return new GoogleGenerativeAI(key)
    .getGenerativeModel({model: "gemini-2.5-flash"});
}

function base64ToPart(base64: string, mimeType: string) {
  return {inlineData: {mimeType, data: base64}};
}

function numberValue(value: unknown, fallback = 0): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string") {
    const parsed = Number(value.replace(/[^0-9.]/g, ""));
    if (Number.isFinite(parsed)) return parsed;
  }
  return fallback;
}

function parseServingSize(value: unknown): number | undefined {
  if (typeof value !== "string") return undefined;
  const parsed = Number(value.replace(/[^0-9.]/g, ""));
  return Number.isFinite(parsed) ? parsed : undefined;
}

function optionalString(value: unknown): string | undefined {
  if (typeof value !== "string") return undefined;
  const trimmed = value.trim();
  return trimmed ? trimmed : undefined;
}

function stringArray(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value.filter((v): v is string => typeof v === "string");
}

function normalizeFoodPayload(food: any) {
  const id = optionalString(food?.id);
  if (!id) throw new Error("missing_food_id");

  const normalized: Record<string, unknown> = {
    id,
    name: optionalString(food.name) ?? "",
    calorieKcal: numberValue(food.calorieKcal ?? food.calories),
    proteinG: numberValue(food.proteinG ?? food.protein),
    carbG: numberValue(food.carbG ?? food.carbs),
    fatG: numberValue(food.fatG ?? food.fat),
    category: optionalString(food.category) ?? "",
    defaultPortionG: numberValue(
      food.defaultPortionG ?? parseServingSize(food.servingSize),
      100
    ),
    tags: stringArray(food.tags),
    verified: typeof food.verified === "boolean" ? food.verified : false,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  const region = optionalString(food.region);
  const brand = optionalString(food.brand);
  const imageUrl = optionalString(food.imageUrl);
  if (region) normalized.region = region;
  if (brand) normalized.brand = brand;
  if (imageUrl) normalized.imageUrl = imageUrl;

  return normalized;
}

// ── Auth helper cho onRequest ───────────────────────────────────────────────
async function verifyAuth(request: any): Promise<string> {
  const authHeader = request.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    throw new Error("missing_token");
  }
  const token = await admin.auth().verifyIdToken(authHeader.split(" ")[1]);
  return token.uid;
}

function hasAdminAccess(user: admin.auth.UserRecord): boolean {
  return user.customClaims?.admin === true || user.email === "admin@smartnutri.com";
}

function usageMonthKey(date = new Date()): string {
  return `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}`;
}

function isPremiumActive(subscription: any): boolean {
  if (subscription?.plan !== "premium" || subscription?.status !== "active") return false;
  const premiumUntil = subscription?.premiumUntil;
  if (!premiumUntil) return true;
  const until = typeof premiumUntil.toDate === "function" ? premiumUntil.toDate() : new Date(premiumUntil);
  return until.getTime() > Date.now();
}

async function consumeAiScanQuota(uid: string): Promise<{allowed: boolean; used: number; limit: number; monthKey: string}> {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(uid);
  const monthKey = usageMonthKey();
  const limit = 5;

  return db.runTransaction(async (tx) => {
    const userSnap = await tx.get(userRef);
    const subscription = userSnap.data()?.subscription;
    if (isPremiumActive(subscription)) {
      return {allowed: true, used: 0, limit, monthKey};
    }

    const usageRef = userRef.collection("usage").doc(monthKey);
    const usageSnap = await tx.get(usageRef);
    const used = Number(usageSnap.data()?.aiScanUsed ?? 0);
    if (used >= limit) {
      return {allowed: false, used, limit, monthKey};
    }

    const nextUsed = used + 1;
    const usage = {
      monthKey,
      aiScanUsed: nextUsed,
      aiScanLimit: limit,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    tx.set(usageRef, usage, {merge: true});
    tx.set(userRef, {aiScanUsage: usage}, {merge: true});
    return {allowed: true, used: nextUsed, limit, monthKey};
  });
}

// ── Health check ────────────────────────────────────────────────────────────
export const health = onRequest((request, response) => {
  response.status(200).json({
    service: "smartnutri-functions",
    ok: true,
    timestamp: Date.now(),
  });
});

// ── Admin: set role ─────────────────────────────────────────────────────────
export const setAdminRole = onRequest(async (request, response) => {
  try {
    const callerUid = await verifyAuth(request);
    const caller = await admin.auth().getUser(callerUid);
    if (!hasAdminAccess(caller)) {
      response.status(403).json({error: "not_an_admin"});
      return;
    }
    const targetUid = request.body?.targetUid as string | undefined;
    if (!targetUid) {
      response.status(400).json({error: "missing_target_uid"});
      return;
    }
    await admin.auth().setCustomUserClaims(targetUid, {admin: true});
    await admin.auth().revokeRefreshTokens(targetUid);
    response.status(200).json({success: true, targetUid});
  } catch (e: any) {
    response.status(401).json({error: e.message});
  }
});

// ── Admin: set subscription ─────────────────────────────────────────────────
export const setUserSubscription = onRequest(async (request, response) => {
  try {
    const callerUid = await verifyAuth(request);
    const caller = await admin.auth().getUser(callerUid);
    if (!hasAdminAccess(caller)) {
      response.status(403).json({error: "not_an_admin"});
      return;
    }

    const targetUid = request.body?.targetUid as string | undefined;
    const plan = request.body?.plan as string | undefined;
    if (!targetUid || (plan !== "free" && plan !== "premium")) {
      response.status(400).json({error: "invalid_subscription_request"});
      return;
    }

    const premiumUntilInput = request.body?.premiumUntil as string | undefined;
    const subscription: Record<string, unknown> = {
      plan,
      status: plan === "premium" ? "active" : "none",
      source: "admin",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (plan === "premium" && premiumUntilInput) {
      subscription.premiumUntil = admin.firestore.Timestamp.fromDate(new Date(premiumUntilInput));
    }

    await admin.firestore().collection("users").doc(targetUid).set(
      {subscription},
      {merge: true}
    );

    response.status(200).json({ok: true, targetUid, subscription});
  } catch (e: any) {
    response.status(401).json({error: e.message});
  }
});

// ── Seed foods ──────────────────────────────────────────────────────────────
export const seedFoods = onRequest(async (request, response) => {
  try {
    const callerUid = await verifyAuth(request);
    const caller = await admin.auth().getUser(callerUid);
    if (!hasAdminAccess(caller)) {
      response.status(403).json({error: "not_an_admin"});
      return;
    }
  } catch (e: any) {
    response.status(401).json({error: e.message});
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
    let normalized: Record<string, unknown>;
    try {
      normalized = normalizeFoodPayload(food);
    } catch (e: any) {
      response.status(400).json({error: e.message ?? "invalid_food"});
      return;
    }

    const ref = db.collection("foods").doc(normalized.id as string);
    batch.set(ref, normalized, {merge: true});
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

// ── AI: Identify food from photo ────────────────────────────────────────────
export const identifyFoodImage = onRequest(async (request, response) => {
  try {
    let uid: string;
    try {
      uid = await verifyAuth(request);
    } catch (e: any) {
      response.status(401).json({error: e.message});
      return;
    }

    const imageBase64 = request.body?.imageBase64 as string | undefined;
    if (!imageBase64) {
      response.status(400).json({error: "missing_image"});
      return;
    }

    const knownFoodNames = (request.body?.knownFoodNames as string[]) ?? [];

    console.log("📷 identifyFoodImage — image:", imageBase64.length, "chars, known foods:", knownFoodNames.length);

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      console.error("❌ GEMINI_API_KEY not set");
      response.status(500).json({error: "missing_api_key"});
      return;
    }

    const quota = await consumeAiScanQuota(uid);
    if (!quota.allowed) {
      response.status(403).json({error: "quota_exceeded", quota});
      return;
    }

    const model = geminiModel();

    const foodListSection = knownFoodNames.length > 0
      ? `\nDanh sách món ăn có trong cơ sở dữ liệu (ưu tiên khớp tên với danh sách này):\n${knownFoodNames.map((n, i) => `${i + 1}. ${n}`).join("\n")}\n`
      : "";

    const prompt = `Bạn là chuyên gia ẩm thực Việt Nam. Phân tích kỹ ảnh món ăn này và xác định chính xác từng món.

${foodListSection}
Quan sát kỹ các đặc điểm sau để nhận diện:
- Màu sắc, hình dạng, thành phần chính (thịt, cá, rau, bún, cơm, nước dùng...)
- Cách trình bày (tô lớn có nước dùng = phở/bún/hủ tiếu; đĩa cơm với sườn/bì/chả = cơm tấm; cuốn trong bánh tráng = gỏi cuốn/chả giò...)
- Các món ăn kèm (rau sống, nước chấm, đồ chua...)

Trả về JSON array các món có trong ảnh. Mỗi món gồm:
- "name": tên món chính xác (tiếng Việt có dấu). Nếu món có trong danh sách database, dùng ĐÚNG tên từ danh sách
- "estimatedKcal": calo ước tính trên 100g (số nguyên)
- "estimatedProteinG": protein trên 100g (số thực, 1 chữ số thập phân)
- "estimatedCarbG": carb trên 100g (số thực, 1 chữ số thập phân)
- "estimatedFatG": chất béo trên 100g (số thực, 1 chữ số thập phân)
- "estimatedPortionG": khối lượng phần ăn trong ảnh (gram, số nguyên)
- "confidence": độ tự tin 0.0-1.0 (chỉ đưa ra nếu >0.5)

QUAN TRỌNG:
- Nếu không tự tin (confidence <0.5), không trả về món đó
- Nếu có danh sách database, ưu tiên khớp với tên trong đó
- Chỉ trả về JSON array hợp lệ, không thêm text hay markdown

Ví dụ output:
[{"name":"Cơm tấm sườn","estimatedKcal":220,"estimatedProteinG":12.5,"estimatedCarbG":30.0,"estimatedFatG":8.0,"estimatedPortionG":400,"confidence":0.92}]`;

    const result = await model.generateContent([
      prompt,
      base64ToPart(imageBase64, "image/jpeg"),
    ]);

    const text = result.response.text();
    console.log("   Gemini raw:", text.substring(0, 300));

    // Extract JSON: find first '[' and last ']'
    const start = text.indexOf('[');
    const end = text.lastIndexOf(']');
    if (start === -1 || end === -1 || start >= end) {
      console.error("❌ No JSON array found in Gemini response");
      response.status(500).json({error: "ai_response_no_json"});
      return;
    }
    const jsonStr = text.substring(start, end + 1);
    const items = JSON.parse(jsonStr);
    console.log("✅ parsed", items.length, "items");

    response.status(200).json({items});
  } catch (e: any) {
    console.error("❌ identifyFoodImage:", e.message ?? e);
    response.status(500).json({error: "ai_processing_failed"});
  }
});

// ── AI: Suggest meals ───────────────────────────────────────────────────────
export const suggestMeals = onRequest(async (request, response) => {
  try {
    try { await verifyAuth(request); } catch { /* optional in emulator */ }

    const body = request.body ?? {};
    const remainingKcal = body.remainingKcal as number;
    const proteinG = body.proteinG as number;
    const carbG = body.carbG as number;
    const fatG = body.fatG as number;
    const recentFoodNames = (body.recentFoodNames as string[]) ?? [];
    const mealTime = (body.mealTime as string) ?? "bất kỳ";

    if (remainingKcal === undefined) {
      response.status(400).json({error: "missing_macros"});
      return;
    }

    // Fetch foods from Firestore, fallback to foodCatalog from request
    const foodsSnap = await admin.firestore().collection("foods").get();
    let foodList = foodsSnap.docs.map((d) => {
      const data = d.data();
      return {
        id: d.id,
        name: data.name,
        calorieKcal: data.calorieKcal ?? data.calories ?? 0,
        proteinG: data.proteinG ?? data.protein ?? 0,
        carbG: data.carbG ?? data.carbs ?? 0,
        fatG: data.fatG ?? data.fat ?? 0,
        category: data.category ?? "",
      };
    });

    // Fallback: use food catalog from Flutter if Firestore is empty
    if (foodList.length === 0 && Array.isArray(body.foodCatalog)) {
      foodList = body.foodCatalog as any[];
    }

    if (foodList.length === 0) {
      response.status(200).json({suggestions: []});
      return;
    }

    const avoidSet = new Set(recentFoodNames.map((n: string) => n.toLowerCase()));
    const available = foodList.filter(
      (f) => !avoidSet.has(f.name.toLowerCase())
    );

    const model = geminiModel();

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
    console.log("   Gemini raw:", text.substring(0, 200));

    // Extract JSON: find first '[' and last ']'
    const start = text.indexOf('[');
    const end = text.lastIndexOf(']');
    if (start === -1 || end === -1 || start >= end) {
      console.error("❌ No JSON array found in Gemini response");
      response.status(500).json({error: "ai_response_no_json"});
      return;
    }
    const jsonStr = text.substring(start, end + 1);
    const suggestions = JSON.parse(jsonStr);

    response.status(200).json({suggestions});
  } catch (e: any) {
    console.error("❌ suggestMeals:", e.message ?? e);
    response.status(500).json({error: "ai_processing_failed"});
  }
});

// ── Barcode lookup ──────────────────────────────────────────────────────────
export const barcodeLookup = onRequest(async (request, response) => {
  try {
    const barcode = request.body?.barcode as string | undefined;
    if (!barcode) {
      response.status(400).json({error: "missing_barcode"});
      return;
    }

    const url = `https://world.openfoodfacts.org/api/v2/product/${barcode}`;
    const res = await fetch(url, {
      headers: {"User-Agent": "SmartNutri/1.0"},
    });

    if (!res.ok) {
      response.status(200).json({product: null});
      return;
    }

    const json = (await res.json()) as any;
    if (json.status !== 1 || !json.product) {
      response.status(200).json({product: null});
      return;
    }

    const p = json.product;
    const nutriments = p.nutriments ?? {};

    response.status(200).json({
      product: {
        name: p.product_name ?? p.brands ?? "",
        brand: p.brands ?? "",
        calorieKcal: Math.round(nutriments["energy-kcal_100g"] ?? 0),
        proteinG: +(nutriments.proteins_100g ?? 0).toFixed(1),
        carbG: +(nutriments.carbohydrates_100g ?? 0).toFixed(1),
        fatG: +(nutriments.fat_100g ?? 0).toFixed(1),
        portionG: +(p.product_quantity ?? 100),
      },
    });
  } catch (e: any) {
    console.error("❌ barcodeLookup:", e.message ?? e);
    response.status(500).json({error: e.message ?? "internal_error"});
  }
});
