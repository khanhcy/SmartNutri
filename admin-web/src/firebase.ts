import {initializeApp} from "firebase/app";
import {getAuth} from "firebase/auth";
import {getFirestore} from "firebase/firestore";

const firebaseConfig = {
  apiKey: "replace-me",
  authDomain: "smartnutri-dev.firebaseapp.com",
  projectId: "smartnutri-dev",
  storageBucket: "smartnutri-dev.appspot.com",
  messagingSenderId: "1234567890",
  appId: "1:1234567890:web:replace-me",
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
