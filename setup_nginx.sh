#!/bin/bash

# This script sets up Nginx with the correct configuration for ZapDeals

# Create the directory structure
sudo mkdir -p /var/www/zapdeals-demo/frontend/build

# Copy the frontend files
sudo cp -r /workspace/zapdeals-demo/frontend/build/* /var/www/zapdeals-demo/frontend/build/

# Set proper permissions
sudo chown -R nginx:nginx /var/www/zapdeals-demo
sudo chmod -R 755 /var/www/zapdeals-demo

# Copy Nginx configuration
sudo cp /workspace/zapdeals-demo/nginx.conf /etc/nginx/conf.d/zapdeals.conf

# Disable default site to avoid conflicts
sudo rm -f /etc/nginx/conf.d/default.conf

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

echo "Nginx setup completed successfully!"
echo "Frontend is accessible at: http://localhost"
echo "API is accessible at: http://localhost/api/deals"