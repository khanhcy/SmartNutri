import { useEffect, useState } from "react";
import {
  collection,
  updateDoc,
  deleteDoc,
  doc,
  getDocs,
  query,
  orderBy,
  Timestamp,
  deleteField,
  setDoc,
} from "firebase/firestore";
import { db } from "../firebase";

export interface FoodItem {
  id: string;
  name: string;
  category: string;
  calorieKcal: number;
  proteinG: number;
  carbG: number;
  fatG: number;
  defaultPortionG: number;
  region?: string;
  brand?: string;
  tags?: string[];
  imageUrl?: string;
  verified?: boolean;
}

export type FoodFormData = Omit<FoodItem, "id">;

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

function foodFromDoc(id: string, data: Record<string, unknown>): FoodItem {
  return {
    id,
    name: typeof data.name === "string" ? data.name : "",
    category: typeof data.category === "string" ? data.category : "",
    calorieKcal: numberValue(data.calorieKcal ?? data.calories),
    proteinG: numberValue(data.proteinG ?? data.protein),
    carbG: numberValue(data.carbG ?? data.carbs),
    fatG: numberValue(data.fatG ?? data.fat),
    defaultPortionG: numberValue(
      data.defaultPortionG ?? parseServingSize(data.servingSize),
      100
    ),
    region: typeof data.region === "string" ? data.region : undefined,
    brand: typeof data.brand === "string" ? data.brand : undefined,
    tags: Array.isArray(data.tags)
      ? data.tags.filter((tag): tag is string => typeof tag === "string")
      : undefined,
    imageUrl: typeof data.imageUrl === "string" ? data.imageUrl : undefined,
    verified: typeof data.verified === "boolean" ? data.verified : false,
  };
}

function toFirestoreFood(data: Partial<FoodFormData>) {
  return {
    name: data.name ?? "",
    category: data.category ?? "",
    calorieKcal: numberValue(data.calorieKcal),
    proteinG: numberValue(data.proteinG),
    carbG: numberValue(data.carbG),
    fatG: numberValue(data.fatG),
    defaultPortionG: numberValue(data.defaultPortionG, 100),
    region: data.region || undefined,
    brand: data.brand || undefined,
    tags: data.tags ?? [],
    imageUrl: data.imageUrl || undefined,
    verified: data.verified ?? false,
  };
}

const legacyDeletes = {
  calories: deleteField(),
  protein: deleteField(),
  carbs: deleteField(),
  fat: deleteField(),
  fiber: deleteField(),
  servingSize: deleteField(),
};

export function useFoods() {
  const [foods, setFoods] = useState<FoodItem[]>([]);
  const [loading, setLoading] = useState(true);

  const loadFoods = async () => {
    setLoading(true);
    const q = query(collection(db, "foods"), orderBy("name"));
    const snap = await getDocs(q);
    const items = snap.docs.map((d) => foodFromDoc(d.id, d.data()));
    setFoods(items);
    setLoading(false);
  };

  useEffect(() => {
    loadFoods();
  }, []);

  const addFood = async (data: FoodFormData) => {
    const ref = doc(collection(db, "foods"));
    await setDoc(ref, {
      ...toFirestoreFood(data),
      id: ref.id,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    });
    await loadFoods();
  };

  const updateFood = async (id: string, data: Partial<FoodFormData>) => {
    await updateDoc(doc(db, "foods", id), {
      ...toFirestoreFood(data),
      ...legacyDeletes,
      id,
      updatedAt: Timestamp.now(),
    });
    await loadFoods();
  };

  const deleteFood = async (id: string) => {
    await deleteDoc(doc(db, "foods", id));
    await loadFoods();
  };

  const importFoods = async (items: FoodFormData[]) => {
    const col = collection(db, "foods");
    for (let i = 0; i < items.length; i += 500) {
      const batch = items.slice(i, i + 500);
      await Promise.all(
        batch.map((item) => {
          const ref = doc(col);
          return setDoc(ref, {
            ...toFirestoreFood(item),
            id: ref.id,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
          });
        })
      );
    }
    await loadFoods();
  };

  return { foods, loading, loadFoods, addFood, updateFood, deleteFood, importFoods };
}
