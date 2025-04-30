#!/bin/bash

# ZapDeals Minimal EC2 Setup Script
# Optimized for t2.micro instances with limited memory

set -e  # Exit immediately if a command exits with a non-zero status

echo "===== ZapDeals Minimal EC2 Setup Script ====="
echo "Starting setup on t2.micro EC2 instance..."

# Create swap file to prevent out of memory errors
echo "Setting up swap space..."
if [ ! -f /swapfile ]; then
    sudo dd if=/dev/zero of=/swapfile bs=128M count=16
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
    echo "Swap file created and enabled"
    free -h
fi

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install development tools and essential packages
echo "Installing essential packages..."
sudo yum install -y git python3 python3-pip nginx

# Install Node.js with minimal memory footprint
echo "Installing Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.nvm/nvm.sh
# Use Node.js 14 which has a smaller memory footprint
nvm install 14
nvm use 14
# Increase Node.js memory limit for build process
export NODE_OPTIONS="--max-old-space-size=512"

# Clone the repository
echo "Cloning the ZapDeals repository..."
cd ~
git clone https://github.com/sidhurana/zapdeals-demo.git
cd zapdeals-demo

# Set up backend with virtual environment
echo "Setting up backend..."
cd ~/zapdeals-demo/backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
# Install packages one by one to minimize memory usage
pip install fastapi
pip install uvicorn
pip install python-dotenv
pip install httpx
deactivate

# Create backend service file with memory limits
echo "Creating backend service..."
sudo tee /etc/systemd/system/zapdeals-api.service > /dev/null << EOL
[Unit]
Description=ZapDeals API
After=network.target

[Service]
User=$(whoami)
WorkingDirectory=/home/$(whoami)/zapdeals-demo/backend
ExecStart=/home/$(whoami)/zapdeals-demo/backend/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=zapdeals-api
Environment="PATH=/home/$(whoami)/zapdeals-demo/backend/venv/bin:/usr/local/bin:/usr/bin:/bin"
# Limit memory usage
MemoryLimit=150M

[Install]
WantedBy=multi-user.target
EOL

# Start backend service
echo "Starting backend service..."
sudo systemctl daemon-reload
sudo systemctl enable zapdeals-api
sudo systemctl start zapdeals-api

# Set up frontend with memory-optimized build
echo "Setting up frontend..."
cd ~/zapdeals-demo/frontend

# Increase swap space before npm install
echo "Increasing swap space for npm install..."
sudo swapoff -a
sudo dd if=/dev/zero of=/swapfile bs=128M count=32
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
free -h

# Use minimal Firebase implementation to avoid memory issues
echo "Setting up minimal Firebase implementation..."
cp ../firebase-minimal.js src/firebase.js

# Install packages without Firebase to avoid postinstall issues
echo "Installing frontend dependencies..."
# Remove firebase from package.json
sed -i 's/"firebase": "^9.6.1",//' package.json

# Install only essential packages in production mode
npm install --production --no-optional react react-dom react-bootstrap bootstrap axios

# Build frontend with minimal memory usage
echo "Building frontend..."
export NODE_OPTIONS="--max-old-space-size=512"
npm run build

# Configure nginx with minimal settings
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
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    # Optimize for low memory
    gzip off;
    access_log off;
    error_log /var/log/nginx/error.log crit;
    
    # Limit client body size
    client_max_body_size 1m;
}
EOL

# Test nginx configuration
echo "Testing nginx configuration..."
sudo nginx -t

# Restart nginx with minimal worker processes
echo "Configuring nginx for minimal memory usage..."
sudo tee /etc/nginx/nginx.conf > /dev/null << EOL
user nginx;
worker_processes 1;
error_log /var/log/nginx/error.log crit;
pid /run/nginx.pid;

events {
    worker_connections 512;
    multi_accept off;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';
    
    access_log off;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;
    
    include /etc/nginx/conf.d/*.conf;
}
EOL

# Restart nginx
echo "Restarting nginx..."
sudo systemctl restart nginx

echo "===== Minimal Setup Complete ====="
echo "ZapDeals should now be accessible at http://YOUR_EC2_PUBLIC_IP"
echo "Make sure your EC2 security group allows inbound traffic on ports 80 (HTTP) and 8000 (API)"
echo ""
echo "Memory-saving tips for t2.micro instances:"
echo "1. Monitor memory usage with 'free -h'"
echo "2. If you still encounter memory issues, increase swap space:"
echo "   sudo dd if=/dev/zero of=/swapfile bs=128M count=32"
echo "3. Restart services if needed:"
echo "   sudo systemctl restart zapdeals-api"
echo "   sudo systemctl restart nginx"