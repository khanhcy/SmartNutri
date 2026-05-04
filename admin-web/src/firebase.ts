import {initializeApp} from "firebase/app";
import {getAuth} from "firebase/auth";
import {getFirestore} from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyA3imUN5YGKHRKbrr65ibsu2hQ6D3K2ii8",
  authDomain: "smartnutri-dev-2e67b.firebaseapp.com",
  projectId: "smartnutri-dev-2e67b",
  storageBucket: "smartnutri-dev-2e67b.firebasestorage.app",
  messagingSenderId: "317078492765",
  appId: "1:317078492765:web:3602b9942f6cb4bc5f9fb4",
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
