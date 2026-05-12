import { Outlet, NavLink, useNavigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";

export function Layout() {
  const { user, isAdmin, logOut } = useAuth();
  const navigate = useNavigate();

  const handleLogOut = async () => {
    await logOut();
    navigate("/login");
  };

  const linkStyle = (isActive: boolean): React.CSSProperties => ({
    display: "block",
    padding: "8px 16px",
    color: isActive ? "#fff" : "#b3d9b3",
    backgroundColor: isActive ? "#2E7D32" : "transparent",
    textDecoration: "none",
    borderRadius: 6,
    fontSize: 14,
    fontWeight: isActive ? 600 : 400,
  });

  return (
    <div style={{ display: "flex", minHeight: "100vh" }}>
      <aside
        style={{
          width: 220,
          backgroundColor: "#1b5e20",
          padding: "24px 16px",
          display: "flex",
          flexDirection: "column",
          gap: 8,
        }}
      >
        <h2 style={{ color: "#fff", fontSize: 18, margin: "0 0 16px 8px" }}>
          SmartNutri Admin
        </h2>

        <NavLink to="/" end style={({ isActive }) => linkStyle(isActive)}>
          Dashboard
        </NavLink>
        <NavLink to="/foods" style={({ isActive }) => linkStyle(isActive)}>
          Thực phẩm
        </NavLink>
        <NavLink to="/users" style={({ isActive }) => linkStyle(isActive)}>
          Người dùng
        </NavLink>

        <div style={{ marginTop: "auto" }}>
          <div
            style={{
              color: "#c8e6c9",
              fontSize: 12,
              padding: "0 8px",
              marginBottom: 8,
            }}
          >
            {user?.email}
            {isAdmin && (
              <span
                style={{
                  background: "#ff9800",
                  color: "#000",
                  padding: "1px 6px",
                  borderRadius: 4,
                  marginLeft: 6,
                  fontSize: 10,
                }}
              >
                ADMIN
              </span>
            )}
          </div>
          <button
            onClick={handleLogOut}
            style={{
              width: "100%",
              padding: "8px",
              backgroundColor: "transparent",
              border: "1px solid #81c784",
              color: "#fff",
              borderRadius: 6,
              cursor: "pointer",
              fontSize: 13,
            }}
          >
            Đăng xuất
          </button>
        </div>
      </aside>

      <main style={{ flex: 1, padding: "32px", backgroundColor: "#f5f5f5" }}>
        <Outlet />
      </main>
    </div>
  );
}
