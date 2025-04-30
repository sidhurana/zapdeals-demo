#!/bin/bash

# ZapDeals EC2 Setup Script
# This is a simplified setup script for Amazon Linux instances that don't have amazon-linux-extras

set -e  # Exit immediately if a command exits with a non-zero status

echo "===== ZapDeals EC2 Setup Script ====="
echo "Starting setup on EC2 instance..."

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
sudo yum install nginx -y
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
pip3 install -r requirements.txt
pip3 install uvicorn

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

echo "===== Setup Complete ====="
echo "ZapDeals should now be accessible at http://YOUR_EC2_PUBLIC_IP"
echo "Make sure your EC2 security group allows inbound traffic on ports 80 (HTTP) and 8000 (API)"
echo ""
echo "To check the status of the backend service:"
echo "sudo systemctl status zapdeals-api"
echo ""
echo "To view backend logs:"
echo "sudo journalctl -u zapdeals-api"