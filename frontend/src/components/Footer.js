import React from "react";
import { Container, Row, Col } from "react-bootstrap";

const Footer = () => {
  return (
    <footer className="bg-light text-center py-3 mt-5 shadow-sm">
      <Container>
        <Row>
          <Col md={4} className="text-md-start">
            <h5>ZapDeals</h5>
            <p className="text-muted">Finding the best deals for you</p>
          </Col>
          <Col md={4}>
            <h5>Quick Links</h5>
            <ul className="list-unstyled">
              <li><a href="#" className="text-decoration-none">Home</a></li>
              <li><a href="#" className="text-decoration-none">About</a></li>
              <li><a href="#" className="text-decoration-none">Contact</a></li>
            </ul>
          </Col>
          <Col md={4} className="text-md-end">
            <h5>Connect With Us</h5>
            <div>
              <a href="#" className="text-decoration-none me-2">Facebook</a>
              <a href="#" className="text-decoration-none me-2">Twitter</a>
              <a href="#" className="text-decoration-none">Instagram</a>
            </div>
          </Col>
        </Row>
        <hr />
        <p className="text-muted">&copy; 2023 ZapDeals. All rights reserved.</p>
      </Container>
    </footer>
  );
};

export default Footer;