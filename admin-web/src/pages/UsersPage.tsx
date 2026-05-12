import { useUsers } from "../hooks/useUsers";

export function UsersPage() {
  const { users, loading } = useUsers();

  return (
    <div>
      <h1 style={{ margin: "0 0 24px", color: "#1b5e20" }}>
        Người dùng ({users.length})
      </h1>

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
                <th style={thStyle}>Số bữa ăn</th>
                <th style={thStyle}>Bữa ăn gần nhất</th>
              </tr>
            </thead>
            <tbody>
              {users.map((u) => (
                <tr key={u.userId} style={{ borderBottom: "1px solid #eee" }}>
                  <td style={tdStyle}>
                    <code style={{ fontSize: 11 }}>{u.userId}</code>
                  </td>
                  <td style={tdStyle}>{u.email}</td>
                  <td style={tdStyle}>{u.mealCount}</td>
                  <td style={tdStyle}>{u.lastMealDate ?? "-"}</td>
                </tr>
              ))}
              {users.length === 0 && (
                <tr>
                  <td colSpan={4} style={tdStyle}>
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
};
