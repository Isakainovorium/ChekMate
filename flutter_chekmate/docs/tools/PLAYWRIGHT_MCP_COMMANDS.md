# Playwright MCP - Command Reference Guide

**Last Updated:** October 17, 2025  
**Purpose:** Quick reference for Playwright MCP commands via Augment  
**Status:** Active

---

## 📋 OVERVIEW

This guide provides ready-to-use Playwright MCP commands for ChekMate visual testing. Simply copy and paste these commands into your Augment AI assistant.

---

## 🌐 NAVIGATION COMMANDS

### **Basic Navigation**

```
"Use Playwright to navigate to http://localhost:8080"
"Use Playwright to navigate to http://localhost:8080/#/login"
"Use Playwright to navigate to http://localhost:8080/#/signup"
"Use Playwright to navigate to http://localhost:8080/#/home"
"Use Playwright to navigate to http://localhost:8080/#/messages"
"Use Playwright to navigate to http://localhost:8080/#/profile"
```

### **Go Back/Forward**

```
"Use Playwright to go back"
"Use Playwright to go forward"
"Use Playwright to reload the page"
```

---

## 📸 SCREENSHOT COMMANDS

### **Basic Screenshots**

```
"Use Playwright to capture screenshot"
"Use Playwright to take screenshot of current page"
"Use Playwright to take full page screenshot"
```

### **Save Screenshots**

```
"Use Playwright to take screenshot and save as test/visual/dev/login_page.png"
"Use Playwright to capture screenshot and save as test/visual/dev/signup_form.png"
"Use Playwright to take full page screenshot and save as test/visual/dev/home_full.png"
```

### **Element Screenshots**

```
"Use Playwright to take screenshot of the login button"
"Use Playwright to capture screenshot of the navigation bar"
"Use Playwright to take screenshot of the form and save as test/visual/dev/signup_form.png"
```

---

## 🖱️ INTERACTION COMMANDS

### **Click Actions**

```
"Use Playwright to click the login button"
"Use Playwright to click the signup link"
"Use Playwright to click the voice record button"
"Use Playwright to click the element with text 'Submit'"
"Use Playwright to click the element with id 'submit-button'"
```

### **Type/Input Actions**

```
"Use Playwright to type 'test@example.com' into the email field"
"Use Playwright to type 'password123' into the password field"
"Use Playwright to fill the email field with 'user@test.com'"
"Use Playwright to clear the email field"
```

### **Hover Actions**

```
"Use Playwright to hover over the profile icon"
"Use Playwright to hover over the menu button"
"Use Playwright to move mouse to the navigation bar"
```

### **Select/Dropdown Actions**

```
"Use Playwright to select 'Male' from the gender dropdown"
"Use Playwright to choose option 'United States' from country select"
```

---

## 🔍 ELEMENT INSPECTION

### **Find Elements**

```
"Use Playwright to find element with text 'Login'"
"Use Playwright to find button with text 'Sign Up'"
"Use Playwright to locate input field with placeholder 'Email'"
"Use Playwright to find element with id 'submit-button'"
"Use Playwright to find element with class 'primary-button'"
```

### **Check Element State**

```
"Use Playwright to check if login button is visible"
"Use Playwright to check if email field is enabled"
"Use Playwright to verify if submit button is clickable"
"Use Playwright to check if error message is displayed"
```

---

## ⏱️ WAIT COMMANDS

### **Wait for Elements**

```
"Use Playwright to wait for login button to appear"
"Use Playwright to wait for page to load"
"Use Playwright to wait for navigation to complete"
"Use Playwright to wait 2 seconds"
```

### **Wait for State**

```
"Use Playwright to wait for network to be idle"
"Use Playwright to wait for page to be fully loaded"
"Use Playwright to wait for element to be visible"
```

---

## 📱 DEVICE EMULATION

### **Mobile Devices**

```
"Use Playwright to emulate iPhone 12"
"Use Playwright to emulate Pixel 5"
"Use Playwright to emulate iPad"
"Use Playwright to set viewport to 375x667"
```

### **Orientation**

```
"Use Playwright to set orientation to portrait"
"Use Playwright to set orientation to landscape"
```

---

## ♿ ACCESSIBILITY TESTING

### **Accessibility Checks**

```
"Use Playwright to check accessibility of current page"
"Use Playwright to run accessibility audit"
"Use Playwright to check for WCAG violations"
"Use Playwright to verify keyboard navigation"
```

---

## 🎯 CHEKMATE-SPECIFIC COMMANDS

### **Phase 1: Authentication**

```
# Login Page
"Use Playwright to navigate to http://localhost:8080/#/login"
"Use Playwright to capture screenshot and save as test/visual/dev/phase1/login_page.png"
"Use Playwright to type 'test@example.com' into email field"
"Use Playwright to type 'password123' into password field"
"Use Playwright to click the login button"
"Use Playwright to capture screenshot and save as test/visual/dev/phase1/login_filled.png"

# Signup Page
"Use Playwright to navigate to http://localhost:8080/#/signup"
"Use Playwright to capture screenshot and save as test/visual/dev/phase1/signup_page.png"
"Use Playwright to fill signup form with test data"
"Use Playwright to click the signup button"
```

---

### **Phase 2: Voice Messages**

```
# Voice Recording UI
"Use Playwright to navigate to http://localhost:8080/#/messages"
"Use Playwright to capture screenshot and save as test/visual/dev/phase2/messages_page.png"
"Use Playwright to click the voice record button"
"Use Playwright to capture screenshot and save as test/visual/dev/phase2/voice_recording.png"
"Use Playwright to wait 2 seconds"
"Use Playwright to click the stop recording button"
"Use Playwright to capture screenshot and save as test/visual/dev/phase2/voice_recorded.png"

# Voice Playback UI
"Use Playwright to click the voice message"
"Use Playwright to capture screenshot and save as test/visual/dev/phase2/voice_playback.png"
"Use Playwright to click the play button"
"Use Playwright to capture screenshot and save as test/visual/dev/phase2/voice_playing.png"
```

---

### **Phase 2: Video Calls**

```
# Video Call Initiation
"Use Playwright to navigate to http://localhost:8080/#/video-call"
"Use Playwright to capture screenshot and save as test/visual/dev/phase2/video_init.png"
"Use Playwright to click the start video call button"
"Use Playwright to capture screenshot and save as test/visual/dev/phase2/video_permission.png"

# Active Video Call
"Use Playwright to wait for video call to connect"
"Use Playwright to capture screenshot and save as test/visual/dev/phase2/video_active.png"
"Use Playwright to click the mute button"
"Use Playwright to capture screenshot and save as test/visual/dev/phase2/video_muted.png"
"Use Playwright to click the end call button"
"Use Playwright to capture screenshot and save as test/visual/dev/phase2/video_ended.png"
```

---

### **Phase 3: Multi-Photo Posts**

```
# Photo Picker
"Use Playwright to navigate to http://localhost:8080/#/create-post"
"Use Playwright to capture screenshot and save as test/visual/dev/phase3/create_post.png"
"Use Playwright to click the add photos button"
"Use Playwright to capture screenshot and save as test/visual/dev/phase3/photo_picker.png"

# Photo Grid
"Use Playwright to select multiple photos"
"Use Playwright to capture screenshot and save as test/visual/dev/phase3/photo_grid.png"
"Use Playwright to click the first photo"
"Use Playwright to capture screenshot and save as test/visual/dev/phase3/photo_zoom.png"
```

---

### **Phase 4: Notifications**

```
# Notification Settings
"Use Playwright to navigate to http://localhost:8080/#/settings/notifications"
"Use Playwright to capture screenshot and save as test/visual/dev/phase4/notification_settings.png"
"Use Playwright to click the enable notifications button"
"Use Playwright to capture screenshot and save as test/visual/dev/phase4/notification_permission.png"

# In-App Notifications
"Use Playwright to navigate to http://localhost:8080/#/home"
"Use Playwright to trigger notification"
"Use Playwright to capture screenshot and save as test/visual/dev/phase4/notification_banner.png"
```

---

## 🔄 WORKFLOW SEQUENCES

### **Complete Login Flow**

```
"Use Playwright to navigate to http://localhost:8080/#/login"
"Use Playwright to capture screenshot and save as test/visual/dev/login_1_empty.png"
"Use Playwright to type 'test@example.com' into email field"
"Use Playwright to capture screenshot and save as test/visual/dev/login_2_email.png"
"Use Playwright to type 'password123' into password field"
"Use Playwright to capture screenshot and save as test/visual/dev/login_3_filled.png"
"Use Playwright to click the login button"
"Use Playwright to wait for navigation to complete"
"Use Playwright to capture screenshot and save as test/visual/dev/login_4_success.png"
```

---

### **Complete Signup Flow**

```
"Use Playwright to navigate to http://localhost:8080/#/signup"
"Use Playwright to capture screenshot and save as test/visual/dev/signup_1_empty.png"
"Use Playwright to type 'newuser@example.com' into email field"
"Use Playwright to type 'SecurePass123' into password field"
"Use Playwright to type 'John Doe' into name field"
"Use Playwright to capture screenshot and save as test/visual/dev/signup_2_filled.png"
"Use Playwright to click the signup button"
"Use Playwright to wait for navigation to complete"
"Use Playwright to capture screenshot and save as test/visual/dev/signup_3_success.png"
```

---

### **Voice Message Flow**

```
"Use Playwright to navigate to http://localhost:8080/#/messages"
"Use Playwright to capture screenshot and save as test/visual/dev/voice_1_messages.png"
"Use Playwright to click the voice record button"
"Use Playwright to capture screenshot and save as test/visual/dev/voice_2_recording.png"
"Use Playwright to wait 3 seconds"
"Use Playwright to click the stop button"
"Use Playwright to capture screenshot and save as test/visual/dev/voice_3_recorded.png"
"Use Playwright to click the send button"
"Use Playwright to capture screenshot and save as test/visual/dev/voice_4_sent.png"
```

---

## 💡 TIPS & TRICKS

### **Tip 1: Use Descriptive Filenames**

```
✅ Good:
"save as test/visual/dev/phase2/voice_recording_active_state.png"

❌ Bad:
"save as test1.png"
```

### **Tip 2: Organize by Feature**

```
test/visual/dev/
├── phase1/
│   ├── login_page.png
│   └── signup_page.png
├── phase2/
│   ├── voice_recording.png
│   └── video_call.png
└── phase3/
    └── photo_picker.png
```

### **Tip 3: Capture State Changes**

```
# Before interaction
"Use Playwright to capture screenshot and save as button_before.png"

# After interaction
"Use Playwright to click the button"
"Use Playwright to capture screenshot and save as button_after.png"
```

### **Tip 4: Use Wait Commands**

```
# Wait for animations to complete
"Use Playwright to click the button"
"Use Playwright to wait 1 second"
"Use Playwright to capture screenshot"
```

### **Tip 5: Test Responsive Design**

```
# Desktop
"Use Playwright to set viewport to 1920x1080"
"Use Playwright to capture screenshot and save as desktop.png"

# Tablet
"Use Playwright to set viewport to 768x1024"
"Use Playwright to capture screenshot and save as tablet.png"

# Mobile
"Use Playwright to set viewport to 375x667"
"Use Playwright to capture screenshot and save as mobile.png"
```

---

## 🚀 QUICK START

### **Test Playwright MCP Right Now**

```
1. "Use Playwright to navigate to https://google.com"
2. "Use Playwright to capture screenshot"
3. "Use Playwright to type 'Playwright testing' into search box"
4. "Use Playwright to click the search button"
5. "Use Playwright to capture screenshot"
```

### **Test with ChekMate (Flutter web must be running)**

```
1. Start Flutter: flutter run -d chrome
2. "Use Playwright to navigate to http://localhost:8080"
3. "Use Playwright to capture screenshot and save as test/visual/dev/home_page.png"
4. "Use Playwright to navigate to http://localhost:8080/#/login"
5. "Use Playwright to capture screenshot and save as test/visual/dev/login_page.png"
```

---

## 📚 RELATED DOCUMENTATION

- `HYBRID_VISUAL_TESTING_WORKFLOW.md` - Hybrid workflow guide
- `PLAYWRIGHT_MCP_GUIDE.md` - Detailed Playwright MCP guide
- `PHASE_TOOL_USAGE.md` - Phase-specific usage
- `README.md` - Tool overview

---

**Maintained by:** ChekMate Development Team  
**Last Review:** October 17, 2025  
**Next Review:** After Phase 2 completion

