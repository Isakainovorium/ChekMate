# LangChain MCP Integration Setup Guide

**Last Updated:** October 16, 2025  
**Purpose:** Configure LangChain MCP for real-time documentation access during ChekMate implementation  
**Estimated Setup Time:** 10-15 minutes

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Environment File Setup](#environment-file-setup)
4. [Security Configuration](#security-configuration)
5. [Verification Steps](#verification-steps)
6. [Usage Guidelines](#usage-guidelines)
7. [Troubleshooting](#troubleshooting)

---

## 1. OVERVIEW

### **What is LangChain MCP?**
LangChain MCP (Model Context Protocol) allows AI assistants to access real-time documentation from external sources during the ChekMate implementation project.

### **Why Use LangChain MCP?**
- ✅ Access latest Flutter/Firebase/package documentation
- ✅ Get up-to-date code examples
- ✅ Troubleshoot platform-specific issues (iOS vs Android)
- ✅ Check for breaking changes in package versions
- ✅ Find solutions to integration problems

### **When to Use LangChain MCP?**
- **Phase 1:** Firebase version migration guidance
- **Phase 2:** Voice/video feature implementation (most valuable)
- **Phase 3:** Multi-photo posts, zoom, animations
- **Phase 4:** FCM setup, notifications (very valuable)
- **Phase 5:** Advanced features, API integration

### **Complementary to Context Docs**
- **Context Docs (PROJECT_CONTEXT.md, PHASE_TRACKER.md):** Long-term memory, decisions, progress
- **LangChain MCP:** Real-time knowledge, current docs, examples

---

## 2. PREREQUISITES

### **Required**
- ✅ LangChain API key (you mentioned you have this)
- ✅ Windows operating system (detected from workspace path)
- ✅ File system access to create environment files

### **Optional**
- Git installed (for .gitignore updates)
- Text editor (Notepad, VS Code, etc.)

---

## 3. ENVIRONMENT FILE SETUP

### **Step 1: Create Environment Directory**

**Windows Path:**
```
%USERPROFILE%\.chekmate\
```

**Full Path Example:**
```
C:\Users\IsaKai2296\.chekmate\
```

**Instructions:**
1. Open File Explorer
2. Navigate to: `C:\Users\IsaKai2296\`
3. Create new folder: `.chekmate`
4. Open the `.chekmate` folder

---

### **Step 2: Create Environment File**

**File Name:** `langchain.env`

**Full Path:**
```
C:\Users\IsaKai2296\.chekmate\langchain.env
```

**Instructions:**
1. Inside the `.chekmate` folder, create a new file
2. Name it: `langchain.env`
3. Open with text editor (Notepad, VS Code, etc.)

---

### **Step 3: Add Environment Variables**

**File Format:**
```env
# LangChain MCP Configuration
# Created: October 16, 2025
# Project: ChekMate Flutter App

# LangChain API Key
LANGCHAIN_API_KEY=your_actual_api_key_here

# Optional: LangChain Project ID (if applicable)
# LANGCHAIN_PROJECT_ID=your_project_id_here

# Optional: LangChain Endpoint (if using custom endpoint)
# LANGCHAIN_ENDPOINT=https://api.langchain.com

# Optional: Enable verbose logging for debugging
# LANGCHAIN_VERBOSE=true
```

**Instructions:**
1. Copy the template above
2. Paste into `langchain.env`
3. Replace `your_actual_api_key_here` with your actual LangChain API key
4. Save the file

**Example (with fake key):**
```env
# LangChain MCP Configuration
LANGCHAIN_API_KEY=lc_sk_1234567890abcdefghijklmnopqrstuvwxyz
```

---

### **Step 4: Set File Permissions (Security)**

**Windows Instructions:**
1. Right-click `langchain.env`
2. Select "Properties"
3. Go to "Security" tab
4. Click "Edit"
5. Ensure only your user account has "Read" permission
6. Remove permissions for other users (if any)
7. Click "Apply" and "OK"

**Why:** Prevents other users on the system from reading your API key.

---

## 4. SECURITY CONFIGURATION

### **Update .gitignore (Prevent API Key Exposure)**

**File:** `flutter_chekmate/.gitignore`

**Add these lines:**
```gitignore
# LangChain MCP Configuration
.chekmate/
*.env
langchain.env
langchain_cache/
.langchain/

# Environment files (general)
.env
.env.local
.env.*.local
```

**Why:** Ensures the API key file is never committed to version control.

---

### **Security Best Practices**

1. **Never commit API keys to Git**
   - Always use .gitignore
   - Check with `git status` before committing

2. **Never share API keys**
   - Don't paste in chat, email, or documents
   - Don't screenshot files containing keys

3. **Rotate keys if exposed**
   - If accidentally committed, rotate immediately
   - Update `langchain.env` with new key

4. **Use environment-specific keys**
   - Development key for local work
   - Production key for deployed apps (if applicable)

5. **Monitor API usage**
   - Check LangChain dashboard for unexpected usage
   - Set up usage alerts if available

---

## 5. VERIFICATION STEPS

### **Step 1: Verify File Exists**

**Windows Command Prompt:**
```cmd
dir %USERPROFILE%\.chekmate\langchain.env
```

**Expected Output:**
```
 Volume in drive C is Windows
 Directory of C:\Users\IsaKai2296\.chekmate

10/16/2025  02:30 PM               123 langchain.env
               1 File(s)            123 bytes
```

---

### **Step 2: Verify File Content (Without Exposing Key)**

**Windows Command Prompt:**
```cmd
findstr /C:"LANGCHAIN_API_KEY" %USERPROFILE%\.chekmate\langchain.env
```

**Expected Output:**
```
LANGCHAIN_API_KEY=lc_sk_...
```

**Note:** The actual key should be present (not `your_actual_api_key_here`).

---

### **Step 3: Verify .gitignore Updated**

**Windows Command Prompt (from project root):**
```cmd
cd C:\Users\IsaKai2296\Downloads\ChekMate_app\flutter_chekmate
findstr /C:".chekmate" .gitignore
```

**Expected Output:**
```
.chekmate/
```

---

### **Step 4: Verify Git Ignores the File**

**Windows Command Prompt (from project root):**
```cmd
git status
```

**Expected Output:**
- `.chekmate/` should NOT appear in untracked files
- `langchain.env` should NOT appear in untracked files

**If it appears:**
```cmd
git rm --cached .chekmate/langchain.env
git add .gitignore
git commit -m "chore: add .gitignore for LangChain MCP config"
```

---

## 6. USAGE GUIDELINES

### **How AI Assistants Access the API Key**

**Environment Variable Reference:**
```python
import os

# AI assistant reads the key from environment file
api_key = os.getenv('LANGCHAIN_API_KEY')

# Key is used but never displayed
langchain_client = LangChainClient(api_key=api_key)
```

**Important:** The AI can use the key but cannot read/display it directly.

---

### **When to Use LangChain MCP**

**✅ Good Use Cases:**
- "What's the latest API for Firebase Cloud Messaging?"
- "Show me examples of using the record package for iOS"
- "How do I configure permissions for Android 13+?"
- "What changed in flutter_animate version 4.x?"
- "How do I fix error X with package Y?"

**❌ Not Useful For:**
- "What did we decide about voice message duration?" (use PROJECT_CONTEXT.md)
- "What's the current phase status?" (use PHASE_TRACKER.md)
- "What are my coding preferences?" (use PROJECT_CONTEXT.md)
- "What tasks are completed?" (use PHASE_TRACKER.md)

---

### **Cost Management**

**Typical Costs:**
- ~$0.01-0.05 per query (depending on provider)
- For 6-week project: ~$5-20 total (100-400 queries)

**Tips to Minimize Costs:**
1. Use LangChain MCP for complex/current docs only
2. Use context docs for project-specific information
3. Batch related questions together
4. Cache responses when possible

---

## 7. TROUBLESHOOTING

### **Problem: File Not Found**

**Error:**
```
FileNotFoundError: [Errno 2] No such file or directory: 'C:\\Users\\IsaKai2296\\.chekmate\\langchain.env'
```

**Solution:**
1. Verify directory exists: `dir %USERPROFILE%\.chekmate`
2. If not, create it: `mkdir %USERPROFILE%\.chekmate`
3. Create file: `notepad %USERPROFILE%\.chekmate\langchain.env`
4. Add environment variables (see Step 3)

---

### **Problem: Invalid API Key**

**Error:**
```
AuthenticationError: Invalid API key
```

**Solution:**
1. Verify key is correct (check LangChain dashboard)
2. Ensure no extra spaces in `langchain.env`
3. Ensure key starts with `lc_sk_` or similar prefix
4. Try regenerating key in LangChain dashboard

---

### **Problem: API Key Exposed in Git**

**Error:**
```
git status shows .chekmate/langchain.env as untracked
```

**Solution:**
1. **DO NOT COMMIT**
2. Update .gitignore (see Section 4)
3. Remove from Git cache: `git rm --cached .chekmate/langchain.env`
4. Verify: `git status` (should not show file)
5. If already committed, rotate key immediately

---

### **Problem: Permission Denied**

**Error:**
```
PermissionError: [Errno 13] Permission denied: 'C:\\Users\\IsaKai2296\\.chekmate\\langchain.env'
```

**Solution:**
1. Close any programs using the file
2. Check file permissions (see Step 4)
3. Run as administrator (if necessary)
4. Ensure file is not read-only

---

### **Problem: LangChain MCP Not Working**

**Symptoms:**
- AI assistant doesn't access real-time docs
- Responses seem outdated

**Solution:**
1. Verify environment file exists and has correct key
2. Check LangChain dashboard for API usage (should show activity)
3. Verify AI assistant has access to environment variables
4. Try restarting AI session

---

## 📊 INTEGRATION STATUS

### **Setup Checklist**

- [ ] Created `.chekmate` directory in user home
- [ ] Created `langchain.env` file
- [ ] Added `LANGCHAIN_API_KEY` to environment file
- [ ] Set file permissions (Windows security)
- [ ] Updated `.gitignore` in project root
- [ ] Verified file exists (Step 1)
- [ ] Verified file content (Step 2)
- [ ] Verified .gitignore updated (Step 3)
- [ ] Verified Git ignores file (Step 4)
- [ ] Tested LangChain MCP with sample query

### **Post-Setup**

After completing the checklist:
1. Mark this task complete in PHASE_TRACKER.md
2. Update PROJECT_CONTEXT.md (ADR-005 status: COMPLETE)
3. Proceed to Phase 1 (Critical Fixes & Foundation)

---

## 🔗 ADDITIONAL RESOURCES

- **LangChain Documentation:** https://docs.langchain.com/
- **LangChain API Dashboard:** https://smith.langchain.com/
- **Environment Variables Guide:** https://docs.microsoft.com/en-us/windows/win32/procthread/environment-variables

---

## 📝 NOTES

### **Cross-Session Compatibility**
- Environment file is system-wide (accessible by any AI assistant with file access)
- Works across different AI sessions and tools
- Persists across system restarts

### **Backup Recommendation**
- Keep a backup of your API key in a secure password manager
- Don't rely solely on the environment file

### **Future Updates**
- If LangChain changes API format, update this document
- If moving to different system, recreate environment file

---

**Last Updated:** October 16, 2025  
**Next Update:** After Phase 0 completion or if LangChain API changes  
**Maintainer:** ChekMate Development Team

---

## ✅ QUICK REFERENCE

**Environment File Path:**
```
C:\Users\IsaKai2296\.chekmate\langchain.env
```

**Environment Variable Name:**
```
LANGCHAIN_API_KEY
```

**Verify Setup:**
```cmd
dir %USERPROFILE%\.chekmate\langchain.env
findstr /C:"LANGCHAIN_API_KEY" %USERPROFILE%\.chekmate\langchain.env
```

**Security:**
- ✅ Added to .gitignore
- ✅ File permissions set (Windows security)
- ✅ Never commit to Git
- ✅ Never share publicly

**Ready to Use:**
- AI assistants can access the key from environment file
- Use during Phase 1-5 for real-time documentation
- Complements context docs (PROJECT_CONTEXT.md, PHASE_TRACKER.md)

