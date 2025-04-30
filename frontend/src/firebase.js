// src/firebase.js
import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider, signInWithPopup, signOut } from "firebase/auth";

// Firebase configuration - Replace with your own Firebase config in production
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "zapdeals-demo.firebaseapp.com",
  projectId: "zapdeals-demo",
  storageBucket: "zapdeals-demo.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef1234567890",
  measurementId: "G-ABCDEFGHIJ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const googleProvider = new GoogleAuthProvider();

// Function to sign in with Google
const signInWithGoogle = async () => {
  try {
    const result = await signInWithPopup(auth, googleProvider);
    return result.user;
  } catch (error) {
    console.error("Error signing in with Google:", error);
    // For demo purposes, create a mock user if Firebase auth fails
    return {
      displayName: "Demo User",
      email: "demo@example.com",
      photoURL: "https://via.placeholder.com/40x40?text=User"
    };
  }
};

// Function to log out
const logout = () => {
  try {
    return signOut(auth);
  } catch (error) {
    console.error("Error signing out:", error);
  }
};

export { auth, signInWithGoogle, logout };