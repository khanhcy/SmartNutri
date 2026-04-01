import React from "react";
import ReactDOM from "react-dom/client";
import {onAuthStateChanged, signInWithEmailAndPassword, signOut, User} from "firebase/auth";
import {auth} from "./firebase";

function App(): JSX.Element {
  const [email, setEmail] = React.useState("");
  const [password, setPassword] = React.useState("");
  const [user, setUser] = React.useState<User | null>(null);
  const [error, setError] = React.useState("");

  React.useEffect(() => {
    return onAuthStateChanged(auth, (nextUser) => setUser(nextUser));
  }, []);

  const handleLogin = async (): Promise<void> => {
    setError("");
    try {
      await signInWithEmailAndPassword(auth, email, password);
    } catch (err) {
      setError("Dang nhap that bai");
    }
  };

  return (
    <main style={{fontFamily: "Arial", margin: "2rem", maxWidth: 560}}>
      <h1>SmartNutri Admin</h1>
      {!user ? (
        <section>
          <p>Dang nhap de quan ly du lieu thuc pham, bai tap, template.</p>
          <input
            placeholder="Email"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            style={{display: "block", marginBottom: 8, width: "100%"}}
          />
          <input
            placeholder="Password"
            type="password"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            style={{display: "block", marginBottom: 8, width: "100%"}}
          />
          <button onClick={handleLogin}>Dang nhap</button>
          {error && <p style={{color: "red"}}>{error}</p>}
        </section>
      ) : (
        <section>
          <p>Xin chao {user.email}</p>
          <p>Admin CRUD scaffold da san sang cho cac module tiep theo.</p>
          <button onClick={() => signOut(auth)}>Dang xuat</button>
        </section>
      )}
    </main>
  );
}

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
