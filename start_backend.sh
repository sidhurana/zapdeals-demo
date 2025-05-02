#!/bin/bash

# Start the backend server
echo "Starting backend server on port 8000..."
python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000 > /tmp/backend.log 2>&1 &
BACKEND_PID=$!
echo "Backend server started with PID: $BACKEND_PID"

echo "Backend server started successfully!"
echo "API is accessible at: http://localhost:8000/api/deals"
echo "To stop the server, run: kill $BACKEND_PID"

# Save PID for later use
echo "$BACKEND_PID" > /tmp/zapdeals_backend_pid.txt