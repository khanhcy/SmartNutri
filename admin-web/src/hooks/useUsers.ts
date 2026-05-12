import { useEffect, useState } from "react";
import {
  collection,
  getDocs,
  query,
  orderBy,
  limit,
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

    const items: UserStats[] = [];
    for (const u of userSnap.docs) {
      const mealsSnap = await getDocs(
        collection(db, "users", u.id, "meal_entries")
      );
      const meals = mealsSnap.docs.map((d) => d.data());
      const sorted = meals
        .filter((m) => m.createdAt)
        .sort(
          (a, b) =>
            (b.createdAt as Timestamp).toMillis() -
            (a.createdAt as Timestamp).toMillis()
        );

      items.push({
        userId: u.id,
        email: u.data().email ?? "",
        mealCount: meals.length,
        lastMealDate: sorted.length > 0
          ? (sorted[0].createdAt as Timestamp).toDate().toLocaleDateString("vi-VN")
          : undefined,
      });
    }

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

    const today = new Date().toISOString().slice(0, 10).replace(/-/g, "");
    let todayMeals = 0;
    for (const u of userSnap.docs) {
      const mSnap = await getDocs(
        collection(db, "users", u.id, "meal_entries")
      );
      todayMeals += mSnap.docs.filter((m) => {
        const createdAt = m.data().createdAt;
        if (!createdAt) return false;
        return (createdAt as Timestamp)
          .toDate()
          .toISOString()
          .startsWith(today);
      }).length;
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
