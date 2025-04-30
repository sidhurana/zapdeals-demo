#!/bin/bash

# ZapDeals Ultra-Minimal EC2 Setup Script
# For extremely resource-constrained t2.micro instances
# This script skips the React build process and uses a pre-built static version

set -e  # Exit immediately if a command exits with a non-zero status

echo "===== ZapDeals Ultra-Minimal EC2 Setup Script ====="
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

# Install only essential packages
echo "Installing essential packages..."
sudo yum install -y git python3 python3-pip nginx

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

# Set up frontend with pre-built static files
echo "Setting up frontend with pre-built static files..."
cd ~/zapdeals-demo/frontend

# Create a minimal static HTML version of the app
mkdir -p build
cat > build/index.html << EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ZapDeals - eBay Deals Finder</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .deal-card {
            transition: transform 0.3s;
            height: 100%;
        }
        .deal-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }
        .navbar-brand {
            font-weight: bold;
            color: #0d6efd;
        }
        .footer {
            background-color: #f8f9fa;
            padding: 20px 0;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-light bg-light shadow-sm">
        <div class="container">
            <a class="navbar-brand d-flex align-items-center" href="/">
                <span class="text-primary fw-bold">ZapDeals</span>
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="categoriesDropdown" role="button" data-bs-toggle="dropdown">
                            Categories
                        </a>
                        <ul class="dropdown-menu" id="categories-menu">
                            <li><a class="dropdown-item" href="#" data-category="electronics">Electronics</a></li>
                            <li><a class="dropdown-item" href="#" data-category="fashion">Fashion</a></li>
                            <li><a class="dropdown-item" href="#" data-category="home">Home & Garden</a></li>
                            <li><a class="dropdown-item" href="#" data-category="toys">Toys & Games</a></li>
                            <li><a class="dropdown-item" href="#" data-category="sports">Sports & Outdoors</a></li>
                        </ul>
                    </li>
                </ul>
                <div class="d-flex">
                    <input class="form-control me-2" type="search" placeholder="Search deals..." id="search-input">
                    <button class="btn btn-outline-primary" id="search-button">Search</button>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container py-4">
        <h2 class="text-center mb-4" id="page-title">Latest eBay Deals</h2>
        <div class="row g-4" id="deals-container">
            <!-- Deals will be loaded here -->
            <div class="text-center">
                <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Loading...</span>
                </div>
                <p>Loading deals...</p>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="footer mt-auto py-3 bg-light">
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                    <h5>ZapDeals</h5>
                    <p>Find the best deals on eBay quickly and easily.</p>
                </div>
                <div class="col-md-6 text-md-end">
                    <p>&copy; 2023 ZapDeals Demo</p>
                    <p>This is a demo application.</p>
                </div>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Simple JavaScript to fetch and display deals
        document.addEventListener('DOMContentLoaded', function() {
            const dealsContainer = document.getElementById('deals-container');
            const searchInput = document.getElementById('search-input');
            const searchButton = document.getElementById('search-button');
            const pageTitle = document.getElementById('page-title');
            const categoryLinks = document.querySelectorAll('[data-category]');
            
            let currentCategory = '';
            let searchTerm = '';
            
            // Fetch deals from API
            function fetchDeals() {
                let url = '/api/deals';
                if (currentCategory) {
                    url += '?category=' + currentCategory;
                }
                
                fetch(url)
                    .then(response => response.json())
                    .then(deals => {
                        displayDeals(deals);
                    })
                    .catch(error => {
                        console.error('Error fetching deals:', error);
                        dealsContainer.innerHTML = '<div class="col-12 text-center"><p>Error loading deals. Please try again later.</p></div>';
                    });
            }
            
            // Display deals in the container
            function displayDeals(deals) {
                // Filter by search term if provided
                if (searchTerm) {
                    deals = deals.filter(deal => 
                        deal.title.toLowerCase().includes(searchTerm.toLowerCase())
                    );
                }
                
                if (deals.length === 0) {
                    dealsContainer.innerHTML = '<div class="col-12 text-center"><p>No deals found</p></div>';
                    return;
                }
                
                let html = '';
                deals.forEach(deal => {
                    html += \`
                    <div class="col-12 col-sm-6 col-md-4 col-lg-3">
                        <div class="card shadow-sm deal-card">
                            <a href="https://www.ebay.com/sch/i.html?_nkw=\${encodeURIComponent(deal.title)}" target="_blank" rel="noopener noreferrer">
                                <img src="\${deal.image || 'https://via.placeholder.com/300?text=No+Image'}" 
                                     class="card-img-top p-2" 
                                     alt="\${deal.title}"
                                     onerror="this.src='https://via.placeholder.com/300?text=No+Image'">
                            </a>
                            <div class="card-body">
                                <h5 class="card-title text-truncate">\${deal.title}</h5>
                                <p class="card-text text-danger fw-bold">\${deal.price ? '$' + deal.price : 'Price Not Available'}</p>
                                <a href="https://www.ebay.com/sch/i.html?_nkw=\${encodeURIComponent(deal.title)}" 
                                   class="btn btn-success w-100" 
                                   target="_blank">View on eBay</a>
                            </div>
                        </div>
                    </div>
                    \`;
                });
                
                dealsContainer.innerHTML = html;
            }
            
            // Set up search functionality
            searchButton.addEventListener('click', function() {
                searchTerm = searchInput.value.trim();
                fetchDeals();
                if (searchTerm) {
                    pageTitle.textContent = 'Search Results: ' + searchTerm;
                } else {
                    pageTitle.textContent = currentCategory ? 
                        currentCategory.charAt(0).toUpperCase() + currentCategory.slice(1) + ' Deals' : 
                        'Latest eBay Deals';
                }
            });
            
            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    searchButton.click();
                }
            });
            
            // Set up category filtering
            categoryLinks.forEach(link => {
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    currentCategory = this.getAttribute('data-category');
                    searchTerm = '';
                    searchInput.value = '';
                    pageTitle.textContent = currentCategory.charAt(0).toUpperCase() + currentCategory.slice(1) + ' Deals';
                    fetchDeals();
                });
            });
            
            // Initial load
            fetchDeals();
        });
    </script>
</body>
</html>
EOL

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

echo "===== Ultra-Minimal Setup Complete ====="
echo "ZapDeals should now be accessible at http://YOUR_EC2_PUBLIC_IP"
echo "This ultra-minimal version uses a static HTML/JS implementation instead of React"
echo "Make sure your EC2 security group allows inbound traffic on ports 80 (HTTP) and 8000 (API)"