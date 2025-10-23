# Hybrid Visual Testing Workflow - Playwright MCP + Selenium

**Last Updated:** October 17, 2025  
**Purpose:** Combine Playwright MCP (via Augment) and Selenium for comprehensive visual testing  
**Status:** Active - Ready for Phase 2

---

## 📋 OVERVIEW

ChekMate uses a **hybrid visual testing approach** that combines:

1. **Playwright MCP** (via Augment) - AI-assisted, quick visual checks during development
2. **Selenium** (local Python) - Automated regression testing and CI/CD integration

This gives you the best of both worlds: **speed during development** and **reliability in automation**.

---

## 🎯 TOOL COMPARISON

| Feature | Playwright MCP | Selenium (Local) |
|---------|---------------|------------------|
| **Access** | Through Augment AI | Local Python scripts |
| **Setup** | ✅ Already enabled | ✅ Already configured |
| **Speed** | ⚡ Instant (AI commands) | 🔄 Script execution |
| **Use Case** | Development, ad-hoc testing | Automated testing, CI/CD |
| **Screenshots** | AI-assisted capture | Batch processing |
| **Browser Support** | Chrome, Firefox, Safari | Chrome (configured) |
| **Learning Curve** | 🟢 Easy (natural language) | 🟡 Medium (Python) |
| **Automation** | 🟡 Limited | ✅ Full automation |
| **CI/CD Integration** | ❌ No | ✅ Yes (CircleCI ready) |

---

## 🔧 CURRENT SETUP STATUS

### **Playwright MCP** ✅ ENABLED

**Status:** Active in Augment  
**Installation:** Not required (MCP access)  
**Configuration:** None needed  
**Documentation:** `docs/tools/PLAYWRIGHT_MCP_GUIDE.md`

**Available Commands:**
```
"Use Playwright to navigate to [URL]"
"Use Playwright to capture screenshot"
"Use Playwright to click [element]"
"Use Playwright to type [text] into [field]"
```

---

### **Selenium** ✅ CONFIGURED

**Status:** Installed and ready  
**Location:** `scripts/python/test_selenium.py`  
**Dependencies:** `requirements.txt` (selenium==4.15.2)  
**Batch Script:** `scripts/batch/run_visual_tests.bat`

**Files:**
```
scripts/
├── python/
│   └── test_selenium.py          # Main test suite
├── batch/
│   └── run_visual_tests.bat      # Windows launcher
└── requirements.txt               # Python dependencies
```

---

## 🎭 HYBRID WORKFLOW

### **Phase 1: Development (Use Playwright MCP)**

**When:** During active feature development  
**Tool:** Playwright MCP via Augment  
**Purpose:** Quick visual validation, debugging UI issues

**Workflow:**
```
1. Start Flutter web: flutter run -d chrome
2. Implement feature
3. Ask AI: "Use Playwright to navigate to http://localhost:8080/#/login"
4. Ask AI: "Use Playwright to capture screenshot and save as test/visual/dev/login_v1.png"
5. Review screenshot
6. Iterate on design
7. Repeat steps 3-6 as needed
```

**Example Commands:**
```
"Use Playwright to navigate to http://localhost:8080/#/signup"
"Use Playwright to take screenshot of the signup form"
"Use Playwright to click the email input field"
"Use Playwright to type 'test@example.com' into email field"
"Use Playwright to capture screenshot and save as test/visual/dev/signup_filled.png"
```

---

### **Phase 2: Testing (Use Selenium)**

**When:** After feature completion, before commit  
**Tool:** Selenium (local Python)  
**Purpose:** Automated regression testing, baseline comparison

**Workflow:**
```
1. Complete feature implementation
2. Run Selenium tests: scripts\batch\run_visual_tests.bat
3. Review test results in test_screenshots/
4. Compare against baselines
5. Fix any visual regressions
6. Commit code
```

**Command:**
```bash
# Windows
cd flutter_chekmate
scripts\batch\run_visual_tests.bat

# Or directly with Python
python scripts\python\test_selenium.py
```

---

### **Phase 3: CI/CD (Use CircleCI + Selenium)**

**When:** Automated testing in CI/CD pipeline  
**Tool:** Selenium via CircleCI  
**Purpose:** Prevent visual regressions in production

**CircleCI Job:**
```yaml
visual_tests:
  docker:
    - image: selenium/standalone-chrome:latest
  steps:
    - checkout
    - run:
        name: Install Python dependencies
        command: pip install -r requirements.txt
    - run:
        name: Start Flutter web
        command: flutter run -d web-server --web-port=8080
        background: true
    - run:
        name: Wait for server
        command: sleep 30
    - run:
        name: Run Selenium tests
        command: python scripts/python/test_selenium.py
    - store_artifacts:
        path: test_screenshots/
        destination: visual-test-results
```

---

## 📊 DECISION MATRIX

### **When to Use Playwright MCP**

✅ **Use Playwright MCP when:**
- Quickly checking UI during development
- Debugging layout issues
- Capturing screenshots for documentation
- Testing interactive elements (clicks, typing)
- Exploring new UI components
- Ad-hoc visual validation
- Accessibility testing (with AI assistance)

**Example Scenarios:**
```
Scenario 1: "Does the login button look right?"
→ "Use Playwright to navigate to login page and capture screenshot"

Scenario 2: "What happens when I click the signup button?"
→ "Use Playwright to click signup button and capture result"

Scenario 3: "Show me the voice recording UI"
→ "Use Playwright to navigate to messages and click voice record button"
```

---

### **When to Use Selenium**

✅ **Use Selenium when:**
- Running automated regression tests
- Batch processing multiple screenshots
- Comparing against baseline images
- CI/CD pipeline testing
- Scheduled visual testing
- Cross-browser testing (if configured)
- Performance testing

**Example Scenarios:**
```
Scenario 1: "Run full visual regression suite"
→ Run: scripts\batch\run_visual_tests.bat

Scenario 2: "Test all pages before commit"
→ Run: python scripts\python\test_selenium.py

Scenario 3: "Automated nightly visual tests"
→ CircleCI scheduled workflow
```

---

## 🚀 PHASE 2 IMPLEMENTATION GUIDE

### **Week 1: Voice Messages**

#### **Day 1-2: Development (Playwright MCP)**

**Morning: Implement voice recording UI**
```
1. Code voice recording button
2. "Use Playwright to navigate to http://localhost:8080/#/messages"
3. "Use Playwright to capture screenshot and save as test/visual/dev/voice_button_v1.png"
4. Review and iterate
```

**Afternoon: Implement recording state**
```
1. Code recording animation
2. "Use Playwright to click voice record button"
3. "Use Playwright to capture screenshot and save as test/visual/dev/voice_recording_v1.png"
4. Review and iterate
```

#### **Day 3-4: Implementation (Playwright MCP)**

**Test voice playback UI:**
```
1. Code playback controls
2. "Use Playwright to navigate to message with voice note"
3. "Use Playwright to capture screenshot and save as test/visual/dev/voice_playback_v1.png"
4. Review and iterate
```

#### **Day 5: Automated Testing (Selenium)**

**Create baseline screenshots:**
```
1. Update test_selenium.py with voice message tests
2. Run: scripts\batch\run_visual_tests.bat
3. Review test_screenshots/
4. Commit baselines to git
```

---

### **Week 2: Video Calls**

#### **Day 1-2: Development (Playwright MCP)**

**Video call initiation:**
```
1. Code video call button
2. "Use Playwright to navigate to video call screen"
3. "Use Playwright to capture screenshot and save as test/visual/dev/video_init_v1.png"
4. Review and iterate
```

#### **Day 3-5: Implementation (Playwright MCP)**

**Active video call UI:**
```
1. Code video call interface
2. "Use Playwright to simulate active call state"
3. "Use Playwright to capture screenshot and save as test/visual/dev/video_active_v1.png"
4. Review and iterate
```

#### **Day 6-7: Automated Testing (Selenium)**

**Full regression suite:**
```
1. Update test_selenium.py with video tests
2. Run: scripts\batch\run_visual_tests.bat
3. Compare against baselines
4. Fix any regressions
5. Commit code
```

---

## 📝 BEST PRACTICES

### **Playwright MCP Best Practices**

1. **Use descriptive filenames:**
   ```
   ✅ "save as test/visual/dev/login_page_empty_state.png"
   ❌ "save as test1.png"
   ```

2. **Organize by feature:**
   ```
   test/visual/dev/
   ├── voice/
   │   ├── recording_button.png
   │   ├── recording_active.png
   │   └── playback_controls.png
   └── video/
       ├── call_initiation.png
       └── call_active.png
   ```

3. **Document AI commands:**
   ```
   # Create a log of useful commands
   docs/tools/PLAYWRIGHT_MCP_COMMANDS.md
   ```

4. **Use for quick iterations:**
   ```
   # Don't write scripts - just ask AI
   "Use Playwright to test the new button design"
   ```

---

### **Selenium Best Practices**

1. **Maintain test scripts:**
   ```python
   # Keep test_selenium.py updated with new features
   def test_voice_message_ui(self):
       self.driver.get(f"{self.app_url}/#/messages")
       self.capture_screenshot("voice_message_button")
   ```

2. **Use baseline comparison:**
   ```python
   # Compare against known-good screenshots
   baseline = Image.open("baselines/login_page.png")
   current = Image.open("test_screenshots/login_page.png")
   diff = ImageChops.difference(baseline, current)
   ```

3. **Automate in CI/CD:**
   ```yaml
   # Add to .circleci/config.yml
   - run: python scripts/python/test_selenium.py
   ```

4. **Version control baselines:**
   ```bash
   # Commit baseline screenshots
   git add test/visual/baselines/
   git commit -m "Add Phase 2 visual baselines"
   ```

---

## 🔄 WORKFLOW INTEGRATION

### **Daily Development Workflow**

```
Morning:
1. Pull latest code
2. Start Flutter web
3. Implement feature
4. Use Playwright MCP for quick visual checks
5. Iterate based on screenshots

Afternoon:
6. Complete feature
7. Run Selenium tests
8. Review test results
9. Fix any issues
10. Commit code

Evening (CI/CD):
11. CircleCI runs Selenium tests
12. Review pipeline results
13. Merge if all tests pass
```

---

### **End-of-Phase Workflow**

```
Phase Completion:
1. Run full Selenium regression suite
2. Use Playwright MCP to capture final screenshots
3. Compare Selenium results against baselines
4. Document any visual changes
5. Update baselines if changes are intentional
6. Commit all screenshots and baselines
7. Update PHASE_TRACKER.md
8. Create phase completion summary
```

---

## 📂 DIRECTORY STRUCTURE

```
flutter_chekmate/
├── test/
│   └── visual/
│       ├── dev/                    # Playwright MCP screenshots (dev only)
│       │   ├── voice/
│       │   ├── video/
│       │   └── README.md
│       ├── baselines/              # Selenium baseline screenshots (git tracked)
│       │   ├── phase1/
│       │   ├── phase2/
│       │   └── README.md
│       └── results/                # Selenium test results (git ignored)
│           └── latest/
├── scripts/
│   ├── python/
│   │   └── test_selenium.py       # Selenium test suite
│   └── batch/
│       └── run_visual_tests.bat   # Windows launcher
└── docs/
    └── tools/
        ├── PLAYWRIGHT_MCP_GUIDE.md
        ├── HYBRID_VISUAL_TESTING_WORKFLOW.md  # This file
        └── PLAYWRIGHT_MCP_COMMANDS.md         # Command reference
```

---

## 🎯 QUICK REFERENCE

### **Playwright MCP Commands**

```bash
# Navigation
"Use Playwright to navigate to http://localhost:8080/#/login"

# Screenshots
"Use Playwright to capture screenshot"
"Use Playwright to take screenshot and save as test/visual/dev/login.png"

# Interactions
"Use Playwright to click [element]"
"Use Playwright to type 'text' into [field]"
"Use Playwright to hover over [element]"

# Accessibility
"Use Playwright to check accessibility of current page"
```

### **Selenium Commands**

```bash
# Run tests (Windows)
scripts\batch\run_visual_tests.bat

# Run tests (Python)
python scripts\python\test_selenium.py

# Install dependencies
pip install -r requirements.txt
```

---

## ✅ SETUP CHECKLIST

### **Playwright MCP**
- [x] Enabled in Augment
- [x] Documentation created
- [ ] Test with sample command
- [ ] Create dev screenshot directory
- [ ] Document useful commands

### **Selenium**
- [x] Python dependencies installed
- [x] test_selenium.py configured
- [x] Batch script created
- [ ] Update tests for Phase 2
- [ ] Create baseline screenshots
- [ ] Integrate with CircleCI

---

## 🚀 NEXT STEPS

**Before Phase 2:**
1. ✅ Test Playwright MCP with sample command
2. ✅ Create dev screenshot directories
3. ✅ Update Selenium tests for Phase 2 features
4. ✅ Document workflow in team guide

**During Phase 2:**
1. Use Playwright MCP for daily development
2. Run Selenium tests before commits
3. Review visual test results
4. Update baselines as needed

**End of Phase 2:**
1. Run full Selenium regression suite
2. Capture final screenshots with Playwright MCP
3. Document visual changes
4. Update PHASE_TRACKER.md

---

**Related Documentation:**
- `PLAYWRIGHT_MCP_GUIDE.md` - Playwright MCP details
- `README.md` - Tool overview
- `PHASE_TOOL_USAGE.md` - Phase-specific usage
- `CIRCLECI_MCP_GUIDE.md` - CI/CD integration

**Maintained by:** ChekMate Development Team  
**Last Review:** October 17, 2025  
**Next Review:** Before Phase 2 start

