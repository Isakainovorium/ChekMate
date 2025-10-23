#!/usr/bin/env python3
"""
Visual Analyzer MCP Tool
Uses AI vision models to analyze screenshots and describe what's visible
"""

import sys
import base64
import json
from pathlib import Path

def encode_image_to_base64(image_path):
    """Encode image to base64 string"""
    with open(image_path, 'rb') as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def analyze_with_anthropic(image_path, api_key=None):
    """
    Analyze screenshot using Anthropic Claude Vision API
    
    Args:
        image_path: Path to screenshot
        api_key: Anthropic API key (optional, will use env var if not provided)
    
    Returns:
        Analysis description
    """
    try:
        import anthropic
        import os
        
        # Get API key
        if not api_key:
            api_key = os.environ.get('ANTHROPIC_API_KEY')
        
        if not api_key:
            return {
                'error': 'No Anthropic API key found. Set ANTHROPIC_API_KEY environment variable.',
                'setup_instructions': [
                    '1. Get API key from: https://console.anthropic.com/',
                    '2. Set environment variable: $env:ANTHROPIC_API_KEY="your-key-here"',
                    '3. Or pass as argument: --api-key YOUR_KEY'
                ]
            }
        
        # Initialize client
        client = anthropic.Anthropic(api_key=api_key)
        
        # Read image
        with open(image_path, 'rb') as image_file:
            image_data = base64.standard_b64encode(image_file.read()).decode('utf-8')
        
        # Determine image type
        image_type = 'image/png' if image_path.endswith('.png') else 'image/jpeg'
        
        # Create message with vision
        message = client.messages.create(
            model="claude-3-5-sonnet-20241022",
            max_tokens=2000,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": image_type,
                                "data": image_data,
                            },
                        },
                        {
                            "type": "text",
                            "text": """Analyze this Flutter web app screenshot and provide a detailed description:

1. **COLORS**: What are the dominant colors? List specific colors you see (describe them like "golden yellow", "navy blue", "orange", "pink", etc.)

2. **LAYOUT**: Describe the layout - what sections are visible? (header, navigation, content, etc.)

3. **COMPONENTS**: What UI components do you see? (buttons, cards, text, images, icons, etc.)

4. **BRANDING**: Does this look like it uses a golden/amber and navy blue color scheme? Or different colors?

5. **COMPARISON TO EXPECTED**: 
   - Expected primary color: Golden/Amber (#FEBD59)
   - Expected secondary color: Navy Blue (#2D497B)
   - Do you see these colors being used prominently?

6. **ISSUES**: Any visual issues, layout problems, or things that look broken?

Be very specific about colors - if you see orange, say "orange". If you see golden/amber, say "golden/amber"."""
                        }
                    ],
                }
            ],
        )
        
        return {
            'success': True,
            'analysis': message.content[0].text,
            'model': 'claude-3-5-sonnet-20241022'
        }
        
    except ImportError:
        return {
            'error': 'Anthropic library not installed',
            'setup_instructions': [
                'Install: pip install anthropic'
            ]
        }
    except Exception as e:
        return {
            'error': str(e)
        }

def analyze_with_openai(image_path, api_key=None):
    """
    Analyze screenshot using OpenAI GPT-4 Vision API
    
    Args:
        image_path: Path to screenshot
        api_key: OpenAI API key (optional, will use env var if not provided)
    
    Returns:
        Analysis description
    """
    try:
        import openai
        import os
        
        # Get API key
        if not api_key:
            api_key = os.environ.get('OPENAI_API_KEY')
        
        if not api_key:
            return {
                'error': 'No OpenAI API key found. Set OPENAI_API_KEY environment variable.',
                'setup_instructions': [
                    '1. Get API key from: https://platform.openai.com/api-keys',
                    '2. Set environment variable: $env:OPENAI_API_KEY="your-key-here"',
                    '3. Or pass as argument: --api-key YOUR_KEY'
                ]
            }
        
        # Initialize client
        client = openai.OpenAI(api_key=api_key)
        
        # Encode image
        image_data = encode_image_to_base64(image_path)
        
        # Create message with vision
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": """Analyze this Flutter web app screenshot and provide a detailed description:

1. **COLORS**: What are the dominant colors? List specific colors you see (describe them like "golden yellow", "navy blue", "orange", "pink", etc.)

2. **LAYOUT**: Describe the layout - what sections are visible? (header, navigation, content, etc.)

3. **COMPONENTS**: What UI components do you see? (buttons, cards, text, images, icons, etc.)

4. **BRANDING**: Does this look like it uses a golden/amber and navy blue color scheme? Or different colors?

5. **COMPARISON TO EXPECTED**: 
   - Expected primary color: Golden/Amber (#FEBD59)
   - Expected secondary color: Navy Blue (#2D497B)
   - Do you see these colors being used prominently?

6. **ISSUES**: Any visual issues, layout problems, or things that look broken?

Be very specific about colors - if you see orange, say "orange". If you see golden/amber, say "golden/amber"."""
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/png;base64,{image_data}"
                            }
                        }
                    ]
                }
            ],
            max_tokens=2000
        )
        
        return {
            'success': True,
            'analysis': response.choices[0].message.content,
            'model': 'gpt-4o'
        }
        
    except ImportError:
        return {
            'error': 'OpenAI library not installed',
            'setup_instructions': [
                'Install: pip install openai'
            ]
        }
    except Exception as e:
        return {
            'error': str(e)
        }

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Analyze screenshot using AI vision')
    parser.add_argument('image_path', help='Path to screenshot')
    parser.add_argument('--provider', choices=['anthropic', 'openai'], default='openai',
                        help='Vision API provider (default: openai)')
    parser.add_argument('--api-key', help='API key (optional, uses env var if not provided)')

    args = parser.parse_args()
    
    print("\n" + "="*70)
    print("👁️  VISUAL ANALYZER - AI Vision Screenshot Analysis")
    print("="*70 + "\n")
    
    print(f"📸 Screenshot: {args.image_path}")
    print(f"🤖 Provider: {args.provider.upper()}\n")
    
    # Check if file exists
    if not Path(args.image_path).exists():
        print(f"❌ ERROR: File not found: {args.image_path}")
        sys.exit(1)
    
    # Analyze based on provider
    if args.provider == 'anthropic':
        result = analyze_with_anthropic(args.image_path, args.api_key)
    else:
        result = analyze_with_openai(args.image_path, args.api_key)
    
    # Display results
    if 'error' in result:
        print(f"❌ ERROR: {result['error']}\n")
        if 'setup_instructions' in result:
            print("📋 SETUP INSTRUCTIONS:")
            for instruction in result['setup_instructions']:
                print(f"   {instruction}")
    else:
        print("="*70)
        print("📊 VISUAL ANALYSIS RESULTS:")
        print("="*70 + "\n")
        print(result['analysis'])
        print("\n" + "="*70)
        print(f"✅ Analysis complete using {result['model']}")
        print("="*70 + "\n")

if __name__ == '__main__':
    main()

