import React from "react";
import { Navbar, Nav, Container, Button } from "react-bootstrap";
import Categories from "./Categories";
import SearchBar from "./SearchBar";

const AppNavbar = ({ user, signInWithGoogle, logout, setSearchTerm, onCategorySelect }) => {
  return (
    <Navbar bg="light" expand="lg" className="shadow-sm">
      <Container>
        <Navbar.Brand href="/" className="d-flex align-items-center">
          <img
            src="/zd-logo.png"
            alt="ZapDeals Logo"
            height="40"
            className="me-2"
            onError={(e) => {
              e.target.src = "https://via.placeholder.com/40x40?text=ZD";
            }}
          />
          <span className="text-primary fw-bold">ZapDeals</span>
        </Navbar.Brand>
        <Navbar.Toggle aria-controls="navbar-nav" />
        <Navbar.Collapse id="navbar-nav">
          <Nav className="me-auto">
            <Categories onCategorySelect={onCategorySelect} />
          </Nav>
          <SearchBar setSearchTerm={setSearchTerm} />
          {!user ? (
            <Button variant="primary" onClick={signInWithGoogle} className="ms-3">
              Login with Google
            </Button>
          ) : (
            <div className="d-flex align-items-center ms-3">
              <img 
                src={user.photoURL} 
                alt="User" 
                className="rounded-circle me-2" 
                width="40"
                onError={(e) => {
                  e.target.src = "https://via.placeholder.com/40x40?text=User";
                }}
              />
              <Button variant="danger" onClick={logout}>
                Logout
              </Button>
            </div>
          )}
        </Navbar.Collapse>
      </Container>
    </Navbar>
  );
};

export default AppNavbar;