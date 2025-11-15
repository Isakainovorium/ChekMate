# 🔐 SECURITY GUIDE - API KEY MANAGEMENT

## ⚠️ **CRITICAL: YOUR API KEY WAS COMPROMISED**

You shared your OpenAI API key in the chat. This is a **SERIOUS SECURITY RISK**.

---

## 🚨 **IMMEDIATE ACTIONS REQUIRED:**

### **Step 1: REVOKE THE OLD KEY (DO THIS NOW!)**

1. Go to: https://platform.openai.com/api-keys
2. Log in to your OpenAI account
3. Find the key that starts with: `sk-svcacct-UWo70txlFFpT4...`
4. Click the **"Revoke"** or **"Delete"** button
5. Confirm the revocation

**Why?** Anyone who saw that chat message can now use your API key and charge costs to your account!

---

### **Step 2: CREATE A NEW KEY**

1. Still on https://platform.openai.com/api-keys
2. Click **"Create new secret key"**
3. Give it a name (e.g., "ChekMate Vision")
4. Click **"Create secret key"**
5. **COPY THE KEY** (you'll only see it once!)
6. **DO NOT share it anywhere!**

---

### **Step 3: STORE THE NEW KEY SECURELY**

#### **Option A: In Project File (Recommended)**

1. Open the file: `flutter_chekmate\.openai_key.example`
2. Replace the placeholder text with your NEW key
3. Save the file as: `.openai_key` (remove `.example`)
4. The file should contain ONLY your key, nothing else

Example:
```
sk-proj-YOUR-NEW-KEY-HERE
```

#### **Option B: Environment Variable**

```powershell
# Temporary (current session only)
$env:OPENAI_API_KEY="sk-proj-YOUR-NEW-KEY-HERE"

# Permanent (Windows System Settings)
# 1. Search "Environment Variables" in Windows
# 2. Click "Environment Variables"
# 3. Under "User variables", click "New"
# 4. Variable name: OPENAI_API_KEY
# 5. Variable value: sk-proj-YOUR-NEW-KEY-HERE
# 6. Click OK
```

---

## 🔒 **SECURITY BEST PRACTICES:**

### **✅ DO:**
- ✅ Store API keys in files on your computer
- ✅ Use environment variables
- ✅ Keep keys in `.gitignore` files
- ✅ Revoke keys if compromised
- ✅ Use different keys for different projects
- ✅ Monitor your API usage regularly

### **❌ DON'T:**
- ❌ Share API keys in chat messages
- ❌ Commit API keys to Git repositories
- ❌ Share API keys in screenshots
- ❌ Email API keys
- ❌ Post API keys on forums/Discord/Slack
- ❌ Hard-code API keys in source code

---

## 📁 **FILE SECURITY:**

### **Files That Should NEVER Be Shared:**

```
.openai_key          ← Your API key
.env                 ← Environment variables
.anthropic_key       ← Anthropic API key
secrets.json         ← Any secrets file
credentials.json     ← Credentials
```

### **Add to .gitignore:**

Create/edit `flutter_chekmate\.gitignore`:

```
# API Keys and Secrets
.openai_key
.anthropic_key
.env
secrets.json
credentials.json
*.key
*_key
```

---

## 💰 **MONITOR YOUR USAGE:**

### **Check OpenAI Usage:**

1. Go to: https://platform.openai.com/usage
2. Monitor your API usage
3. Set up billing alerts
4. Check for unexpected charges

### **Set Spending Limits:**

1. Go to: https://platform.openai.com/account/billing/limits
2. Set a monthly spending limit (e.g., $10)
3. This prevents unexpected large bills

---

## 🔍 **WHAT TO DO IF KEY IS COMPROMISED:**

1. **Revoke immediately** at https://platform.openai.com/api-keys
2. **Create new key**
3. **Update your applications** with new key
4. **Check usage** for unauthorized charges
5. **Contact OpenAI support** if you see suspicious activity

---

## ✅ **SETUP CHECKLIST:**

- [ ] Revoked the old compromised key
- [ ] Created a new API key
- [ ] Stored new key securely (file or environment variable)
- [ ] Added `.openai_key` to `.gitignore`
- [ ] Set up billing alerts
- [ ] Set spending limits
- [ ] Tested that new key works

---

## 🚀 **USING YOUR NEW KEY:**

### **Method 1: Using the Setup Script**

```powershell
# This will load your key from .openai_key file
.\setup_openai_vision.ps1
```

### **Method 2: Manual Setup**

```powershell
# Set environment variable
$env:OPENAI_API_KEY = Get-Content .openai_key

# Test it works
python visual_analyzer_mcp.py screenshot.png --provider openai
```

---

## 📞 **SUPPORT:**

### **If You See Unauthorized Usage:**

1. **Revoke all keys immediately**
2. **Contact OpenAI:** https://help.openai.com/
3. **Dispute charges** if necessary
4. **Create new keys** with better security

### **If You Need Help:**

- OpenAI Help: https://help.openai.com/
- API Documentation: https://platform.openai.com/docs
- Billing Support: https://platform.openai.com/account/billing

---

## 🎯 **REMEMBER:**

**API keys are like passwords:**
- Never share them
- Store them securely
- Revoke if compromised
- Monitor usage regularly

**Your API key = Your money!**

Protect it like you would protect your credit card number.

---

## ✅ **NEXT STEPS:**

1. **Revoke the old key** (if you haven't already)
2. **Create a new key**
3. **Store it in `.openai_key` file**
4. **Run the setup script**
5. **Test the vision analyzer**

**Then we can continue with the project safely!** 🔒

