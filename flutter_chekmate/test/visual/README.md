# Visual Testing Directory

**Last Updated:** October 17, 2025  
**Purpose:** Visual testing screenshots and baselines for ChekMate  
**Testing Approach:** Hybrid (Playwright MCP + Selenium)

---

## 📂 DIRECTORY STRUCTURE

```
test/visual/
├── dev/                          # Development screenshots (Playwright MCP)
│   ├── phase1/                   # Phase 1 development screenshots
│   ├── phase2/                   # Phase 2 development screenshots
│   ├── phase3/                   # Phase 3 development screenshots
│   ├── phase4/                   # Phase 4 development screenshots
│   └── phase5/                   # Phase 5 development screenshots
├── baselines/                    # Baseline screenshots (Selenium)
│   ├── phase1/                   # Phase 1 baselines (git tracked)
│   ├── phase2/                   # Phase 2 baselines (git tracked)
│   ├── phase3/                   # Phase 3 baselines (git tracked)
│   ├── phase4/                   # Phase 4 baselines (git tracked)
│   └── phase5/                   # Phase 5 baselines (git tracked)
├── results/                      # Test results (Selenium)
│   └── latest/                   # Latest test run (git ignored)
└── README.md                     # This file
```

---

## 🎯 PURPOSE

### **dev/** - Development Screenshots
- **Tool:** Playwright MCP (via Augment)
- **Purpose:** Quick visual checks during development
- **Git Status:** ❌ Not tracked (add to .gitignore)
- **Usage:** Ad-hoc screenshots, debugging, iteration
- **Retention:** Delete after feature completion

### **baselines/** - Baseline Screenshots
- **Tool:** Selenium (automated)
- **Purpose:** Known-good screenshots for regression testing
- **Git Status:** ✅ Tracked (committed to repository)
- **Usage:** Comparison baseline for automated tests
- **Retention:** Permanent (updated when UI changes intentionally)

### **results/** - Test Results
- **Tool:** Selenium (automated)
- **Purpose:** Latest test run results
- **Git Status:** ❌ Not tracked (add to .gitignore)
- **Usage:** Compare against baselines to detect regressions
- **Retention:** Overwritten on each test run

---

## 🔧 USAGE

### **Development (Playwright MCP)**

**During feature development:**
```
1. Implement feature
2. Ask AI: "Use Playwright to navigate to http://localhost:8080/#/login"
3. Ask AI: "Use Playwright to capture screenshot and save as test/visual/dev/phase1/login_page.png"
4. Review screenshot
5. Iterate on design
```

**Example commands:**
```
"Use Playwright to capture screenshot and save as test/visual/dev/phase2/voice_recording.png"
"Use Playwright to capture screenshot and save as test/visual/dev/phase2/video_call_active.png"
```

---

### **Testing (Selenium)**

**After feature completion:**
```bash
# Run Selenium tests
cd flutter_chekmate
scripts\batch\run_visual_tests.bat

# Results saved to:
test/visual/results/latest/
```

**Create baselines:**
```bash
# After verifying screenshots are correct
# Copy from results to baselines
copy test\visual\results\latest\*.png test\visual\baselines\phase1\
```

---

## 📋 NAMING CONVENTIONS

### **Development Screenshots (dev/)**

**Format:** `{feature}_{state}_{variant}.png`

**Examples:**
```
dev/phase1/
├── login_page_empty.png
├── login_page_filled.png
├── login_page_error.png
├── signup_page_empty.png
└── signup_page_success.png

dev/phase2/
├── voice_recording_button.png
├── voice_recording_active.png
├── voice_playback_controls.png
├── video_call_initiation.png
└── video_call_active.png
```

---

### **Baseline Screenshots (baselines/)**

**Format:** `{timestamp}_{test_name}.png`

**Examples:**
```
baselines/phase1/
├── 20251017_120000_login_page.png
├── 20251017_120001_signup_page.png
└── 20251017_120002_home_page.png

baselines/phase2/
├── 20251017_140000_voice_recording.png
├── 20251017_140001_voice_playback.png
├── 20251017_140002_video_call_init.png
└── 20251017_140003_video_call_active.png
```

---

## 🔄 WORKFLOW

### **Daily Development Workflow**

```
Morning:
1. Implement feature
2. Use Playwright MCP for quick visual checks
3. Save screenshots to dev/phase{N}/
4. Iterate based on feedback

Afternoon:
5. Complete feature
6. Run Selenium tests
7. Review results/ screenshots
8. Compare against baselines/
9. Fix any regressions

Evening:
10. If screenshots look good, update baselines
11. Commit code + baselines
12. Push to repository
```

---

### **End-of-Phase Workflow**

```
Phase Completion:
1. Run full Selenium regression suite
2. Review all results/ screenshots
3. Compare against all baselines/
4. Document any intentional visual changes
5. Update baselines/ if changes are intentional
6. Commit all baselines/
7. Delete dev/ screenshots (no longer needed)
8. Update PHASE_TRACKER.md
```

---

## 🚀 QUICK START

### **Test Playwright MCP**

```
1. Start Flutter web: flutter run -d chrome
2. Ask AI: "Use Playwright to navigate to http://localhost:8080"
3. Ask AI: "Use Playwright to capture screenshot and save as test/visual/dev/phase1/test.png"
4. Check: test/visual/dev/phase1/test.png exists
```

---

### **Test Selenium**

```
1. Start Flutter web: flutter run -d chrome --web-port=8080
2. Run: scripts\batch\run_visual_tests.bat
3. Check: test/visual/results/latest/ contains screenshots
```

---

## 📊 PHASE-SPECIFIC SCREENSHOTS

### **Phase 1: Authentication & Core Setup**

**Baselines to capture:**
- ✅ Login page (empty state)
- ✅ Login page (filled state)
- ✅ Signup page (empty state)
- ✅ Signup page (filled state)
- ✅ Home page (empty state)

---

### **Phase 2: Voice/Video Features**

**Baselines to capture:**
- 📸 Voice recording button
- 📸 Voice recording active state
- 📸 Voice playback controls
- 📸 Video call initiation screen
- 📸 Video call active state
- 📸 Video call controls (mute, camera, end)

---

### **Phase 3: Multi-Photo Posts**

**Baselines to capture:**
- 📸 Photo picker UI
- 📸 Photo grid layout (2, 3, 4+ photos)
- 📸 Photo zoom view
- 📸 Photo editing UI
- 📸 Post creation with photos

---

### **Phase 4: FCM & Notifications**

**Baselines to capture:**
- 📸 Notification permission dialog
- 📸 In-app notification banner
- 📸 Notification list
- 📸 Notification settings screen

---

### **Phase 5: Production Polish**

**Baselines to capture:**
- 📸 Full app flow (end-to-end)
- 📸 Dark mode variants
- 📸 Tablet layouts
- 📸 Accessibility features

---

## 🔍 TROUBLESHOOTING

### **Issue: Screenshots are blank**

**Solution:**
```
1. Ensure Flutter web is running: flutter run -d chrome --web-port=8080
2. Wait for app to fully load (3-5 seconds)
3. Check browser console for errors
```

---

### **Issue: Playwright MCP can't save screenshots**

**Solution:**
```
1. Ensure directory exists: test/visual/dev/phase{N}/
2. Use absolute path or relative from project root
3. Check file permissions
```

---

### **Issue: Selenium tests fail**

**Solution:**
```
1. Check app URL is correct (http://localhost:8080)
2. Ensure Chrome WebDriver is installed
3. Update Selenium: pip install --upgrade selenium
4. Check requirements.txt dependencies
```

---

## 📚 RELATED DOCUMENTATION

- `docs/tools/HYBRID_VISUAL_TESTING_WORKFLOW.md` - Complete workflow guide
- `docs/tools/PLAYWRIGHT_MCP_COMMANDS.md` - Playwright command reference
- `docs/tools/PLAYWRIGHT_MCP_GUIDE.md` - Detailed Playwright guide
- `scripts/python/test_selenium.py` - Selenium test suite

---

## ✅ CHECKLIST

### **Setup**
- [x] Create directory structure
- [x] Configure Selenium tests
- [x] Document workflow
- [ ] Capture Phase 1 baselines
- [ ] Test Playwright MCP
- [ ] Add to .gitignore (dev/, results/)

### **Phase 1**
- [ ] Capture login page baseline
- [ ] Capture signup page baseline
- [ ] Capture home page baseline
- [ ] Commit baselines to git

### **Phase 2**
- [ ] Capture voice UI baselines
- [ ] Capture video UI baselines
- [ ] Run regression tests
- [ ] Commit baselines to git

---

**Maintained by:** ChekMate Development Team  
**Last Review:** October 17, 2025  
**Next Review:** Before Phase 2 start

