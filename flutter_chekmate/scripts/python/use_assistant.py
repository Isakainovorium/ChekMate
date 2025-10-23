#!/usr/bin/env python3
"""
Use OpenAI Assistant to achieve 5-star Figma quality
"""

import os
import sys
import time
import base64
from openai import OpenAI

def load_api_key():
    """Load OpenAI API key"""
    key_file = ".openai_key"
    if os.path.exists(key_file):
        with open(key_file, 'r') as f:
            return f.read().strip()
    return os.getenv('OPENAI_API_KEY')

def load_assistant_config():
    """Load assistant configuration"""
    config_file = "../../config/.assistant_config"
    if not os.path.exists(config_file):
        print("❌ ERROR: Assistant not configured!")
        print("   Run: python create_openai_assistant.py")
        sys.exit(1)
    
    config = {}
    with open(config_file, 'r') as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                config[key] = value
    
    return config

def upload_image(client, image_path):
    """Upload image to OpenAI"""
    print(f"📤 Uploading image: {image_path}")
    
    with open(image_path, 'rb') as f:
        file = client.files.create(
            file=f,
            purpose='vision'
        )
    
    print(f"✅ Image uploaded: {file.id}")
    return file.id

def send_message(client, thread_id, message, image_files=None):
    """Send message to assistant"""
    
    content = [{"type": "text", "text": message}]
    
    # Add images if provided
    if image_files:
        for file_id in image_files:
            content.append({
                "type": "image_file",
                "image_file": {"file_id": file_id}
            })
    
    message = client.beta.threads.messages.create(
        thread_id=thread_id,
        role="user",
        content=content
    )
    
    return message

def run_assistant(client, thread_id, assistant_id):
    """Run the assistant and wait for completion"""
    
    print("\n🤖 Running assistant...")
    
    run = client.beta.threads.runs.create(
        thread_id=thread_id,
        assistant_id=assistant_id
    )
    
    # Wait for completion
    while run.status in ['queued', 'in_progress']:
        time.sleep(2)
        run = client.beta.threads.runs.retrieve(
            thread_id=thread_id,
            run_id=run.id
        )
        print(f"   Status: {run.status}...")
    
    if run.status == 'completed':
        print("✅ Assistant completed!")
        return True
    else:
        print(f"❌ Assistant failed: {run.status}")
        if run.last_error:
            print(f"   Error: {run.last_error}")
        return False

def get_messages(client, thread_id):
    """Get messages from thread"""
    
    messages = client.beta.threads.messages.list(
        thread_id=thread_id,
        order='asc'
    )
    
    return messages.data

def display_response(messages):
    """Display assistant's response"""
    
    print("\n" + "="*70)
    print("🤖 ASSISTANT RESPONSE:")
    print("="*70 + "\n")
    
    # Get the last assistant message
    for message in reversed(messages):
        if message.role == 'assistant':
            for content in message.content:
                if content.type == 'text':
                    print(content.text.value)
                    print()
            break

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Use OpenAI Assistant for 5-star quality')
    parser.add_argument('--figma', default='figma_home.png', help='Figma screenshot')
    parser.add_argument('--flutter', default='live_screenshot_1760123343.png', help='Flutter screenshot')
    parser.add_argument('--message', help='Custom message to assistant')
    
    args = parser.parse_args()
    
    print("\n" + "="*70)
    print("🤖 OPENAI ASSISTANT - 5-Star Quality System")
    print("="*70 + "\n")
    
    # Load API key
    api_key = load_api_key()
    if not api_key:
        print("❌ ERROR: OpenAI API key not found!")
        sys.exit(1)
    
    # Load configuration
    config = load_assistant_config()
    assistant_id = config['ASSISTANT_ID']
    thread_id = config['THREAD_ID']
    
    print(f"✅ Assistant: {assistant_id}")
    print(f"✅ Thread: {thread_id}")
    print()
    
    # Create client
    client = OpenAI(api_key=api_key)
    
    # Upload images
    image_files = []
    
    if os.path.exists(args.figma):
        figma_file = upload_image(client, args.figma)
        image_files.append(figma_file)
    else:
        print(f"⚠️  Figma screenshot not found: {args.figma}")
    
    if os.path.exists(args.flutter):
        flutter_file = upload_image(client, args.flutter)
        image_files.append(flutter_file)
    else:
        print(f"⚠️  Flutter screenshot not found: {args.flutter}")
    
    # Create message
    if args.message:
        message_text = args.message
    else:
        message_text = f"""Analyze these screenshots and achieve 5-star Figma quality:

1. First image: Figma design (expected)
2. Second image: Flutter app (current)

TASK:
1. Analyze both images in detail
2. Extract exact specifications from Figma:
   - Colors (hex codes)
   - Spacing (pixel values)
   - Typography (fonts, sizes, weights)
   - Component styles

3. Compare to Flutter app and identify ALL differences

4. Generate complete Dart code fixes for:
   - lib/core/theme/app_colors.dart
   - lib/core/theme/app_theme.dart
   - lib/core/theme/app_spacing.dart
   - Any other files needed

5. Provide:
   - Exact code to copy/paste
   - Verification checklist
   - Expected results

GOAL: Achieve pixel-perfect match to Figma design (5-star quality)

Be thorough and precise!"""
    
    print("💬 Sending message to assistant...")
    print()
    
    # Send message
    send_message(client, thread_id, message_text, image_files)
    
    # Run assistant
    success = run_assistant(client, thread_id, assistant_id)
    
    if success:
        # Get and display response
        messages = get_messages(client, thread_id)
        display_response(messages)
        
        print("="*70)
        print("✅ ASSISTANT ANALYSIS COMPLETE!")
        print("="*70 + "\n")
        
        print("📋 NEXT STEPS:")
        print("   1. Review the assistant's analysis above")
        print("   2. Copy the code fixes provided")
        print("   3. Apply them to your Flutter files")
        print("   4. Test and verify")
        print("   5. Run again if needed for iteration")
        print()
        
        print("💰 COST: ~$0.50 for this analysis")
        print("⭐ QUALITY: Aiming for 5-star Figma match")
        print()
    else:
        print("❌ Assistant failed to complete")
        sys.exit(1)

if __name__ == '__main__':
    main()

