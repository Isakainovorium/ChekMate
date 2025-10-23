#!/usr/bin/env python3
"""
AI Design Fixer - Uses OpenAI to automatically generate code fixes based on visual analysis
Cost-efficient: Uses gpt-4o-mini for code generation
"""

import os
import sys
import json
from openai import OpenAI

def load_api_key():
    """Load OpenAI API key from .openai_key file"""
    key_file = ".openai_key"
    if os.path.exists(key_file):
        with open(key_file, 'r') as f:
            return f.read().strip()
    return os.getenv('OPENAI_API_KEY')

def read_file(file_path):
    """Read file content"""
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()

def generate_fixes(client, analysis_report, current_code, file_path):
    """
    Generate code fixes based on analysis report
    Uses gpt-4o-mini for cost efficiency
    """
    
    prompt = f"""You are a Flutter expert. Based on the visual analysis report, generate EXACT code fixes.

ANALYSIS REPORT:
{analysis_report}

CURRENT CODE ({file_path}):
```dart
{current_code}
```

GENERATE:

1. **SPECIFIC CHANGES NEEDED**:
   - List each change with exact line numbers
   - Provide before/after code snippets
   - Explain why each change is needed

2. **UPDATED CODE**:
   - Provide the complete updated file
   - Ensure all changes match the Figma design
   - Use exact hex colors from the report
   - Use exact spacing values from the report

3. **VERIFICATION**:
   - List what should be visible after the fix
   - Provide expected color values
   - Describe expected layout

Format your response as:

## Changes Needed

1. **Change 1**: [description]
   - Line: [line number]
   - Before: `[old code]`
   - After: `[new code]`
   - Reason: [why]

2. **Change 2**: ...

## Updated Code

```dart
[complete updated file]
```

## Verification Checklist

- [ ] Primary color is #FEBD59 (golden)
- [ ] Secondary color is #2D497B (navy blue)
- [ ] Spacing matches Figma
- [ ] Typography matches Figma
- [ ] Components match Figma

Be SPECIFIC and ACCURATE."""

    response = client.chat.completions.create(
        model="gpt-4o-mini",  # Cost-efficient model
        messages=[
            {
                "role": "system",
                "content": "You are a Flutter expert who generates precise code fixes based on visual design analysis."
            },
            {
                "role": "user",
                "content": prompt
            }
        ],
        max_tokens=3000,
        temperature=0.3  # Lower temperature for more consistent code generation
    )
    
    return response.choices[0].message.content

def main():
    print("\n" + "="*70)
    print("🔧 AI DESIGN FIXER - Automated Code Generation")
    print("="*70 + "\n")
    
    # Load API key
    api_key = load_api_key()
    if not api_key:
        print("❌ ERROR: OpenAI API key not found!")
        sys.exit(1)
    
    client = OpenAI(api_key=api_key)
    
    # Check for analysis report
    report_file = "FIGMA_FLUTTER_COMPARISON_REPORT.md"
    if not os.path.exists(report_file):
        print(f"❌ ERROR: Analysis report not found: {report_file}")
        print("   Run match_figma_quality.ps1 first to generate the report")
        sys.exit(1)
    
    print(f"📋 Reading analysis report: {report_file}")
    analysis_report = read_file(report_file)
    
    # Files to potentially fix
    files_to_check = [
        "lib/core/theme/app_colors.dart",
        "lib/core/theme/app_theme.dart",
        "lib/core/theme/app_spacing.dart",
        "lib/features/home/presentation/pages/home_page.dart"
    ]
    
    print("\n🔍 Analyzing files for fixes...\n")
    
    fixes = {}
    
    for file_path in files_to_check:
        if os.path.exists(file_path):
            print(f"📄 Analyzing: {file_path}")
            current_code = read_file(file_path)
            
            # Generate fixes
            fix_suggestions = generate_fixes(client, analysis_report, current_code, file_path)
            fixes[file_path] = fix_suggestions
            
            # Save individual fix report
            fix_report_file = f"FIX_REPORT_{os.path.basename(file_path)}.md"
            with open(fix_report_file, 'w', encoding='utf-8') as f:
                f.write(f"# Fix Report: {file_path}\n\n")
                f.write(fix_suggestions)
            
            print(f"   ✅ Fix report saved: {fix_report_file}")
        else:
            print(f"   ⚠️  File not found: {file_path}")
    
    # Generate master fix plan
    print("\n📝 Generating master fix plan...")
    
    master_plan = "# Master Fix Plan - Figma Quality Matching\n\n"
    master_plan += "## Overview\n\n"
    master_plan += "This plan contains all code fixes needed to match Figma design quality.\n\n"
    
    for file_path, fix_content in fixes.items():
        master_plan += f"\n## {file_path}\n\n"
        master_plan += fix_content + "\n\n"
        master_plan += "---\n\n"
    
    master_plan_file = "MASTER_FIX_PLAN.md"
    with open(master_plan_file, 'w', encoding='utf-8') as f:
        f.write(master_plan)
    
    print(f"✅ Master fix plan saved: {master_plan_file}")
    
    print("\n" + "="*70)
    print("📋 SUMMARY:")
    print("="*70 + "\n")
    print(f"Files analyzed: {len(fixes)}")
    print(f"Fix reports generated: {len(fixes)}")
    print(f"Master plan: {master_plan_file}")
    print("\n✅ Ready to implement fixes!")
    print("\n" + "="*70 + "\n")

if __name__ == '__main__':
    main()

