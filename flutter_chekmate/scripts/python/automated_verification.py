#!/usr/bin/env python3
"""
Automated Functionality Verification
Fully automated: starts app, captures screenshot, analyzes functionality
"""

import os
import sys
import time
import base64
import subprocess
import requests
from datetime import datetime
from openai import OpenAI
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def load_api_key():
    """Load OpenAI API key"""
    key_file = ".openai_key"
    if os.path.exists(key_file):
        with open(key_file, 'r') as f:
            content = f.read().strip()
            return content.split('\n')[0].strip()
    
    # Try .openai_key.example
    key_file = ".openai_key.example"
    if os.path.exists(key_file):
        with open(key_file, 'r') as f:
            content = f.read().strip()
            return content.split('\n')[0].strip()
    
    return os.getenv('OPENAI_API_KEY')

def check_flutter_available():
    """Check if Flutter is available"""
    try:
        result = subprocess.run(['flutter', '--version'], 
                              capture_output=True, 
                              text=True, 
                              timeout=10)
        return result.returncode == 0
    except:
        return False

def start_flutter_app():
    """Start Flutter app in background"""
    print("🚀 Starting Flutter app...")
    print("   Command: flutter run -d chrome --web-port=8080")
    print("")
    
    try:
        # Start Flutter in background
        process = subprocess.Popen(
            ['flutter', 'run', '-d', 'chrome', '--web-port=8080'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        print("⏳ Waiting for app to start...")
        
        # Wait for app to be ready (check localhost:8080)
        max_wait = 180  # 3 minutes
        waited = 0
        
        while waited < max_wait:
            time.sleep(5)
            waited += 5
            
            try:
                response = requests.get("http://localhost:8080", timeout=2)
                if response.status_code == 200:
                    print(f"✅ App started successfully! (took {waited} seconds)")
                    print("")
                    # Wait a bit more for full render
                    time.sleep(10)
                    return process
            except:
                print(f"   Still waiting... ({waited}/{max_wait} seconds)")
        
        print("❌ App failed to start within timeout")
        process.kill()
        return None
        
    except Exception as e:
        print(f"❌ Error starting Flutter: {e}")
        return None

def check_app_running():
    """Check if app is already running"""
    try:
        response = requests.get("http://localhost:8080", timeout=2)
        return response.status_code == 200
    except:
        return False

def capture_screenshot_selenium():
    """Capture screenshot using Selenium"""
    print("📸 Capturing Flutter app screenshot with Selenium...")
    
    try:
        # Setup Chrome options
        chrome_options = Options()
        chrome_options.add_argument('--headless')
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument('--window-size=1920,1080')
        
        # Create driver
        driver = webdriver.Chrome(options=chrome_options)
        
        # Navigate to app
        driver.get("http://localhost:8080")
        
        # Wait for page to load
        print("   Waiting for page to load...")
        time.sleep(5)
        
        # Take screenshot
        timestamp = int(time.time())
        screenshot_path = f"flutter_screenshot_{timestamp}.png"
        driver.save_screenshot(screenshot_path)
        
        driver.quit()
        
        print(f"✅ Screenshot saved: {screenshot_path}")
        print("")
        
        return screenshot_path
        
    except Exception as e:
        print(f"❌ Error capturing screenshot: {e}")
        print("   Make sure Chrome/Chromedriver is installed")
        return None

def encode_image(image_path):
    """Encode image to base64"""
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def analyze_functionality(figma_path, flutter_path, api_key):
    """Analyze functionality using OpenAI Vision API"""
    
    print("🤖 Analyzing functionality with GPT-4 Vision...")
    print("   Focus: FUNCTIONALITY and LAYOUT (not colors)")
    print("")
    
    client = OpenAI(api_key=api_key)
    
    # Encode images
    figma_base64 = encode_image(figma_path)
    flutter_base64 = encode_image(flutter_path)
    
    # Create the prompt
    prompt = """You are a functionality verification expert. Compare these two images:
1. Figma Design (reference)
2. Flutter App (implementation)

CRITICAL: Focus ONLY on FUNCTIONALITY and LAYOUT. DO NOT analyze colors - they are already correct.

Analyze and report on:

## FUNCTIONALITY VERIFICATION

### 1. UI Components Present
- Are all buttons from Figma present in Flutter?
- Are all input fields present?
- Are all navigation elements present?
- Are all icons present?
- Are all text elements present?
- Are all cards/posts present?

### 2. Layout & Positioning
- Are components in the correct positions?
- Is the spacing between elements correct?
- Are component sizes appropriate?
- Is the visual hierarchy correct?
- Is the grid/layout structure correct?

### 3. Navigation Elements
- Are all navigation tabs/buttons visible?
- Are navigation labels correct?
- Is the navigation structure clear?
- Are tab indicators present?

### 4. Interactive Elements
- Are all clickable elements visible?
- Are buttons properly styled (shape, size)?
- Are form fields properly styled?
- Are interactive states indicated?

### 5. Content Structure
- Is the content organized the same way?
- Are sections in the correct order?
- Is the information hierarchy correct?
- Are stories/posts displayed correctly?

## DIFFERENCES FOUND

List any differences in this format:

**P1 - Critical (Breaks Functionality):**
- [Missing features that prevent core functionality]

**P2 - High (Layout Problems):**
- [Incorrect positioning, spacing, or sizing]

**P3 - Medium (Polish):**
- [Minor layout issues, missing polish]

**P4 - Low (Nice to Have):**
- [Very minor issues]

## FUNCTIONALITY SCORE

Rate the functionality match: __/100

Scoring guide:
- 95-100: Excellent match
- 85-94: Good match, minor issues
- 70-84: Acceptable, some issues
- Below 70: Needs significant work

## RECOMMENDATIONS

Provide specific, actionable recommendations to fix each issue.
Format: "Fix [component] by [specific action]"

REMEMBER: DO NOT mention colors, color matching, or hex codes. Focus ONLY on functionality and layout."""

    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/png;base64,{figma_base64}",
                                "detail": "high"
                            }
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/png;base64,{flutter_base64}",
                                "detail": "high"
                            }
                        }
                    ]
                }
            ],
            max_tokens=2500
        )
        
        analysis = response.choices[0].message.content
        
        print("✅ Analysis complete!")
        print("")
        
        return analysis
        
    except Exception as e:
        print(f"❌ Error during analysis: {e}")
        return None

def save_report(analysis, figma_path, flutter_path):
    """Save analysis report to file"""
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"FUNCTIONALITY_VERIFICATION_REPORT_{timestamp}.md"
    
    report = f"""# FUNCTIONALITY VERIFICATION REPORT

**Date:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}  
**Focus:** Functionality & Layout (NOT colors)  
**Method:** GPT-4 Vision API Comparison  
**Figma:** {figma_path}  
**Flutter:** {flutter_path}

---

## 📊 ANALYSIS RESULTS

{analysis}

---

## 📝 NOTES

- This analysis focuses on FUNCTIONALITY and LAYOUT only
- Colors are NOT analyzed (already manually extracted and correct)
- Priority levels: P1 (Critical) → P2 (High) → P3 (Medium) → P4 (Low)
- Automated verification using Selenium screenshot capture

---

## 🚀 NEXT STEPS

1. Review the differences found
2. Prioritize fixes (P1 first, then P2, P3, P4)
3. Implement fixes in Flutter code
4. Re-run verification: `python automated_verification.py`
5. Repeat until functionality score is 95%+

---

**Generated by:** automated_verification.py  
**Model:** GPT-4 Vision (gpt-4o)  
**Automation:** Full (app start + screenshot + analysis)
"""
    
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"📄 Report saved: {filename}")
    print("")
    
    return filename

def main():
    """Main function"""
    
    print("")
    print("=" * 70)
    print("🤖 AUTOMATED FUNCTIONALITY VERIFICATION - Phase 5")
    print("=" * 70)
    print("")
    
    # Load API key
    api_key = load_api_key()
    if not api_key:
        print("❌ ERROR: OpenAI API key not found")
        print("   Create .openai_key file with your API key")
        sys.exit(1)
    
    print("✅ API key loaded")
    print("")
    
    # Check Figma screenshot
    figma_path = "figma_home.png"
    if not os.path.exists(figma_path):
        print(f"❌ ERROR: {figma_path} not found")
        print("   Please export the Figma design as figma_home.png")
        sys.exit(1)
    
    print(f"✅ Figma screenshot found: {figma_path}")
    print("")
    
    # Check if app is already running
    flutter_process = None
    if check_app_running():
        print("✅ Flutter app already running on http://localhost:8080")
        print("")
    else:
        # Check if Flutter is available
        if not check_flutter_available():
            print("❌ ERROR: Flutter not found")
            print("   Please ensure Flutter is in your PATH")
            print("   Or start the app manually: flutter run -d chrome --web-port=8080")
            sys.exit(1)
        
        # Start Flutter app
        flutter_process = start_flutter_app()
        if not flutter_process:
            print("❌ Failed to start Flutter app")
            sys.exit(1)
    
    # Capture screenshot
    flutter_path = capture_screenshot_selenium()
    if not flutter_path:
        print("❌ Failed to capture screenshot")
        if flutter_process:
            flutter_process.kill()
        sys.exit(1)
    
    # Analyze functionality
    analysis = analyze_functionality(figma_path, flutter_path, api_key)
    
    if not analysis:
        print("❌ Analysis failed")
        if flutter_process:
            flutter_process.kill()
        sys.exit(1)
    
    # Save report
    report_file = save_report(analysis, figma_path, flutter_path)
    
    # Print summary
    print("=" * 70)
    print("✅ AUTOMATED VERIFICATION COMPLETE!")
    print("=" * 70)
    print("")
    print(f"📄 Report: {report_file}")
    print(f"📸 Screenshot: {flutter_path}")
    print("")
    print("Next steps:")
    print("  1. Review the report")
    print("  2. Implement fixes for P1 and P2 issues")
    print("  3. Re-run: python automated_verification.py")
    print("")
    
    # Keep app running or kill it
    if flutter_process:
        print("Flutter app is still running on http://localhost:8080")
        print("Press Ctrl+C to stop it")
        try:
            flutter_process.wait()
        except KeyboardInterrupt:
            print("\n🛑 Stopping Flutter app...")
            flutter_process.kill()

if __name__ == "__main__":
    main()

