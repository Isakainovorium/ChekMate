#!/usr/bin/env python3
"""
Functionality Verification Script
Compares Flutter app with Figma design focusing on FUNCTIONALITY (not colors)
"""

import os
import sys
import base64
import requests
from datetime import datetime
from openai import OpenAI

def load_api_key():
    """Load OpenAI API key"""
    key_file = ".openai_key"
    if os.path.exists(key_file):
        with open(key_file, 'r') as f:
            content = f.read().strip()
            # Get first line if multiple lines
            return content.split('\n')[0].strip()
    return os.getenv('OPENAI_API_KEY')

def encode_image(image_path):
    """Encode image to base64"""
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def check_app_running():
    """Check if Flutter app is running"""
    try:
        response = requests.get("http://localhost:8080", timeout=2)
        return True
    except:
        return False

def capture_screenshot():
    """Capture screenshot of running app"""
    print("📸 Capturing Flutter app screenshot...")
    
    # Use Selenium or Playwright to capture screenshot
    # For now, we'll use the existing live_screenshot files
    import glob
    screenshots = glob.glob("live_screenshot_*.png")
    if screenshots:
        latest = max(screenshots, key=os.path.getctime)
        print(f"✅ Using existing screenshot: {latest}")
        return latest
    
    print("⚠️  No screenshot found. Please capture manually.")
    return None

def analyze_functionality(figma_path, flutter_path, api_key):
    """Analyze functionality using OpenAI Vision API"""
    
    print("\n🤖 Analyzing functionality with GPT-4 Vision...")
    print("   Focus: FUNCTIONALITY (not colors)")
    print("")
    
    client = OpenAI(api_key=api_key)
    
    # Encode images
    figma_base64 = encode_image(figma_path)
    flutter_base64 = encode_image(flutter_path)
    
    # Create the prompt
    prompt = """You are a functionality verification expert. Compare these two images:
1. Figma Design (reference)
2. Flutter App (implementation)

IMPORTANT: Focus ONLY on FUNCTIONALITY and LAYOUT. DO NOT analyze colors - they are already correct.

Analyze and report on:

## FUNCTIONALITY VERIFICATION

### 1. UI Components Present
- Are all buttons from Figma present in Flutter?
- Are all input fields present?
- Are all navigation elements present?
- Are all icons present?
- Are all text elements present?

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

### 4. Interactive Elements
- Are all clickable elements visible?
- Are buttons properly styled (shape, size)?
- Are form fields properly styled?
- Are interactive states indicated?

### 5. Content Structure
- Is the content organized the same way?
- Are sections in the correct order?
- Is the information hierarchy correct?

## DIFFERENCES FOUND

List any differences in this format:

**P1 - Critical (Breaks Functionality):**
- [List critical issues]

**P2 - High (Layout Problems):**
- [List layout issues]

**P3 - Medium (Polish):**
- [List medium issues]

**P4 - Low (Nice to Have):**
- [List minor issues]

## FUNCTIONALITY SCORE

Rate the functionality match: __/100

## RECOMMENDATIONS

Provide specific, actionable recommendations to fix the issues.

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
            max_tokens=2000
        )
        
        analysis = response.choices[0].message.content
        
        print("✅ Analysis complete!")
        print("")
        
        return analysis
        
    except Exception as e:
        print(f"❌ Error during analysis: {e}")
        return None

def save_report(analysis):
    """Save analysis report to file"""
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"FUNCTIONALITY_VERIFICATION_REPORT_{timestamp}.md"
    
    report = f"""# FUNCTIONALITY VERIFICATION REPORT

**Date:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}  
**Focus:** Functionality & Layout (NOT colors)  
**Method:** GPT-4 Vision API Comparison

---

## 📊 ANALYSIS RESULTS

{analysis}

---

## 📝 NOTES

- This analysis focuses on FUNCTIONALITY and LAYOUT only
- Colors are NOT analyzed (already manually extracted and correct)
- Priority levels: P1 (Critical) → P2 (High) → P3 (Medium) → P4 (Low)

---

## 🚀 NEXT STEPS

1. Review the differences found
2. Prioritize fixes (P1 first)
3. Implement fixes
4. Re-run verification
5. Repeat until functionality score is 95%+

---

**Generated by:** verify_functionality.py  
**Model:** GPT-4 Vision (gpt-4o)
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
    print("🎯 FUNCTIONALITY VERIFICATION - Phase 5")
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
    
    # Check if app is running
    if not check_app_running():
        print("⚠️  WARNING: Flutter app not running on http://localhost:8080")
        print("   Please start the app:")
        print("   flutter run -d chrome --web-port=8080")
        print("")
    else:
        print("✅ Flutter app is running")
        print("")
    
    # Get Flutter screenshot
    flutter_path = capture_screenshot()
    if not flutter_path:
        print("❌ ERROR: No Flutter screenshot available")
        print("   Please capture a screenshot and save as live_screenshot_*.png")
        sys.exit(1)
    
    print(f"✅ Flutter screenshot: {flutter_path}")
    print("")
    
    # Analyze functionality
    analysis = analyze_functionality(figma_path, flutter_path, api_key)
    
    if not analysis:
        print("❌ Analysis failed")
        sys.exit(1)
    
    # Save report
    report_file = save_report(analysis)
    
    # Print summary
    print("=" * 70)
    print("✅ VERIFICATION COMPLETE!")
    print("=" * 70)
    print("")
    print(f"📄 Report: {report_file}")
    print("")
    print("Next steps:")
    print("  1. Review the report")
    print("  2. Implement fixes for P1 issues")
    print("  3. Re-run verification")
    print("")

if __name__ == "__main__":
    main()

