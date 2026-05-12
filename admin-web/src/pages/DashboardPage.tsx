import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useUsers } from "../hooks/useUsers";

interface Stats {
  totalUsers: number;
  totalFoods: number;
  todayMeals: number;
  newUsersThisWeek: number;
}

export function DashboardPage() {
  const { getDashboardStats } = useUsers();
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    getDashboardStats()
      .then(setStats)
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return <p>Đang tải thống kê...</p>;
  }

  return (
    <div>
      <h1 style={{ margin: "0 0 24px", color: "#1b5e20" }}>Dashboard</h1>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
          gap: 16,
        }}
      >
        <StatCard
          title="Tổng người dùng"
          value={stats?.totalUsers ?? 0}
          color="#2E7D32"
          onClick={() => navigate("/users")}
        />
        <StatCard
          title="Tổng thực phẩm"
          value={stats?.totalFoods ?? 0}
          color="#1565c0"
          onClick={() => navigate("/foods")}
        />
        <StatCard
          title="Bữa ăn hôm nay"
          value={stats?.todayMeals ?? 0}
          color="#ef6c00"
        />
        <StatCard
          title="Người dùng mới (7 ngày)"
          value={stats?.newUsersThisWeek ?? 0}
          color="#6a1b9a"
        />
      </div>
    </div>
  );
}

function StatCard({
  title,
  value,
  color,
  onClick,
}: {
  title: string;
  value: number;
  color: string;
  onClick?: () => void;
}) {
  return (
    <div
      onClick={onClick}
      style={{
        backgroundColor: "#fff",
        borderRadius: 10,
        padding: "24px",
        boxShadow: "0 1px 6px rgba(0,0,0,0.08)",
        cursor: onClick ? "pointer" : "default",
        borderLeft: `4px solid ${color}`,
      }}
    >
      <p style={{ margin: "0 0 8px", color: "#666", fontSize: 13 }}>{title}</p>
      <p
        style={{
          margin: 0,
          fontSize: 32,
          fontWeight: 700,
          color,
        }}
      >
        {value}
      </p>
    </div>
  );
}
