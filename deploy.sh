#!/bin/bash

# ZapDeals Deployment Script for Amazon Linux 2
# This script installs all dependencies and sets up the ZapDeals application

set -e  # Exit immediately if a command exits with a non-zero status

echo "===== ZapDeals Deployment Script ====="
echo "Starting deployment on Amazon Linux 2..."

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install development tools
echo "Installing development tools..."
sudo yum groupinstall "Development Tools" -y
sudo yum install -y git wget

# Install Node.js and npm
echo "Installing Node.js and npm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.nvm/nvm.sh
nvm install 16
nvm use 16
node -v
npm -v

# Install Python 3 and pip
echo "Installing Python 3 and pip..."
sudo yum install -y python3 python3-pip
python3 --version
pip3 --version

# Install nginx
echo "Installing nginx..."
# Try amazon-linux-extras first (Amazon Linux 2)
if command -v amazon-linux-extras &> /dev/null; then
    sudo amazon-linux-extras install nginx1 -y
else
    # Fall back to regular package manager
    sudo yum install nginx -y || sudo amazon-linux-extras install nginx1 -y || sudo apt-get update && sudo apt-get install -y nginx
fi
sudo systemctl enable nginx
sudo systemctl start nginx

# Clone the repository
echo "Cloning the ZapDeals repository..."
cd ~
git clone https://github.com/sidhurana/zapdeals-demo.git
cd zapdeals-demo

# Set up backend
echo "Setting up backend..."
cd ~/zapdeals-demo/backend
# Use --ignore-installed flag to avoid conflicts with system packages
pip3 install --ignore-installed -r requirements.txt
pip3 install --ignore-installed uvicorn

# Create backend service file
echo "Creating backend service..."
sudo tee /etc/systemd/system/zapdeals-api.service > /dev/null << EOL
[Unit]
Description=ZapDeals API
After=network.target

[Service]
User=$(whoami)
WorkingDirectory=/home/$(whoami)/zapdeals-demo/backend
ExecStart=/usr/local/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=zapdeals-api
Environment="PATH=/home/$(whoami)/.local/bin:/usr/local/bin:/usr/bin:/bin"

[Install]
WantedBy=multi-user.target
EOL

# Start backend service
echo "Starting backend service..."
sudo systemctl daemon-reload
sudo systemctl enable zapdeals-api
sudo systemctl start zapdeals-api

# Set up frontend
echo "Setting up frontend..."
cd ~/zapdeals-demo/frontend
npm install

# Build frontend
echo "Building frontend..."
npm run build

# Configure nginx
echo "Configuring nginx..."
sudo tee /etc/nginx/conf.d/zapdeals.conf > /dev/null << EOL
server {
    listen 80;
    server_name _;

    # Frontend
    location / {
        root /home/$(whoami)/zapdeals-demo/frontend/build;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

# Test nginx configuration
echo "Testing nginx configuration..."
sudo nginx -t

# Restart nginx
echo "Restarting nginx..."
sudo systemctl restart nginx

# Configure firewall (if enabled)
echo "Configuring firewall..."
sudo yum install -y firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

echo "===== Deployment Complete ====="
echo "ZapDeals should now be accessible at http://YOUR_EC2_PUBLIC_IP"
echo "Make sure your EC2 security group allows inbound traffic on ports 80 (HTTP) and 8000 (API)"
echo ""
echo "To check the status of the backend service:"
echo "sudo systemctl status zapdeals-api"
echo ""
echo "To view backend logs:"
echo "sudo journalctl -u zapdeals-api"
echo ""
echo "To restart the backend service:"
echo "sudo systemctl restart zapdeals-api"
echo ""
echo "To restart nginx:"
echo "sudo systemctl restart nginx"