import React, { useState, useEffect } from "react";
import { Container } from "react-bootstrap";
import Navbar from "./components/Navbar";
import DealsGrid from "./components/DealsGrid";
import Footer from "./components/Footer";
import { auth, signInWithGoogle, logout } from "./firebase";
import { onAuthStateChanged } from "firebase/auth";
import axios from "axios";
import "./App.css";
import demoDeals from "./demoData";

function App() {
  const [user, setUser] = useState(null);
  const [deals, setDeals] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      setUser(currentUser);
    });

    return () => unsubscribe();
  }, []);

  useEffect(() => {
    // In a real app, we would fetch from the backend API
    // const fetchDeals = async () => {
    //   try {
    //     setLoading(true);
    //     const response = await axios.get(
    //       `http://localhost:8000/api/deals${selectedCategory ? `?category=${selectedCategory}` : ""}`
    //     );
    //     setDeals(response.data);
    //   } catch (error) {
    //     console.error("Error fetching deals:", error);
    //     setDeals([]);
    //   } finally {
    //     setLoading(false);
    //   }
    // };
    
    // fetchDeals();

    // Using demo data instead
    setLoading(true);
    setTimeout(() => {
      let filteredDeals = [...demoDeals];
      if (selectedCategory) {
        filteredDeals = filteredDeals.filter(deal => deal.category === selectedCategory);
      }
      setDeals(filteredDeals);
      setLoading(false);
    }, 500); // Simulate API delay
  }, [selectedCategory]);

  const handleCategorySelect = (category) => {
    setSelectedCategory(category);
  };

  return (
    <div className="d-flex flex-column min-vh-100">
      <Navbar
        user={user}
        signInWithGoogle={signInWithGoogle}
        logout={logout}
        setSearchTerm={setSearchTerm}
        onCategorySelect={handleCategorySelect}
      />
      <Container className="flex-grow-1">
        {loading ? (
          <div className="text-center my-5">
            <div className="spinner-border text-primary" role="status">
              <span className="visually-hidden">Loading...</span>
            </div>
            <p className="mt-2">Loading deals...</p>
          </div>
        ) : (
          <DealsGrid deals={deals} searchTerm={searchTerm} />
        )}
      </Container>
      <Footer />
    </div>
  );
}

export default App;