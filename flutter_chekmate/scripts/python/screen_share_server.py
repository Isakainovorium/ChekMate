#!/usr/bin/env python3
"""
Screen Share Server
Captures screenshots and serves them via HTTP so AI can view them
"""

import time
import base64
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

try:
    from PIL import ImageGrab
    SCREENSHOT_AVAILABLE = True
except ImportError:
    SCREENSHOT_AVAILABLE = False

class ScreenShareHandler(BaseHTTPRequestHandler):
    """HTTP handler for screen sharing"""
    
    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/':
            # Serve HTML viewer
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            html = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Screen Share - ChekMate App</title>
                <style>
                    body {
                        margin: 0;
                        padding: 20px;
                        background: #1a1a1a;
                        color: #fff;
                        font-family: Arial, sans-serif;
                    }
                    h1 {
                        text-align: center;
                        color: #FEBD59;
                    }
                    #screenshot {
                        max-width: 100%;
                        border: 2px solid #FEBD59;
                        border-radius: 8px;
                        display: block;
                        margin: 20px auto;
                    }
                    .info {
                        text-align: center;
                        color: #888;
                        margin: 10px 0;
                    }
                    .controls {
                        text-align: center;
                        margin: 20px 0;
                    }
                    button {
                        background: #FEBD59;
                        color: #000;
                        border: none;
                        padding: 10px 20px;
                        border-radius: 5px;
                        cursor: pointer;
                        font-size: 16px;
                        margin: 0 10px;
                    }
                    button:hover {
                        background: #DF912F;
                    }
                </style>
            </head>
            <body>
                <h1>👁️ Screen Share - ChekMate App</h1>
                <div class="info">
                    <p>This page shows your screen in real-time so the AI can see what you see.</p>
                    <p id="status">Loading...</p>
                </div>
                <div class="controls">
                    <button onclick="toggleAutoRefresh()">Toggle Auto-Refresh</button>
                    <button onclick="captureNow()">Capture Now</button>
                    <button onclick="downloadScreenshot()">Download Screenshot</button>
                </div>
                <img id="screenshot" src="/screenshot" alt="Screen capture">
                
                <script>
                    let autoRefresh = true;
                    let refreshInterval;
                    
                    function updateScreenshot() {
                        const img = document.getElementById('screenshot');
                        const timestamp = new Date().getTime();
                        img.src = '/screenshot?t=' + timestamp;
                        document.getElementById('status').textContent = 
                            'Last updated: ' + new Date().toLocaleTimeString();
                    }
                    
                    function toggleAutoRefresh() {
                        autoRefresh = !autoRefresh;
                        if (autoRefresh) {
                            refreshInterval = setInterval(updateScreenshot, 2000);
                            document.getElementById('status').textContent = 'Auto-refresh: ON';
                        } else {
                            clearInterval(refreshInterval);
                            document.getElementById('status').textContent = 'Auto-refresh: OFF';
                        }
                    }
                    
                    function captureNow() {
                        updateScreenshot();
                    }
                    
                    function downloadScreenshot() {
                        const link = document.createElement('a');
                        link.href = '/screenshot?download=1';
                        link.download = 'screenshot_' + Date.now() + '.png';
                        link.click();
                    }
                    
                    // Start auto-refresh
                    refreshInterval = setInterval(updateScreenshot, 2000);
                    updateScreenshot();
                </script>
            </body>
            </html>
            """
            
            self.wfile.write(html.encode())
            
        elif self.path.startswith('/screenshot'):
            # Capture and serve screenshot
            if not SCREENSHOT_AVAILABLE:
                self.send_response(500)
                self.send_header('Content-type', 'text/plain')
                self.end_headers()
                self.wfile.write(b'PIL not installed. Run: pip install Pillow')
                return
            
            try:
                # Capture screenshot
                screenshot = ImageGrab.grab()
                
                # Save to bytes
                from io import BytesIO
                buffer = BytesIO()
                screenshot.save(buffer, format='PNG')
                image_data = buffer.getvalue()
                
                # Send response
                self.send_response(200)
                self.send_header('Content-type', 'image/png')
                self.send_header('Content-length', len(image_data))
                self.end_headers()
                self.wfile.write(image_data)
                
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-type', 'text/plain')
                self.end_headers()
                self.wfile.write(f'Error capturing screenshot: {e}'.encode())
        
        elif self.path == '/api/screenshot':
            # API endpoint for programmatic access
            if not SCREENSHOT_AVAILABLE:
                self.send_json_response({'error': 'PIL not installed'}, 500)
                return
            
            try:
                screenshot = ImageGrab.grab()
                
                # Convert to base64
                from io import BytesIO
                buffer = BytesIO()
                screenshot.save(buffer, format='PNG')
                image_data = base64.b64encode(buffer.getvalue()).decode('utf-8')
                
                self.send_json_response({
                    'success': True,
                    'image': image_data,
                    'width': screenshot.width,
                    'height': screenshot.height,
                    'timestamp': time.time()
                })
                
            except Exception as e:
                self.send_json_response({'error': str(e)}, 500)
        
        else:
            self.send_response(404)
            self.end_headers()
    
    def send_json_response(self, data, status=200):
        """Send JSON response"""
        self.send_response(status)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())
    
    def log_message(self, format, *args):
        """Suppress log messages"""
        pass

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Screen Share Server for AI')
    parser.add_argument('--port', type=int, default=8888, help='Server port (default: 8888)')
    parser.add_argument('--host', default='localhost', help='Server host (default: localhost)')
    
    args = parser.parse_args()
    
    if not SCREENSHOT_AVAILABLE:
        print("❌ ERROR: PIL (Pillow) not installed")
        print("📦 Install: pip install Pillow")
        return
    
    print("\n" + "="*70)
    print("👁️  SCREEN SHARE SERVER - AI Visual Access")
    print("="*70 + "\n")
    
    print(f"🌐 Server starting on http://{args.host}:{args.port}")
    print(f"📸 Screenshots will be captured every 2 seconds")
    print(f"\n📋 USAGE:")
    print(f"   1. Open http://{args.host}:{args.port} in your browser")
    print(f"   2. The AI can now access /api/screenshot to see your screen")
    print(f"   3. Press Ctrl+C to stop\n")
    
    print("="*70 + "\n")
    
    try:
        server = HTTPServer((args.host, args.port), ScreenShareHandler)
        print(f"✅ Server running! Open: http://{args.host}:{args.port}\n")
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n\n🛑 Server stopped by user")
    except Exception as e:
        print(f"\n❌ ERROR: {e}")

if __name__ == '__main__':
    main()

