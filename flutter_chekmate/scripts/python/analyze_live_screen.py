#!/usr/bin/env python3
"""
Analyze Live Screen - Fetches screenshot from screen share server and analyzes it
"""

import sys
import requests
import base64
import json

def fetch_screenshot(server_url="http://localhost:8888"):
    """Fetch screenshot from screen share server"""
    try:
        response = requests.get(f"{server_url}/api/screenshot")
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                return data
        return None
    except Exception as e:
        print(f"Error fetching screenshot: {e}")
        return None

def analyze_with_vision(image_base64, prompt):
    """
    Analyze screenshot using AI vision
    This is a placeholder - you would integrate with Anthropic or OpenAI API here
    """
    # For now, just return the image data
    return {
        'success': True,
        'message': 'Screenshot captured successfully',
        'image_size': len(image_base64)
    }

def main():
    print("\n" + "="*70)
    print("👁️  LIVE SCREEN ANALYZER")
    print("="*70 + "\n")
    
    print("📸 Fetching screenshot from screen share server...")
    screenshot_data = fetch_screenshot()
    
    if not screenshot_data:
        print("❌ Failed to fetch screenshot. Is the screen share server running?")
        print("   Run: python screen_share_server.py")
        sys.exit(1)
    
    print(f"✅ Screenshot captured: {screenshot_data['width']}x{screenshot_data['height']}")
    print(f"📊 Image size: {len(screenshot_data['image'])} bytes\n")
    
    # Save screenshot to file for inspection
    image_data = base64.b64decode(screenshot_data['image'])
    filename = f"live_screenshot_{int(screenshot_data['timestamp'])}.png"
    
    with open(filename, 'wb') as f:
        f.write(image_data)
    
    print(f"💾 Screenshot saved to: {filename}\n")
    
    print("="*70)
    print("📊 ANALYSIS:")
    print("="*70 + "\n")
    
    print("The screenshot has been captured and saved.")
    print("To analyze it with AI vision, you would need to:")
    print("1. Install: pip install anthropic")
    print("2. Set API key: $env:ANTHROPIC_API_KEY='your-key'")
    print("3. Run: python visual_analyzer_mcp.py " + filename)
    print("\nOr integrate the vision API directly into this script.")

if __name__ == '__main__':
    main()

