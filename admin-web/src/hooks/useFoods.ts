import { useEffect, useState } from "react";
import {
  collection,
  addDoc,
  updateDoc,
  deleteDoc,
  doc,
  getDocs,
  query,
  orderBy,
  Timestamp,
} from "firebase/firestore";
import { db } from "../firebase";

export interface FoodItem {
  id: string;
  name: string;
  category: string;
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  fiber: number;
  servingSize: string;
  region?: string;
  brand?: string;
  tags?: string[];
  imageUrl?: string;
  verified?: boolean;
}

export type FoodFormData = Omit<FoodItem, "id">;

export function useFoods() {
  const [foods, setFoods] = useState<FoodItem[]>([]);
  const [loading, setLoading] = useState(true);

  const loadFoods = async () => {
    setLoading(true);
    const q = query(collection(db, "foods"), orderBy("name"));
    const snap = await getDocs(q);
    const items: FoodItem[] = snap.docs.map((d) => {
      const data = d.data();
      return {
        id: d.id,
        name: data.name ?? "",
        category: data.category ?? "",
        calories: data.calories ?? 0,
        protein: data.protein ?? 0,
        carbs: data.carbs ?? 0,
        fat: data.fat ?? 0,
        fiber: data.fiber ?? 0,
        servingSize: data.servingSize ?? "",
        region: data.region ?? undefined,
        brand: data.brand ?? undefined,
        tags: data.tags ?? undefined,
        imageUrl: data.imageUrl ?? undefined,
        verified: data.verified ?? false,
      };
    });
    setFoods(items);
    setLoading(false);
  };

  useEffect(() => {
    loadFoods();
  }, []);

  const addFood = async (data: FoodFormData) => {
    await addDoc(collection(db, "foods"), {
      ...data,
      createdAt: Timestamp.now(),
    });
    await loadFoods();
  };

  const updateFood = async (id: string, data: Partial<FoodFormData>) => {
    await updateDoc(doc(db, "foods", id), data);
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
        batch.map((item) =>
          addDoc(col, { ...item, createdAt: Timestamp.now() })
        )
      );
    }
    await loadFoods();
  };

  return { foods, loading, loadFoods, addFood, updateFood, deleteFood, importFoods };
}
