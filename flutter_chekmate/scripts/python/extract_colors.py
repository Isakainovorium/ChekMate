#!/usr/bin/env python3
"""
Color Palette Extractor for ChekMate
Extracts exact hex color codes from the brand palette image
"""

import sys
from PIL import Image
from collections import Counter
import colorsys

def rgb_to_hex(rgb):
    """Convert RGB tuple to hex color code"""
    return '#{:02x}{:02x}{:02x}'.format(rgb[0], rgb[1], rgb[2])

def get_color_name(rgb):
    """Get a descriptive name for the color"""
    r, g, b = rgb
    h, s, v = colorsys.rgb_to_hsv(r/255, g/255, b/255)
    
    # Convert to degrees
    h = h * 360
    
    # Determine color name based on HSV
    if v < 0.2:
        return "Black/Dark Gray"
    elif s < 0.1:
        if v > 0.9:
            return "White"
        elif v > 0.5:
            return "Light Gray"
        else:
            return "Gray"
    elif h < 30:
        return "Red/Orange"
    elif h < 60:
        if s > 0.5 and v > 0.7:
            return "Golden/Amber"
        else:
            return "Yellow/Gold"
    elif h < 90:
        return "Yellow"
    elif h < 150:
        return "Green"
    elif h < 210:
        return "Cyan/Blue"
    elif h < 270:
        if v < 0.5:
            return "Navy Blue"
        else:
            return "Blue"
    elif h < 330:
        return "Purple/Magenta"
    else:
        return "Red/Pink"

def extract_colors(image_path, num_colors=10):
    """Extract the most common colors from an image"""
    try:
        # Open image
        img = Image.open(image_path)

        # Convert to RGB if necessary
        if img.mode != 'RGB':
            img = img.convert('RGB')

        # Don't resize - keep original size for better color detection
        # img = img.resize((150, 150))

        # Get all pixels
        pixels = list(img.getdata())

        # Count color frequencies
        color_counts = Counter(pixels)

        # Get most common colors
        most_common = color_counts.most_common(num_colors * 5)

        # Filter out near-white colors (likely background)
        filtered_colors = []
        for color, count in most_common:
            r, g, b = color
            # Skip pure white and very light colors
            if r > 245 and g > 245 and b > 245:
                continue
            # Keep dark colors (including navy blue)
            # Only skip pure black
            if r < 5 and g < 5 and b < 5:
                continue

            filtered_colors.append((color, count))

            if len(filtered_colors) >= num_colors:
                break

        return filtered_colors

    except Exception as e:
        print(f"Error processing image: {e}")
        return []

def cluster_similar_colors(colors, threshold=30):
    """Group similar colors together"""
    clusters = []
    
    for color, count in colors:
        # Check if this color is similar to any existing cluster
        found_cluster = False
        for cluster in clusters:
            cluster_color = cluster[0][0]
            # Calculate color distance
            distance = sum((a - b) ** 2 for a, b in zip(color, cluster_color)) ** 0.5
            
            if distance < threshold:
                cluster.append((color, count))
                found_cluster = True
                break
        
        if not found_cluster:
            clusters.append([(color, count)])
    
    # Get representative color from each cluster (most common)
    representative_colors = []
    for cluster in clusters:
        # Sort by count and get the most common
        cluster.sort(key=lambda x: x[1], reverse=True)
        representative_colors.append(cluster[0])
    
    return representative_colors

def main():
    if len(sys.argv) < 2:
        print("Usage: python extract_colors.py <image_path>")
        sys.exit(1)
    
    image_path = sys.argv[1]
    
    print("=" * 60)
    print("🎨 ChekMate Color Palette Extractor")
    print("=" * 60)
    print(f"\nAnalyzing image: {image_path}\n")
    
    # Extract colors
    colors = extract_colors(image_path, num_colors=15)
    
    if not colors:
        print("❌ Failed to extract colors from image")
        sys.exit(1)
    
    # Cluster similar colors
    clustered = cluster_similar_colors(colors, threshold=40)
    
    # Sort by count (most common first)
    clustered.sort(key=lambda x: x[1], reverse=True)
    
    print("📊 Extracted Color Palette:\n")
    print("-" * 60)
    
    for i, (color, count) in enumerate(clustered[:8], 1):
        hex_code = rgb_to_hex(color)
        color_name = get_color_name(color)
        percentage = (count / sum(c[1] for c in colors)) * 100
        
        print(f"{i}. {color_name:20} | {hex_code:8} | RGB{color} | {percentage:5.1f}%")
    
    print("-" * 60)
    
    # Generate Flutter color constants
    print("\n" + "=" * 60)
    print("🎯 Flutter Color Constants (app_colors.dart):")
    print("=" * 60)
    print()
    
    color_names_map = {
        "Golden/Amber": "primary",
        "Yellow/Gold": "secondary", 
        "Navy Blue": "navyBlue",
        "Red/Orange": "accent",
        "Yellow": "yellow",
        "Blue": "blue",
        "Cyan/Blue": "lightBlue"
    }
    
    for i, (color, count) in enumerate(clustered[:8], 1):
        hex_code = rgb_to_hex(color)
        color_name = get_color_name(color)
        
        # Convert to Flutter format (0xFFRRGGBB)
        flutter_hex = f"0xFF{hex_code[1:]}"
        
        # Get variable name
        var_name = color_names_map.get(color_name, f"color{i}")
        
        print(f"static const Color {var_name} = Color({flutter_hex}); // {color_name}")
    
    print("\n" + "=" * 60)
    print("✅ Color extraction complete!")
    print("=" * 60)

if __name__ == "__main__":
    main()

