import { Navigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";

export function AuthGuard({ children }: { children: React.ReactNode }) {
  const { user, loading, isAdmin } = useAuth();

  if (loading) {
    return (
      <div
        style={{
          height: "100vh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontFamily: "Arial",
        }}
      >
        Đang tải...
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (!isAdmin) {
    return <AccessDenied />;
  }

  return <>{children}</>;
}

function AccessDenied() {
  return (
    <div
      style={{
        height: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: 24,
        fontFamily: "Arial",
        backgroundColor: "#f5f7f5",
      }}
    >
      <div
        style={{
          maxWidth: 420,
          padding: 24,
          borderRadius: 12,
          backgroundColor: "#fff",
          boxShadow: "0 8px 24px rgba(0,0,0,0.08)",
          textAlign: "center",
        }}
      >
        <h1 style={{ marginTop: 0, color: "#1b5e20" }}>Không có quyền truy cập</h1>
        <p style={{ marginBottom: 0, color: "#555", lineHeight: 1.5 }}>
          Tài khoản này chưa được cấp quyền quản trị SmartNutri.
        </p>
      </div>
    </div>
  );
}
