// Firebase Web SDK Configuration for flutter-3f849
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
import { getFirestore } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";
import { getAuth } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js";

const firebaseConfig = {
  apiKey: "AIzaSyAOZgBDJWktmesqLnjfXleiw185Ma7cZ0M",
  authDomain: "flutter-3f849.firebaseapp.com",
  projectId: "flutter-3f849",
  storageBucket: "flutter-3f849.firebasestorage.app",
  messagingSenderId: "707109012803",
  appId: "1:707109012803:web:947f58cc0143140fe65bf6",
  measurementId: "G-HTHJL542PR"
};

// Initialize Firebase App
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);

export { app, db, auth, firebaseConfig };
