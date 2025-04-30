import React from "react";
import { Container, Row, Col, Card, Button, Badge } from "react-bootstrap";

const DealsGrid = ({ deals, searchTerm }) => {
  const filteredDeals = deals.filter((deal) =>
    deal.title.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getCategoryBadgeColor = (category) => {
    const colors = {
      electronics: "primary",
      gaming: "danger",
      home: "success",
      fashion: "info"
    };
    return colors[category] || "secondary";
  };

  return (
    <Container className="py-4">
      <h2 className="text-center mb-4">Latest Deals</h2>
      <Row className="g-4">
        {filteredDeals.length > 0 ? (
          filteredDeals.map((deal, index) => (
            <Col key={index} xs={12} sm={6} md={4} lg={3}>
              <Card className="shadow-sm h-100 border-0">
                <div className="position-relative">
                  <Badge 
                    bg={getCategoryBadgeColor(deal.category)} 
                    className="position-absolute top-0 end-0 m-2"
                  >
                    {deal.category.charAt(0).toUpperCase() + deal.category.slice(1)}
                  </Badge>
                  <a
                    href={deal.url}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <Card.Img
                      variant="top"
                      src={deal.image || "https://via.placeholder.com/300?text=No+Image"}
                      onError={(e) => {
                        e.target.src = "https://via.placeholder.com/300?text=No+Image";
                      }}
                      className="p-2"
                      alt={deal.title}
                      style={{ height: "200px", objectFit: "contain" }}
                    />
                  </a>
                </div>
                <Card.Body className="d-flex flex-column">
                  <Card.Title className="text-truncate">{deal.title}</Card.Title>
                  <Card.Text className="text-danger fw-bold">
                    {deal.price}
                  </Card.Text>
                  <Button
                    variant="success"
                    className="w-100 mt-auto"
                    href={deal.url}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    View Deal
                  </Button>
                </Card.Body>
              </Card>
            </Col>
          ))
        ) : (
          <Col xs={12}>
            <div className="text-center p-5 bg-light rounded">
              <h4>No deals found</h4>
              <p>Try adjusting your search or category filter</p>
            </div>
          </Col>
        )}
      </Row>
    </Container>
  );
};

export default DealsGrid;