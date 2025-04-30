import React, { useState } from "react";
import { Form, FormControl, Button } from "react-bootstrap";

const SearchBar = ({ setSearchTerm }) => {
  const [localSearchTerm, setLocalSearchTerm] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    setSearchTerm(localSearchTerm);
  };

  return (
    <Form className="d-flex" onSubmit={handleSubmit}>
      <FormControl
        type="search"
        placeholder="Search deals..."
        className="me-2"
        aria-label="Search"
        value={localSearchTerm}
        onChange={(e) => setLocalSearchTerm(e.target.value)}
      />
      <Button variant="outline-primary" type="submit">
        Search
      </Button>
    </Form>
  );
};

export default SearchBar;