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
import { auth, db } from "../firebase";

type SubscriptionPlan = "free" | "premium";

interface UserStats {
  userId: string;
  email: string;
  mealCount: number;
  lastMealDate?: string;
  subscriptionPlan: SubscriptionPlan;
  subscriptionStatus: string;
  premiumUntil?: string;
  aiScanUsed: number;
  aiScanLimit: number;
}

interface DashboardStats {
  totalUsers: number;
  totalFoods: number;
  todayMeals: number;
  newUsersThisWeek: number;
}

function functionBaseUrl() {
  return import.meta.env.DEV
    ? "http://127.0.0.1:5001/smartnutri-dev-2e67b/us-central1"
    : "https://us-central1-smartnutri-dev-2e67b.cloudfunctions.net";
}

function formatPremiumUntil(value: unknown): string | undefined {
  if (!value) return undefined;
  if (value instanceof Timestamp) return value.toDate().toISOString().slice(0, 10);
  if (typeof value === "string") return value.slice(0, 10);
  return undefined;
}

export function useUsers() {
  const [users, setUsers] = useState<UserStats[]>([]);
  const [loading, setLoading] = useState(true);

  const loadUsers = async () => {
    setLoading(true);
    const userSnap = await getDocs(
      query(collection(db, "users"), orderBy("email"))
    );

    const items: UserStats[] = userSnap.docs.map((u) => {
      const data = u.data();
      const subscription = data.subscription ?? {};
      const usage = data.aiScanUsage ?? {};
      return {
        userId: u.id,
        email: data.email ?? "",
        mealCount: data.mealCount ?? 0,
        lastMealDate: data.lastMealDate ?? undefined,
        subscriptionPlan: subscription.plan === "premium" ? "premium" : "free",
        subscriptionStatus: subscription.status ?? "none",
        premiumUntil: formatPremiumUntil(subscription.premiumUntil),
        aiScanUsed: usage.aiScanUsed ?? 0,
        aiScanLimit: usage.aiScanLimit ?? 5,
      };
    });

    setUsers(items);
    setLoading(false);
  };

  useEffect(() => {
    loadUsers();
  }, []);

  const setUserSubscription = async (targetUid: string, plan: SubscriptionPlan) => {
    const token = await auth.currentUser?.getIdToken();
    if (!token) throw new Error("missing_token");

    const response = await fetch(`${functionBaseUrl()}/setUserSubscription`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ targetUid, plan }),
    });

    if (!response.ok) {
      const body = await response.json().catch(() => ({}));
      throw new Error(body.error ?? "set_subscription_failed");
    }

    await loadUsers();
  };

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

    const dateStr = new Date().toISOString().slice(0, 10);
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
      todayMeals = 0;
    }

    return {
      totalUsers: userSnap.size,
      totalFoods: foodSnap.size,
      todayMeals,
      newUsersThisWeek: newUsersSnap.size,
    };
  };

  return { users, loading, loadUsers, setUserSubscription, getDashboardStats };
}
