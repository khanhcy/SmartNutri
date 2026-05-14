import { initializeApp } from "firebase/app";
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyA3imUN5YGKHRKbrr65ibsu2hQ6D3K2ii8",
  authDomain: "smartnutri-dev-2e67b.firebaseapp.com",
  projectId: "smartnutri-dev-2e67b",
  storageBucket: "smartnutri-dev-2e67b.firebasestorage.app",
  messagingSenderId: "317078492765",
  appId: "1:317078492765:web:3602b9942f6cb4bc5f9fb4",
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

createUserWithEmailAndPassword(auth, "admin@smartnutri.com", "admin123")
  .then((userCredential) => {
    console.log("Created user successfully:", userCredential.user.email);
    process.exit(0);
  })
  .catch((error) => {
    if (error.code === 'auth/email-already-in-use') {
        console.log("User admin@smartnutri.com already exists.");
        process.exit(0);
    } else {
        console.log("Error:", error.message);
        process.exit(1);
    }
  });
