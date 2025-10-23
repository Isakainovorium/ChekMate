#!/usr/bin/env python3
"""
Convert ALL Figma React/TypeScript components to Flutter/Dart
Uses OpenAI Assistant to intelligently convert each component
"""

import os
import sys
import time
from openai import OpenAI
from pathlib import Path

def load_api_key():
    """Load OpenAI API key"""
    key_file = ".openai_key"
    if os.path.exists(key_file):
        with open(key_file, 'r') as f:
            return f.read().strip()
    return os.getenv('OPENAI_API_KEY')

def load_assistant_config():
    """Load assistant configuration"""
    config_file = ".assistant_config"
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

def read_component_file(file_path):
    """Read a React/TypeScript component file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"❌ Error reading {file_path}: {e}")
        return None

def send_conversion_request(client, thread_id, component_name, component_code):
    """Send component conversion request to assistant"""
    
    message_text = f"""Convert this React/TypeScript component to Flutter/Dart:

COMPONENT NAME: {component_name}

REACT/TYPESCRIPT CODE:
```typescript
{component_code}
```

CONVERSION REQUIREMENTS:

1. **Use Our Brand Colors:**
   - Golden: #FEBD59 (Color(0xFFFEBD59))
   - Navy Blue: #2D497B (Color(0xFF2D497B))
   - Replace any orange/pink colors with these

2. **Flutter Best Practices:**
   - Use StatefulWidget or StatelessWidget appropriately
   - Use proper Material Design 3 widgets
   - Follow Flutter naming conventions (snake_case for files, PascalCase for classes)
   - Use const constructors where possible

3. **Preserve Functionality:**
   - Keep all interactive elements (buttons, gestures, etc.)
   - Maintain state management logic
   - Preserve navigation logic
   - Keep all event handlers

4. **Component Structure:**
   - Create proper widget hierarchy
   - Use composition over inheritance
   - Extract reusable widgets
   - Add proper documentation comments

5. **Styling:**
   - Use our AppColors, AppSpacing, AppTheme
   - Match the visual design
   - Use proper padding, margins, borders
   - Implement responsive design

PROVIDE:
1. Complete Dart code for the widget
2. File path where it should be saved (lib/features/...)
3. Any dependencies needed (packages)
4. Usage example
5. Any additional files needed (models, providers, etc.)

Be thorough and ensure the Flutter version works exactly like the React version!"""
    
    message = client.beta.threads.messages.create(
        thread_id=thread_id,
        role="user",
        content=message_text
    )
    
    return message

def run_assistant(client, thread_id, assistant_id):
    """Run the assistant and wait for completion"""
    
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
        print(f"   Converting... ({run.status})")
    
    if run.status == 'completed':
        return True
    else:
        print(f"❌ Conversion failed: {run.status}")
        if run.last_error:
            print(f"   Error: {run.last_error}")
        return False

def get_latest_message(client, thread_id):
    """Get the latest assistant message"""
    
    messages = client.beta.threads.messages.list(
        thread_id=thread_id,
        order='desc',
        limit=1
    )
    
    for message in messages.data:
        if message.role == 'assistant':
            for content in message.content:
                if content.type == 'text':
                    return content.text.value
    
    return None

def save_conversion(component_name, conversion_result):
    """Save conversion result to file"""
    
    output_dir = "converted_components"
    os.makedirs(output_dir, exist_ok=True)
    
    output_file = os.path.join(output_dir, f"{component_name}_conversion.md")
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"# {component_name} - Flutter Conversion\n\n")
        f.write(conversion_result)
    
    print(f"💾 Saved to: {output_file}")

def main():
    print("\n" + "="*70)
    print("🔄 FIGMA COMPONENT CONVERTER - React/TypeScript → Flutter/Dart")
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
    
    # Define components to convert (in priority order)
    components_dir = Path("../ChekMate (Copy)/src/components")
    
    components_to_convert = [
        # Core UI Components (Priority 1)
        ("Post", "Post.tsx"),
        ("Stories", "Stories.tsx"),
        ("BottomNavigation", "BottomNavigation.tsx"),
        ("Header", "Header.tsx"),
        ("NavigationTabs", "NavigationTabs.tsx"),
        
        # Feature Components (Priority 2)
        ("Following", "Following.tsx"),
        ("Explore", "Explore.tsx"),
        ("Live", "Live.tsx"),
        ("RateYourDate", "RateYourDate.tsx"),
        ("Notifications", "Notifications.tsx"),
        
        # Profile Components (Priority 3)
        ("MyProfile", "MyProfile.tsx"),
        ("UserProfile", "UserProfile.tsx"),
        ("ProfileCard", "ProfileCard.tsx"),
        ("EditProfile", "EditProfile.tsx"),
        
        # Messaging Components (Priority 4)
        ("MessagesPage", "MessagesPage.tsx"),
        ("MessagingInterface", "MessagingInterface.tsx"),
        ("ConversationInputBar", "ConversationInputBar.tsx"),
        
        # Modal Components (Priority 5)
        ("PostCreationModal", "PostCreationModal.tsx"),
        ("PostDetailModal", "PostDetailModal.tsx"),
        ("ShareModal", "ShareModal.tsx"),
        ("StoryViewer", "StoryViewer.tsx"),
    ]
    
    total_components = len(components_to_convert)
    converted_count = 0
    failed_count = 0
    
    print(f"📦 Found {total_components} components to convert\n")
    
    for idx, (component_name, file_name) in enumerate(components_to_convert, 1):
        print(f"\n{'='*70}")
        print(f"🔄 [{idx}/{total_components}] Converting: {component_name}")
        print(f"{'='*70}\n")
        
        # Read component file
        file_path = components_dir / file_name
        if not file_path.exists():
            print(f"⚠️  File not found: {file_path}")
            failed_count += 1
            continue
        
        component_code = read_component_file(file_path)
        if not component_code:
            failed_count += 1
            continue
        
        print(f"📖 Read {len(component_code)} characters from {file_name}")
        
        # Send conversion request
        print(f"🤖 Sending to AI assistant...")
        send_conversion_request(client, thread_id, component_name, component_code)
        
        # Run assistant
        success = run_assistant(client, thread_id, assistant_id)
        
        if success:
            # Get conversion result
            conversion_result = get_latest_message(client, thread_id)
            
            if conversion_result:
                # Save conversion
                save_conversion(component_name, conversion_result)
                converted_count += 1
                print(f"✅ {component_name} converted successfully!")
            else:
                print(f"❌ No conversion result received")
                failed_count += 1
        else:
            failed_count += 1
        
        # Rate limiting - wait between requests
        if idx < total_components:
            print(f"\n⏳ Waiting 3 seconds before next conversion...")
            time.sleep(3)
    
    # Summary
    print("\n" + "="*70)
    print("📊 CONVERSION SUMMARY")
    print("="*70 + "\n")
    
    print(f"✅ Successfully converted: {converted_count}/{total_components}")
    print(f"❌ Failed: {failed_count}/{total_components}")
    print(f"📁 Output directory: converted_components/")
    print()
    
    print("🎯 NEXT STEPS:")
    print("   1. Review converted components in converted_components/")
    print("   2. Copy Dart code to appropriate Flutter files")
    print("   3. Add any required dependencies to pubspec.yaml")
    print("   4. Test each component")
    print("   5. Integrate into main app")
    print()
    
    estimated_cost = total_components * 0.50
    print(f"💰 Estimated cost: ${estimated_cost:.2f}")
    print()

if __name__ == '__main__':
    main()

