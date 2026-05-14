import { useState } from "react";
import { useUsers } from "../hooks/useUsers";

export function UsersPage() {
  const { users, loading, setUserSubscription } = useUsers();
  const [updatingUserId, setUpdatingUserId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const updatePlan = async (userId: string, plan: "free" | "premium") => {
    setUpdatingUserId(userId);
    setError(null);
    try {
      await setUserSubscription(userId, plan);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Không thể cập nhật gói");
    } finally {
      setUpdatingUserId(null);
    }
  };

  return (
    <div>
      <h1 style={{ margin: "0 0 24px", color: "#1b5e20" }}>
        Người dùng ({users.length})
      </h1>

      {error && (
        <p style={{ color: "#b00020", marginTop: -8 }}>
          Lỗi cập nhật subscription: {error}
        </p>
      )}

      {loading ? (
        <p>Đang tải...</p>
      ) : (
        <div
          style={{
            backgroundColor: "#fff",
            borderRadius: 8,
            boxShadow: "0 1px 4px rgba(0,0,0,0.06)",
            overflow: "auto",
          }}
        >
          <table
            style={{
              width: "100%",
              borderCollapse: "collapse",
              fontSize: 13,
            }}
          >
            <thead>
              <tr style={{ backgroundColor: "#e8f5e9" }}>
                <th style={thStyle}>User ID</th>
                <th style={thStyle}>Email</th>
                <th style={thStyle}>Gói</th>
                <th style={thStyle}>AI scan</th>
                <th style={thStyle}>Số bữa ăn</th>
                <th style={thStyle}>Bữa ăn gần nhất</th>
                <th style={thStyle}>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {users.map((u) => {
                const isPremium = u.subscriptionPlan === "premium" && u.subscriptionStatus === "active";
                const isUpdating = updatingUserId === u.userId;
                return (
                  <tr key={u.userId} style={{ borderBottom: "1px solid #eee" }}>
                    <td style={tdStyle}>
                      <code style={{ fontSize: 11 }}>{u.userId}</code>
                    </td>
                    <td style={tdStyle}>{u.email}</td>
                    <td style={tdStyle}>
                      <strong style={{ color: isPremium ? "#1b5e20" : "#555" }}>
                        {isPremium ? "Premium" : "Free"}
                      </strong>
                      {u.premiumUntil && <div>Đến {u.premiumUntil}</div>}
                    </td>
                    <td style={tdStyle}>
                      {isPremium ? "Không giới hạn" : `${u.aiScanUsed}/${u.aiScanLimit}`}
                    </td>
                    <td style={tdStyle}>{u.mealCount}</td>
                    <td style={tdStyle}>{u.lastMealDate ?? "-"}</td>
                    <td style={tdStyle}>
                      {isPremium ? (
                        <button
                          style={buttonStyle}
                          disabled={isUpdating}
                          onClick={() => updatePlan(u.userId, "free")}
                        >
                          Set Free
                        </button>
                      ) : (
                        <button
                          style={buttonStyle}
                          disabled={isUpdating}
                          onClick={() => updatePlan(u.userId, "premium")}
                        >
                          Set Premium
                        </button>
                      )}
                    </td>
                  </tr>
                );
              })}
              {users.length === 0 && (
                <tr>
                  <td colSpan={7} style={tdStyle}>
                    Chưa có người dùng nào.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

const thStyle: React.CSSProperties = {
  padding: "12px",
  textAlign: "left",
  fontWeight: 600,
};

const tdStyle: React.CSSProperties = {
  padding: "10px 12px",
  verticalAlign: "top",
};

const buttonStyle: React.CSSProperties = {
  border: "1px solid #1b5e20",
  borderRadius: 6,
  background: "#fff",
  color: "#1b5e20",
  padding: "6px 10px",
  cursor: "pointer",
};
