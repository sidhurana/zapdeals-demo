#!/bin/bash

# This script sets up Nginx with the correct configuration for ZapDeals

# Install Nginx if not already installed
if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    apt-get update
    apt-get install -y nginx
fi

# Create the directory structure in /var/www
echo "Creating directory structure in /var/www..."
mkdir -p /var/www/zapdeals-demo/frontend/build

# Copy frontend files to /var/www
echo "Copying frontend files to /var/www/zapdeals-demo..."
cp -r /workspace/zapdeals-demo/frontend/build/* /var/www/zapdeals-demo/frontend/build/

# Create Nginx configuration
echo "Creating Nginx configuration..."
cat > /etc/nginx/conf.d/zapdeals.conf << 'EOF'
server {
    listen 80;
    listen [::]:80;

    # Correct root directory path - using /var/www path
    root /var/www/zapdeals-demo/frontend/build;
    index index.html;

    server_name _;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:8000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Disable default site
echo "Disabling default Nginx site..."
rm -f /etc/nginx/sites-enabled/default

# Set correct permissions for www-data (Debian/Ubuntu) or nginx (CentOS/RHEL)
echo "Setting correct permissions..."
if getent group www-data > /dev/null; then
    # Debian/Ubuntu
    chown -R www-data:www-data /var/www/zapdeals-demo
    chmod -R 755 /var/www/zapdeals-demo
else
    # CentOS/RHEL
    chown -R nginx:nginx /var/www/zapdeals-demo
    chmod -R 755 /var/www/zapdeals-demo
fi

# Restart Nginx
echo "Restarting Nginx..."
if command -v systemctl &> /dev/null; then
    systemctl restart nginx
else
    service nginx restart || nginx -s reload || nginx
fi

# Start backend server
echo "Starting backend server..."
cd /workspace/zapdeals-demo

# Find the correct Python path
PYTHON_PATH=$(which python3 || which python)

# Install uvicorn if not already installed
$PYTHON_PATH -m pip install uvicorn fastapi

# Start the backend server
cd backend
nohup $PYTHON_PATH -m uvicorn main:app --host 0.0.0.0 --port 8000 > /tmp/backend.log 2>&1 &
BACKEND_PID=$!
echo "Backend server started with PID: $BACKEND_PID"

echo "Setup complete! ZapDeals is now accessible at http://localhost/"
echo "Backend API is accessible at http://localhost/api/deals"
echo "Backend server log is at /tmp/backend.log"
echo "To stop the backend server, run: kill $BACKEND_PID"

echo ""
echo "Files have been copied to /var/www/zapdeals-demo/frontend/build"
echo "Ownership has been set to nginx:nginx or www-data:www-data depending on your system"