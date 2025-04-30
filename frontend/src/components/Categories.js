import React from "react";
import { NavDropdown } from "react-bootstrap";

const Categories = ({ onCategorySelect }) => {
  const categories = [
    { id: "electronics", name: "Electronics" },
    { id: "gaming", name: "Gaming" },
    { id: "home", name: "Home & Kitchen" },
    { id: "fashion", name: "Fashion" },
    { id: "all", name: "All Deals" }
  ];

  return (
    <NavDropdown title="Categories" id="categories-dropdown">
      {categories.map((category) => (
        <NavDropdown.Item
          key={category.id}
          onClick={() => onCategorySelect(category.id === "all" ? "" : category.id)}
        >
          {category.name}
        </NavDropdown.Item>
      ))}
    </NavDropdown>
  );
};

export default Categories;