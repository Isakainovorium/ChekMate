#!/usr/bin/env python3
"""
Use OpenAI Assistant for FUNCTIONALITY matching (not colors)
Focus: Make the app FUNCTION like the Figma prototype
"""

import os
import sys
import time
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
    print(f"📤 Uploading: {image_path}")
    
    with open(image_path, 'rb') as f:
        file = client.files.create(
            file=f,
            purpose='vision'
        )
    
    print(f"✅ Uploaded: {file.id}")
    return file.id

def send_message(client, thread_id, message, image_files=None):
    """Send message to assistant"""
    
    content = [{"type": "text", "text": message}]
    
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
    
    print("\n🤖 Assistant analyzing functionality...")
    
    run = client.beta.threads.runs.create(
        thread_id=thread_id,
        assistant_id=assistant_id
    )
    
    while run.status in ['queued', 'in_progress']:
        time.sleep(2)
        run = client.beta.threads.runs.retrieve(
            thread_id=thread_id,
            run_id=run.id
        )
        print(f"   Status: {run.status}...")
    
    if run.status == 'completed':
        print("✅ Analysis complete!")
        return True
    else:
        print(f"❌ Failed: {run.status}")
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
    print("🤖 FUNCTIONALITY ANALYSIS:")
    print("="*70 + "\n")
    
    for message in reversed(messages):
        if message.role == 'assistant':
            for content in message.content:
                if content.type == 'text':
                    print(content.text.value)
                    print()
            break

def save_analysis(messages):
    """Save analysis to file"""
    
    for message in reversed(messages):
        if message.role == 'assistant':
            for content in message.content:
                if content.type == 'text':
                    with open('FUNCTIONALITY_ANALYSIS.md', 'w', encoding='utf-8') as f:
                        f.write("# Functionality Analysis Report\n\n")
                        f.write(content.text.value)
                    print("💾 Analysis saved to: FUNCTIONALITY_ANALYSIS.md")
            break

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Analyze Figma functionality')
    parser.add_argument('--figma', default='figma_home.png', help='Figma screenshot')
    parser.add_argument('--flutter', default='live_screenshot_1760123343.png', help='Flutter screenshot')
    
    args = parser.parse_args()
    
    print("\n" + "="*70)
    print("🎯 FUNCTIONALITY ANALYSIS - Make App Work Like Figma")
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
    
    if os.path.exists(args.flutter):
        flutter_file = upload_image(client, args.flutter)
        image_files.append(flutter_file)
    
    # Create functionality-focused message
    message_text = f"""IMPORTANT: Ignore colors! We already have the correct brand colors:
- Golden: #FEBD59
- Navy Blue: #2D497B

FOCUS ON FUNCTIONALITY ONLY!

Analyze these screenshots:
1. First image: Figma design (expected functionality)
2. Second image: Flutter app (current functionality)

YOUR TASK - ANALYZE FUNCTIONALITY:

1. **Interactive Elements:**
   - What buttons/tabs/cards are clickable in Figma?
   - Are they implemented in Flutter?
   - Do they work correctly?

2. **Navigation Flow:**
   - What screens can you navigate to?
   - What's the navigation pattern? (tabs, drawer, etc.)
   - Is navigation implemented in Flutter?

3. **Features & Interactions:**
   - What features are visible? (feed, stories, profiles, etc.)
   - What user interactions are possible? (like, comment, swipe, etc.)
   - Are these features implemented?

4. **Data & State:**
   - What data is displayed? (posts, users, dates, etc.)
   - Is this data dynamic or static?
   - Is state management needed?

5. **Backend Requirements:**
   - What needs Firebase? (auth, database, storage, etc.)
   - What API calls are needed?
   - What real-time features exist?

GENERATE CODE FOR:
- Missing features (not colors!)
- Navigation implementation
- Interactive elements
- State management
- Firebase integration
- API calls

PROVIDE:
1. List of ALL features in Figma
2. List of MISSING features in Flutter
3. Complete Dart code to implement missing features
4. Firebase setup instructions
5. Testing checklist

GOAL: Make the app FUNCTION like Figma (not just look like it)

Be thorough and focus on FUNCTIONALITY!"""
    
    print("💬 Sending functionality analysis request...")
    print()
    
    # Send message
    send_message(client, thread_id, message_text, image_files)
    
    # Run assistant
    success = run_assistant(client, thread_id, assistant_id)
    
    if success:
        # Get and display response
        messages = get_messages(client, thread_id)
        display_response(messages)
        
        # Save analysis
        save_analysis(messages)
        
        print("="*70)
        print("✅ FUNCTIONALITY ANALYSIS COMPLETE!")
        print("="*70 + "\n")
        
        print("📋 NEXT STEPS:")
        print("   1. Review FUNCTIONALITY_ANALYSIS.md")
        print("   2. Implement missing features")
        print("   3. Add Firebase integration")
        print("   4. Test functionality")
        print("   5. Iterate until app works like Figma")
        print()
        
        print("💰 COST: ~$0.50")
        print("🎯 FOCUS: Functionality (not colors)")
        print()
    else:
        print("❌ Analysis failed")
        sys.exit(1)

if __name__ == '__main__':
    main()

