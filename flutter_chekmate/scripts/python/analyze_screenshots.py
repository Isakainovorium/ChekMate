"""
Analyze the captured screenshots to see what's actually displayed
"""
from PIL import Image
import os

def analyze_screenshot(filepath):
    """Analyze a single screenshot"""
    img = Image.open(filepath)
    
    # Get basic info
    width, height = img.size
    mode = img.mode
    
    # Check if image is mostly white (blank)
    pixels = img.load()
    white_count = 0
    total_pixels = width * height
    sample_size = min(10000, total_pixels)  # Sample 10k pixels
    
    for i in range(0, width, max(1, width // 100)):
        for j in range(0, height, max(1, height // 100)):
            try:
                pixel = pixels[i, j]
                if mode == 'RGB':
                    if pixel[0] > 240 and pixel[1] > 240 and pixel[2] > 240:
                        white_count += 1
                elif mode == 'RGBA':
                    if pixel[0] > 240 and pixel[1] > 240 and pixel[2] > 240:
                        white_count += 1
            except:
                pass
    
    # Calculate percentage
    sampled = (width // max(1, width // 100)) * (height // max(1, height // 100))
    white_percentage = (white_count / sampled * 100) if sampled > 0 else 0
    
    # Check for specific colors (ChekMate primary color is purple/pink)
    has_color = white_percentage < 90
    
    return {
        'size': f'{width}x{height}',
        'mode': mode,
        'white_percentage': round(white_percentage, 1),
        'has_content': has_color,
        'file_size': os.path.getsize(filepath)
    }

def main():
    screenshots_dir = 'test_screenshots'
    
    print("=" * 80)
    print("SCREENSHOT ANALYSIS REPORT")
    print("=" * 80)
    print()
    
    files = sorted([f for f in os.listdir(screenshots_dir) if f.endswith('.png')])
    
    for filename in files:
        filepath = os.path.join(screenshots_dir, filename)
        analysis = analyze_screenshot(filepath)
        
        print(f"📸 {filename}")
        print(f"   Size: {analysis['size']}")
        print(f"   File: {analysis['file_size']:,} bytes")
        print(f"   White: {analysis['white_percentage']}%")
        print(f"   Content: {'✅ YES' if analysis['has_content'] else '❌ BLANK/WHITE'}")
        print()
    
    print("=" * 80)
    print()
    
    # Summary
    total = len(files)
    with_content = sum(1 for f in files if analyze_screenshot(os.path.join(screenshots_dir, f))['has_content'])
    
    print(f"SUMMARY:")
    print(f"  Total screenshots: {total}")
    print(f"  With content: {with_content}")
    print(f"  Blank/white: {total - with_content}")
    print()
    
    if with_content == 0:
        print("⚠️  WARNING: All screenshots appear to be blank!")
        print("   This means the app may not have loaded properly.")
        print("   Check if the Flutter app is actually running on http://localhost:60366")
    elif with_content < total:
        print(f"⚠️  WARNING: {total - with_content} screenshot(s) appear blank!")
    else:
        print("✅ All screenshots contain content!")

if __name__ == '__main__':
    main()

