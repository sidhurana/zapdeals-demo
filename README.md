# ZapDeals

ZapDeals is a deals aggregation application that fetches and displays deals from various e-commerce platforms like eBay, Amazon, BestBuy, etc.

## Application Structure

### Frontend
- React application with React-Bootstrap for UI components
- Components for navigation, search, category filtering, and deal display
- Firebase Authentication with Google Sign-In

### Backend
- FastAPI server with Firebase authentication
- API integration with e-commerce platforms
- Deal filtering and formatting

## Features
- Category-based filtering (Electronics, Gaming, Home & Kitchen, Fashion, etc.)
- Search functionality for filtering deals by title
- Authentication with Google
- Responsive design with Bootstrap components
- Direct links to e-commerce sites for viewing/purchasing deals

## Tech Stack
- **Frontend**: React, React-Bootstrap, Firebase, Axios
- **Backend**: FastAPI, Firebase Admin, Requests
- **Authentication**: Firebase Authentication
- **Data Sources**: Demo data (in production would use eBay API, Amazon API, etc.)

## Setup and Installation

### Frontend
```bash
cd frontend
npm install
npm start
```

### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Port Forwarding (for external access)
The repository includes a port forwarding script (`forward.py`) that allows external access to the application:

```bash
# Start the port forwarding script
python forward.py
```

This script forwards requests from port 12001 to the Nginx server running on port 80, which in turn serves the frontend and proxies API requests to the backend server on port 8000.

The application will be accessible at:
- http://localhost:12001 (local access)
- https://work-1-egmcjtdxsefviltg.prod-runtime.all-hands.dev (external access)

## Deployment on EC2

To deploy the application on an EC2 instance:

1. SSH into your EC2 instance:
   ```
   ssh -i your-key.pem ec2-user@your-ec2-ip
   ```

2. Clone the repository:
   ```
   git clone https://github.com/sidhurana/zapdeals-demo.git
   ```

3. Navigate to the project directory:
   ```
   cd zapdeals-demo
   ```

4. Choose the appropriate setup script:

   For Amazon Linux 2:
   ```
   chmod +x deploy.sh
   ./deploy.sh
   ```

   For other Amazon Linux versions or if you encounter issues with amazon-linux-extras:
   ```
   chmod +x ec2-setup.sh
   ./ec2-setup.sh
   ```

   If you encounter package conflicts (e.g., "Cannot uninstall requests, RECORD file not found"):
   ```
   chmod +x ec2-setup-alt.sh
   ./ec2-setup-alt.sh
   ```
   This alternative script uses a Python virtual environment to avoid conflicts with system packages.
   
   For t2.micro instances with limited memory (if you encounter "JavaScript heap out of memory" errors):
   ```
   chmod +x ec2-setup-minimal.sh
   ./ec2-setup-minimal.sh
   ```
   This minimal script is optimized for low memory usage and creates swap space to prevent out-of-memory errors.
   
   For extremely resource-constrained t2.micro instances (if you still encounter memory issues):
   ```
   chmod +x ec2-setup-ultra-minimal.sh
   ./ec2-setup-ultra-minimal.sh
   ```
   This ultra-minimal script skips the React build process entirely and uses a pre-built static HTML/JS implementation.

5. The application will be accessible at http://your-ec2-ip

Note: Make sure your EC2 security group allows inbound traffic on ports 80 (HTTP) and 8000 (API).

## Production Deployment with Nginx

For a production deployment with Nginx:

1. Use the provided setup script:
   ```bash
   chmod +x setup_nginx.sh
   sudo ./setup_nginx.sh
   ```

   This script will:
   - Create the directory structure at `/var/www/zapdeals-demo/frontend/build`
   - Copy the frontend files to the Nginx web root
   - Set the correct ownership for the files (nginx:nginx)
   - Copy the Nginx configuration file to `/etc/nginx/conf.d/zapdeals.conf`
   - Disable the default Nginx site to avoid conflicts
   - Test and restart Nginx

2. Start the backend server:
   ```bash
   chmod +x start_backend.sh
   ./start_backend.sh
   ```

The Nginx configuration (`nginx.conf`) includes:

```
server {
    listen 80;
    server_name localhost;

    # Frontend static files
    location / {
        root /var/www/zapdeals-demo/frontend/build;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # API proxy
    location /api/ {
        proxy_pass http://localhost:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Important Note:** Make sure the Nginx user has permission to access the frontend files. The setup script sets the correct ownership, but if you're doing this manually, remember to run:

```bash
sudo chown -R nginx:nginx /var/www/zapdeals-demo
sudo chmod -R 755 /var/www/zapdeals-demo
```

## Security Considerations

- The Firebase configuration in `firebase.js` uses placeholder values. In a production environment, you should replace these with your actual Firebase project credentials.
- For a production deployment, consider setting up HTTPS using Let's Encrypt or AWS Certificate Manager.
- Implement proper error handling and input validation in both frontend and backend.

## Demo Data
This repository includes demo data for development and testing purposes since it doesn't have actual API access to e-commerce platforms.