#!/usr/bin/env python3
"""
Figma to Flutter Analyzer - Uses OpenAI GPT-4 Vision to compare Figma design to Flutter app
Cost-efficient: Uses gpt-4o-mini for initial analysis, gpt-4o for detailed comparison
"""

import os
import sys
import base64
import json
from openai import OpenAI

def load_api_key():
    """Load OpenAI API key from .openai_key file"""
    key_file = ".openai_key"
    if os.path.exists(key_file):
        with open(key_file, 'r') as f:
            return f.read().strip()
    return os.getenv('OPENAI_API_KEY')

def encode_image(image_path):
    """Encode image to base64"""
    with open(image_path, 'rb') as f:
        return base64.b64encode(f.read()).decode('utf-8')

def analyze_single_image(client, image_path, prompt, model="gpt-4o-mini"):
    """
    Analyze a single image with GPT-4 Vision
    Uses gpt-4o-mini by default for cost efficiency (~15x cheaper than gpt-4o)
    """
    print(f"📸 Analyzing: {image_path}")
    print(f"🤖 Model: {model}")
    
    image_base64 = encode_image(image_path)
    
    response = client.chat.completions.create(
        model=model,
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/png;base64,{image_base64}",
                            "detail": "high"
                        }
                    }
                ]
            }
        ],
        max_tokens=1500
    )
    
    return response.choices[0].message.content

def compare_images(client, figma_path, flutter_path, model="gpt-4o"):
    """
    Compare Figma design to Flutter app using GPT-4 Vision
    Uses gpt-4o for detailed comparison (more accurate)
    """
    print(f"\n🔍 Comparing Figma vs Flutter...")
    print(f"🤖 Model: {model}")
    
    figma_base64 = encode_image(figma_path)
    flutter_base64 = encode_image(flutter_path)
    
    prompt = """You are a UI/UX expert comparing a Figma design to a Flutter implementation.

ANALYZE BOTH IMAGES AND PROVIDE:

1. **COLORS** - Compare exact colors:
   - Expected (Figma): Golden #FEBD59, Navy Blue #2D497B
   - Actual (Flutter): What colors do you see?
   - Match: Yes/No for each color

2. **LAYOUT** - Compare structure:
   - Spacing differences
   - Alignment issues
   - Component positioning

3. **TYPOGRAPHY** - Compare text:
   - Font sizes
   - Font weights
   - Text colors
   - Line heights

4. **COMPONENTS** - Compare UI elements:
   - Buttons (size, style, color)
   - Cards (shadows, borders, spacing)
   - Icons (size, color, style)
   - Navigation (layout, active states)

5. **CRITICAL ISSUES** - List top 5 issues preventing Figma match:
   - Issue #1: [description]
   - Issue #2: [description]
   - etc.

6. **FIX RECOMMENDATIONS** - Specific code changes needed:
   - File to edit
   - Exact change to make
   - Expected result

Be SPECIFIC with hex colors, pixel values, and exact component names."""

    response = client.chat.completions.create(
        model=model,
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
    
    return response.choices[0].message.content

def analyze_figma_design(client, figma_path):
    """Analyze Figma design to extract design specs"""
    prompt = """You are analyzing a Figma design for a dating/social app called ChekMate.

EXTRACT THE FOLLOWING DESIGN SPECIFICATIONS:

1. **COLOR PALETTE**:
   - Primary color (hex code)
   - Secondary color (hex code)
   - Accent colors (hex codes)
   - Text colors (hex codes)
   - Background colors (hex codes)

2. **TYPOGRAPHY**:
   - Heading font (family, size, weight)
   - Body font (family, size, weight)
   - Button text (family, size, weight)
   - Caption text (family, size, weight)

3. **SPACING SYSTEM**:
   - Base unit (e.g., 4px, 8px)
   - Common spacing values
   - Padding patterns
   - Margin patterns

4. **COMPONENT STYLES**:
   - Button style (height, padding, border-radius, colors)
   - Card style (padding, border-radius, shadow, colors)
   - Input style (height, padding, border, colors)
   - Navigation style (height, colors, active states)

5. **LAYOUT**:
   - Screen structure
   - Grid system
   - Component hierarchy

Be SPECIFIC with exact values (hex codes, pixel sizes, etc.)."""

    return analyze_single_image(client, figma_path, prompt, model="gpt-4o-mini")

def analyze_flutter_app(client, flutter_path):
    """Analyze Flutter app to see what's actually rendered"""
    prompt = """You are analyzing a Flutter web app implementation.

DESCRIBE WHAT YOU SEE:

1. **COLORS** (provide hex codes if possible):
   - Primary color used
   - Secondary color used
   - Text colors
   - Background colors
   - Button colors
   - Navigation colors

2. **LAYOUT**:
   - Screen structure
   - Component arrangement
   - Spacing between elements

3. **COMPONENTS VISIBLE**:
   - Buttons (style, color, size)
   - Cards (style, shadow, spacing)
   - Navigation (type, position, style)
   - Text elements (sizes, weights)

4. **ISSUES VISIBLE**:
   - Layout problems
   - Color mismatches
   - Spacing issues
   - Broken components

Be SPECIFIC and DETAILED."""

    return analyze_single_image(client, flutter_path, prompt, model="gpt-4o-mini")

def main():
    print("\n" + "="*70)
    print("🎨 FIGMA TO FLUTTER ANALYZER - AI-Powered Design Comparison")
    print("="*70 + "\n")
    
    # Load API key
    api_key = load_api_key()
    if not api_key:
        print("❌ ERROR: OpenAI API key not found!")
        print("   Please create .openai_key file with your API key")
        sys.exit(1)
    
    client = OpenAI(api_key=api_key)
    
    # Check for images
    import argparse
    parser = argparse.ArgumentParser(description='Compare Figma design to Flutter app')
    parser.add_argument('--figma', help='Path to Figma screenshot')
    parser.add_argument('--flutter', help='Path to Flutter app screenshot')
    parser.add_argument('--mode', choices=['analyze-figma', 'analyze-flutter', 'compare'], 
                        default='compare', help='Analysis mode')
    
    args = parser.parse_args()
    
    if args.mode == 'analyze-figma':
        if not args.figma:
            print("❌ ERROR: --figma path required for analyze-figma mode")
            sys.exit(1)
        
        print("📊 ANALYZING FIGMA DESIGN\n")
        result = analyze_figma_design(client, args.figma)
        print("\n" + "="*70)
        print("📋 FIGMA DESIGN SPECIFICATIONS:")
        print("="*70 + "\n")
        print(result)
        
    elif args.mode == 'analyze-flutter':
        if not args.flutter:
            print("❌ ERROR: --flutter path required for analyze-flutter mode")
            sys.exit(1)
        
        print("📊 ANALYZING FLUTTER APP\n")
        result = analyze_flutter_app(client, args.flutter)
        print("\n" + "="*70)
        print("📋 FLUTTER APP ANALYSIS:")
        print("="*70 + "\n")
        print(result)
        
    elif args.mode == 'compare':
        if not args.figma or not args.flutter:
            print("❌ ERROR: Both --figma and --flutter paths required for compare mode")
            sys.exit(1)
        
        print("📊 STEP 1: Analyzing Figma design...\n")
        figma_analysis = analyze_figma_design(client, args.figma)
        
        print("\n📊 STEP 2: Analyzing Flutter app...\n")
        flutter_analysis = analyze_flutter_app(client, args.flutter)
        
        print("\n📊 STEP 3: Comparing designs...\n")
        comparison = compare_images(client, args.figma, args.flutter)
        
        print("\n" + "="*70)
        print("📋 COMPLETE ANALYSIS REPORT:")
        print("="*70 + "\n")
        
        print("🎨 FIGMA DESIGN SPECS:")
        print("-" * 70)
        print(figma_analysis)
        
        print("\n\n🖥️  FLUTTER APP CURRENT STATE:")
        print("-" * 70)
        print(flutter_analysis)
        
        print("\n\n🔍 COMPARISON & FIX RECOMMENDATIONS:")
        print("-" * 70)
        print(comparison)
        
        # Save report
        report_file = "FIGMA_FLUTTER_COMPARISON_REPORT.md"
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write("# Figma to Flutter Comparison Report\n\n")
            f.write("## 🎨 Figma Design Specifications\n\n")
            f.write(figma_analysis + "\n\n")
            f.write("## 🖥️ Flutter App Current State\n\n")
            f.write(flutter_analysis + "\n\n")
            f.write("## 🔍 Comparison & Fix Recommendations\n\n")
            f.write(comparison + "\n")
        
        print(f"\n\n💾 Report saved to: {report_file}")
    
    print("\n" + "="*70)
    print("✅ ANALYSIS COMPLETE")
    print("="*70 + "\n")

if __name__ == '__main__':
    main()

