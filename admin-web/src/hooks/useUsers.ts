import { useEffect, useState } from "react";
import {
  collection,
  collectionGroup,
  getDocs,
  query,
  orderBy,
  where,
  Timestamp,
} from "firebase/firestore";
import { db } from "../firebase";

interface UserStats {
  userId: string;
  email: string;
  mealCount: number;
  lastMealDate?: string;
}

interface DashboardStats {
  totalUsers: number;
  totalFoods: number;
  todayMeals: number;
  newUsersThisWeek: number;
}

export function useUsers() {
  const [users, setUsers] = useState<UserStats[]>([]);
  const [loading, setLoading] = useState(true);

  const loadUsers = async () => {
    setLoading(true);
    const userSnap = await getDocs(
      query(collection(db, "users"), orderBy("email"))
    );

    // Sử dụng trường mealCount/lastMealDate đã được Cloud Function trigger
    // duy trì trên document users/{uid}, tránh N+1 query vào sub-collection.
    const items: UserStats[] = userSnap.docs.map((u) => {
      const data = u.data();
      return {
        userId: u.id,
        email: data.email ?? "",
        mealCount: data.mealCount ?? 0,
        lastMealDate: data.lastMealDate ?? undefined,
      };
    });

    setUsers(items);
    setLoading(false);
  };

  useEffect(() => {
    loadUsers();
  }, []);

  const getDashboardStats = async (): Promise<DashboardStats> => {
    const userSnap = await getDocs(collection(db, "users"));
    const foodSnap = await getDocs(collection(db, "foods"));

    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
    const newUsersSnap = await getDocs(
      query(
        collection(db, "users"),
        where("createdAt", ">=", Timestamp.fromDate(oneWeekAgo))
      )
    );

    // Collection group query thay vì N+1 sub-collection queries.
    // Cần index: collectionGroup=meal_entries, field=date (ASC).
    const dateStr = new Date().toISOString().slice(0, 10); // "2026-05-14"
    let todayMeals = 0;
    try {
      const todaySnap = await getDocs(
        query(
          collectionGroup(db, "meal_entries"),
          where("date", "==", dateStr)
        )
      );
      todayMeals = todaySnap.size;
    } catch (_) {
      // Fallback nếu collection group index chưa deploy
      todayMeals = 0;
    }

    return {
      totalUsers: userSnap.size,
      totalFoods: foodSnap.size,
      todayMeals,
      newUsersThisWeek: newUsersSnap.size,
    };
  };

  return { users, loading, loadUsers, getDashboardStats };
}
