import http.server
import socketserver
import urllib.request
import urllib.error
import urllib.parse
import logging
import sys
import os

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)
logger = logging.getLogger('zapdeals-proxy')

PORT = 12001  # Use the port provided in the runtime information
TARGET_HOST = "http://localhost:80"  # The Nginx server

# Note: For production deployment
# 1. Copy frontend files to /var/www/zapdeals/frontend/build
# 2. Set ownership: chown -R nginx:nginx /var/www/zapdeals
# 3. Update Nginx config to use root /var/www/zapdeals/frontend/build

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_HEAD(self):
        self.forward_request('HEAD')
        
    def do_GET(self):
        self.forward_request('GET')

    def do_POST(self):
        self.forward_request('POST')
        
    def do_PUT(self):
        self.forward_request('PUT')
        
    def do_DELETE(self):
        self.forward_request('DELETE')
        
    def do_OPTIONS(self):
        self.forward_request('OPTIONS')
        
    def forward_request(self, method):
        url = TARGET_HOST + self.path
        logger.info(f"Forwarding {method} request to {url}")
        
        try:
            # Get request body for methods that support it
            post_data = None
            if method in ['POST', 'PUT']:
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length) if content_length > 0 else None
            
            # Create request
            req = urllib.request.Request(url, data=post_data, method=method)
            
            # Copy headers
            for header in self.headers:
                req.add_header(header, self.headers[header])
                
            # Send request
            response = urllib.request.urlopen(req)
            
            # Forward response
            self.send_response(response.status)
            for header in response.headers._headers:
                self.send_header(header[0], header[1])
            self.end_headers()
            
            # Only write body for non-HEAD requests
            if method != 'HEAD':
                self.wfile.write(response.read())
                
            logger.info(f"Successfully forwarded {method} request to {url} - Status: {response.status}")
            
        except urllib.error.URLError as e:
            logger.error(f"Error forwarding {method} request to {url}: {str(e)}")
            self.send_response(500)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            if method != 'HEAD':
                self.wfile.write(f"Error: {str(e)}".encode())
        except Exception as e:
            logger.error(f"Unexpected error forwarding {method} request to {url}: {str(e)}")
            self.send_response(500)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            if method != 'HEAD':
                self.wfile.write(f"Unexpected error: {str(e)}".encode())

class ThreadedHTTPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True

def setup_production_environment():
    """
    Helper function to set up the production environment.
    This would typically be run on the server during deployment.
    """
    import subprocess
    import shutil
    
    try:
        # Create directory structure if it doesn't exist
        os.makedirs('/var/www/zapdeals/frontend/build', exist_ok=True)
        
        # Copy frontend files
        if os.path.exists('./frontend/build'):
            shutil.copytree('./frontend/build', '/var/www/zapdeals/frontend/build', dirs_exist_ok=True)
            logger.info("Copied frontend files to /var/www/zapdeals/frontend/build")
        else:
            logger.error("Frontend build directory not found")
            return False
        
        # Change ownership to nginx:nginx
        subprocess.run(['chown', '-R', 'nginx:nginx', '/var/www/zapdeals'])
        logger.info("Changed ownership of /var/www/zapdeals to nginx:nginx")
        
        # Update Nginx configuration
        nginx_config = """
server {
    listen 80;
    listen [::]:80;

    root /var/www/zapdeals/frontend/build;
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
"""
        with open('/etc/nginx/conf.d/zapdeals.conf', 'w') as f:
            f.write(nginx_config)
        logger.info("Updated Nginx configuration")
        
        # Restart Nginx
        subprocess.run(['systemctl', 'restart', 'nginx'])
        logger.info("Restarted Nginx")
        
        return True
    except Exception as e:
        logger.error(f"Error setting up production environment: {str(e)}")
        return False

if __name__ == "__main__":
    try:
        # Uncomment the line below to set up the production environment
        # setup_production_environment()
        
        httpd = ThreadedHTTPServer(("0.0.0.0", PORT), ProxyHandler)
        logger.info(f"Starting proxy server on port {PORT}, forwarding to {TARGET_HOST}")
        httpd.serve_forever()
    except KeyboardInterrupt:
        logger.info("Stopping server...")
        httpd.server_close()
    except Exception as e:
        logger.error(f"Server error: {str(e)}")