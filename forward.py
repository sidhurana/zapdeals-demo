import http.server
import socketserver
import urllib.request
import urllib.error
import urllib.parse
import logging
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)
logger = logging.getLogger('zapdeals-proxy')

PORT = 12001  # Use the port provided in the runtime information
TARGET_HOST = "http://localhost:80"  # The Nginx server

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

if __name__ == "__main__":
    try:
        httpd = ThreadedHTTPServer(("0.0.0.0", PORT), ProxyHandler)
        logger.info(f"Starting proxy server on port {PORT}, forwarding to {TARGET_HOST}")
        httpd.serve_forever()
    except KeyboardInterrupt:
        logger.info("Stopping server...")
        httpd.server_close()
    except Exception as e:
        logger.error(f"Server error: {str(e)}")