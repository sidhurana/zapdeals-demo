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

### External Access
When running in a cloud environment, make sure to configure your security groups or firewall rules to allow access to ports 80 (HTTP) and 8000 (API).

The application will be accessible at:
- http://your-server-ip (when deployed to a server)
- http://localhost (when running locally)

## Deployment

To deploy the application:

1. Clone the repository:
   ```
   git clone https://github.com/sidhurana/zapdeals-demo.git
   ```

2. Navigate to the project directory:
   ```
   cd zapdeals-demo
   ```

3. Run the setup script:
   ```
   chmod +x setup_nginx.sh
   sudo ./setup_nginx.sh
   ```

4. The application will be accessible at http://localhost

Note: Make sure your firewall allows inbound traffic on ports 80 (HTTP) and 8000 (API)

## Production Deployment with Nginx

For a production deployment with Nginx:

1. Use the provided setup script:
   ```bash
   chmod +x setup_nginx.sh
   sudo ./setup_nginx.sh
   ```

   This script will:
   - Install Nginx if not already installed
   - Create the Nginx configuration at `/etc/nginx/conf.d/zapdeals.conf`
   - Set the correct root directory to `/workspace/zapdeals-demo/frontend/build`
   - Set the correct ownership for the files (www-data:www-data on Debian/Ubuntu or nginx:nginx on CentOS/RHEL)
   - Disable the default Nginx site to avoid conflicts
   - Restart Nginx
   - Start the backend server on port 8000

The Nginx configuration created by the script includes:

```
server {
    listen 80;
    listen [::]:80;

    # Correct root directory path
    root /workspace/zapdeals-demo/frontend/build;
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
```

**Important Note:** Make sure the Nginx user has permission to access the frontend files. The setup script sets the correct ownership, but if you're doing this manually, remember to run:

```bash
# For Debian/Ubuntu
sudo chown -R www-data:www-data /workspace/zapdeals-demo/frontend/build
sudo chmod -R 755 /workspace/zapdeals-demo/frontend/build

# For CentOS/RHEL
sudo chown -R nginx:nginx /workspace/zapdeals-demo/frontend/build
sudo chmod -R 755 /workspace/zapdeals-demo/frontend/build
```

**Troubleshooting Nginx 500 Errors:**

If you encounter a 500 error with Nginx, check the following:

1. Verify the root directory path in the Nginx configuration:
   ```bash
   grep -r "root" /etc/nginx/conf.d/
   ```
   Make sure it points to the correct location where your frontend files are stored.

2. Check Nginx error logs:
   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```

3. Verify file permissions:
   ```bash
   ls -la /workspace/zapdeals-demo/frontend/build
   ```
   The Nginx user (www-data or nginx) must have read access to these files.

4. Test the backend API directly:
   ```bash
   curl http://localhost:8000/api/deals
   ```
   If this works but the proxied version doesn't, there might be an issue with the Nginx proxy configuration.

## Security Considerations

- The Firebase configuration in `firebase.js` uses placeholder values. In a production environment, you should replace these with your actual Firebase project credentials.
- For a production deployment, consider setting up HTTPS using Let's Encrypt or AWS Certificate Manager.
- Implement proper error handling and input validation in both frontend and backend.

## Demo Data
This repository includes demo data for development and testing purposes since it doesn't have actual API access to e-commerce platforms.