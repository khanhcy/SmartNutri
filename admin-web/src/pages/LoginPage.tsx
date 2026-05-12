import { useState, FormEvent } from "react";
import { useNavigate, Navigate } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";

export function LoginPage() {
  const { user, loading, signIn } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const navigate = useNavigate();

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

  if (user) {
    return <Navigate to="/" replace />;
  }

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError("");
    setSubmitting(true);
    try {
      await signIn(email, password);
      navigate("/");
    } catch {
      setError("Đăng nhập thất bại. Kiểm tra email và mật khẩu.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div
      style={{
        height: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "#e8f5e9",
        fontFamily: "Arial",
      }}
    >
      <form
        onSubmit={handleSubmit}
        style={{
          backgroundColor: "#fff",
          padding: 40,
          borderRadius: 12,
          boxShadow: "0 2px 16px rgba(0,0,0,0.1)",
          width: 380,
          maxWidth: "90vw",
        }}
      >
        <h1 style={{ margin: "0 0 8px", color: "#2E7D32" }}>
          SmartNutri Admin
        </h1>
        <p style={{ margin: "0 0 24px", color: "#666", fontSize: 14 }}>
          Đăng nhập để quản lý dữ liệu
        </p>

        <label
          style={{ display: "block", marginBottom: 4, fontSize: 14, fontWeight: 500 }}
        >
          Email
        </label>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
          style={{
            display: "block",
            width: "100%",
            padding: "10px 12px",
            marginBottom: 16,
            border: "1px solid #ccc",
            borderRadius: 6,
            fontSize: 14,
            boxSizing: "border-box",
          }}
        />

        <label
          style={{ display: "block", marginBottom: 4, fontSize: 14, fontWeight: 500 }}
        >
          Mật khẩu
        </label>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          style={{
            display: "block",
            width: "100%",
            padding: "10px 12px",
            marginBottom: 16,
            border: "1px solid #ccc",
            borderRadius: 6,
            fontSize: 14,
            boxSizing: "border-box",
          }}
        />

        {error && (
          <p style={{ color: "#d32f2f", fontSize: 13, marginBottom: 12 }}>
            {error}
          </p>
        )}

        <button
          type="submit"
          disabled={submitting}
          style={{
            width: "100%",
            padding: "12px",
            backgroundColor: "#2E7D32",
            color: "#fff",
            border: "none",
            borderRadius: 6,
            fontSize: 15,
            fontWeight: 600,
            cursor: submitting ? "not-allowed" : "pointer",
            opacity: submitting ? 0.7 : 1,
          }}
        >
          {submitting ? "Đang đăng nhập..." : "Đăng nhập"}
        </button>
      </form>
    </div>
  );
}
