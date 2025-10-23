#!/usr/bin/env python3
"""
Screenshot Color Analyzer
Analyzes actual colors in screenshots to verify they match expected brand colors
"""

import sys
from PIL import Image
from collections import Counter
import colorsys

def rgb_to_hex(rgb):
    """Convert RGB tuple to hex string"""
    return '#{:02x}{:02x}{:02x}'.format(rgb[0], rgb[1], rgb[2])

def hex_to_rgb(hex_color):
    """Convert hex string to RGB tuple"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def color_distance(color1, color2):
    """Calculate Euclidean distance between two RGB colors"""
    return sum((a - b) ** 2 for a, b in zip(color1, color2)) ** 0.5

def is_neutral(rgb, threshold=30):
    """Check if color is neutral (grayscale)"""
    r, g, b = rgb
    return max(r, g, b) - min(r, g, b) < threshold

def analyze_screenshot(image_path, expected_colors):
    """
    Analyze screenshot and find colors matching expected palette
    
    Args:
        image_path: Path to screenshot
        expected_colors: Dict of {name: hex_color}
    
    Returns:
        Dict with analysis results
    """
    print(f"\n{'='*70}")
    print(f"🔍 ANALYZING SCREENSHOT: {image_path}")
    print(f"{'='*70}\n")
    
    try:
        img = Image.open(image_path)
        img = img.convert('RGB')
        
        # Get all pixels
        pixels = list(img.getdata())
        total_pixels = len(pixels)
        
        print(f"📊 Image size: {img.size[0]}x{img.size[1]} ({total_pixels:,} pixels)\n")
        
        # Filter out white/black/neutral colors
        colored_pixels = [
            p for p in pixels 
            if not (
                # Skip pure white
                (p[0] > 240 and p[1] > 240 and p[2] > 240) or
                # Skip pure black
                (p[0] < 15 and p[1] < 15 and p[2] < 15) or
                # Skip neutral grays
                is_neutral(p, threshold=20)
            )
        ]
        
        print(f"🎨 Colored pixels (non-neutral): {len(colored_pixels):,} ({len(colored_pixels)/total_pixels*100:.1f}%)\n")
        
        # Convert expected colors to RGB
        expected_rgb = {name: hex_to_rgb(hex_color) for name, hex_color in expected_colors.items()}
        
        # Find pixels matching each expected color (within tolerance)
        tolerance = 30  # Color distance tolerance
        matches = {name: [] for name in expected_colors.keys()}
        
        for pixel in colored_pixels:
            for name, expected in expected_rgb.items():
                if color_distance(pixel, expected) < tolerance:
                    matches[name].append(pixel)
                    break
        
        # Calculate percentages
        results = {}
        print("🎯 EXPECTED COLOR MATCHES:\n")
        print(f"{'Color Name':<20} {'Expected':<10} {'Found':<10} {'% of Image':<12} {'Status'}")
        print("-" * 70)
        
        for name, hex_color in expected_colors.items():
            count = len(matches[name])
            percentage = (count / total_pixels) * 100
            status = "✅ FOUND" if count > 100 else "❌ NOT FOUND"
            
            print(f"{name:<20} {hex_color:<10} {count:>8,}  {percentage:>10.2f}%  {status}")
            
            results[name] = {
                'expected_hex': hex_color,
                'pixel_count': count,
                'percentage': percentage,
                'found': count > 100
            }
        
        # Find most common non-expected colors
        print(f"\n{'='*70}")
        print("🔍 TOP 10 UNEXPECTED COLORS (not in brand palette):\n")
        print(f"{'Hex Color':<12} {'RGB':<20} {'Count':<12} {'% of Image'}")
        print("-" * 70)
        
        # Get colors that don't match expected palette
        unexpected_pixels = []
        for pixel in colored_pixels:
            is_expected = False
            for expected in expected_rgb.values():
                if color_distance(pixel, expected) < tolerance:
                    is_expected = True
                    break
            if not is_expected:
                unexpected_pixels.append(pixel)
        
        # Count unexpected colors
        color_counts = Counter(unexpected_pixels)
        
        for color, count in color_counts.most_common(10):
            hex_color = rgb_to_hex(color)
            percentage = (count / total_pixels) * 100
            print(f"{hex_color:<12} {str(color):<20} {count:>10,}  {percentage:>10.2f}%")
        
        # Overall assessment
        print(f"\n{'='*70}")
        print("📊 OVERALL ASSESSMENT:\n")
        
        total_expected_pixels = sum(len(matches[name]) for name in expected_colors.keys())
        expected_percentage = (total_expected_pixels / total_pixels) * 100
        
        print(f"Total pixels using brand colors: {total_expected_pixels:,} ({expected_percentage:.1f}%)")
        print(f"Total unexpected colored pixels: {len(unexpected_pixels):,} ({len(unexpected_pixels)/total_pixels*100:.1f}%)")
        
        if expected_percentage > 5:
            print("\n✅ VERDICT: Brand colors ARE being used in the app")
        else:
            print("\n❌ VERDICT: Brand colors NOT found - colors may be wrong!")
        
        print(f"{'='*70}\n")
        
        return results
        
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return None

def main():
    if len(sys.argv) < 2:
        print("Usage: python analyze_screenshot_colors.py <screenshot_path>")
        sys.exit(1)
    
    screenshot_path = sys.argv[1]
    
    # Expected ChekMate brand colors
    expected_colors = {
        'Primary Gold': '#FEBD59',
        'Navy Blue': '#2D497B',
        'Darker Gold': '#DF912F',
        'Light Golden': '#FDD698',
    }
    
    # Also check for WRONG colors (orange/pink)
    wrong_colors = {
        'Orange (WRONG)': '#FF6B35',
        'Pink (WRONG)': '#FF8FA3',
    }
    
    print("\n" + "="*70)
    print("🎨 CHEKMATE SCREENSHOT COLOR ANALYZER")
    print("="*70)
    
    print("\n📋 EXPECTED BRAND COLORS:")
    for name, hex_color in expected_colors.items():
        print(f"  {name:<20} {hex_color}")
    
    print("\n⚠️  WRONG COLORS TO CHECK FOR:")
    for name, hex_color in wrong_colors.items():
        print(f"  {name:<20} {hex_color}")
    
    # Analyze for expected colors
    results = analyze_screenshot(screenshot_path, expected_colors)
    
    # Check for wrong colors
    print("\n" + "="*70)
    print("⚠️  CHECKING FOR WRONG COLORS (Orange/Pink):")
    print("="*70)
    
    wrong_results = analyze_screenshot(screenshot_path, wrong_colors)
    
    # Final verdict
    print("\n" + "="*70)
    print("🎯 FINAL VERDICT:")
    print("="*70 + "\n")
    
    if results:
        found_correct = any(r['found'] for r in results.values())
        found_wrong = wrong_results and any(r['found'] for r in wrong_results.values())
        
        if found_correct and not found_wrong:
            print("✅ SUCCESS: Correct brand colors found, no wrong colors detected!")
        elif found_correct and found_wrong:
            print("⚠️  WARNING: Both correct AND wrong colors found - partial fix?")
        elif not found_correct and found_wrong:
            print("❌ FAILURE: Wrong colors (orange/pink) still being used!")
        else:
            print("❓ UNCLEAR: Neither correct nor wrong colors found in significant amounts")
            print("   This might mean the screenshot is mostly neutral colors (white/gray/black)")

if __name__ == '__main__':
    main()

