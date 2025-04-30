// Minimal Firebase configuration for low-memory environments
// This file can be used as a replacement for firebase.js when memory is limited

// Import only the essential Firebase modules
import { initializeApp } from 'firebase/app';
import { getAuth, GoogleAuthProvider, signInWithPopup, signOut } from 'firebase/auth';

// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDummyKeyForDemoPurposesOnly",
  authDomain: "zapdeals-demo.firebaseapp.com",
  projectId: "zapdeals-demo",
  storageBucket: "zapdeals-demo.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef1234567890abcdef"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const googleProvider = new GoogleAuthProvider();

// Authentication functions
const signInWithGoogle = async () => {
  try {
    const result = await signInWithPopup(auth, googleProvider);
    return result.user;
  } catch (error) {
    console.error("Error signing in with Google: ", error);
    return null;
  }
};

const logoutUser = async () => {
  try {
    await signOut(auth);
    return true;
  } catch (error) {
    console.error("Error signing out: ", error);
    return false;
  }
};

export { auth, signInWithGoogle, logoutUser };