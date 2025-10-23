# MANUAL TESTING GUIDE - PHASE 5: POLISH & DIFFERENTIATION

**Purpose:** Manual testing guide for Phase 5 features on low-end devices  
**Target Devices:** Devices with <2GB RAM, older processors  
**Focus:** Animation performance, staggered grids, file uploads, HTTP client  
**Created:** October 18, 2025

---

## 📱 TEST DEVICES

### **Minimum Spec Devices (Required)**

**Android:**
- Samsung Galaxy J2 (2015) - 1GB RAM, Quad-core 1.3 GHz
- Moto E4 (2017) - 2GB RAM, Quad-core 1.3 GHz
- Nokia 2.1 (2018) - 1GB RAM, Quad-core 1.4 GHz

**iOS:**
- iPhone 6 (2014) - 1GB RAM, Apple A8
- iPhone 6s (2015) - 2GB RAM, Apple A9
- iPhone SE (1st gen, 2016) - 2GB RAM, Apple A9

### **Mid-Range Devices (Recommended)**

**Android:**
- Samsung Galaxy A12 (2020) - 3GB RAM
- Xiaomi Redmi 9 (2020) - 3GB RAM

**iOS:**
- iPhone 7 (2016) - 2GB RAM
- iPhone 8 (2017) - 2GB RAM

---

## 🎯 TESTING OBJECTIVES

### **Performance Targets**
- ✅ **60 FPS** during animations (16.67ms per frame)
- ✅ **<200ms** animation duration for optimal UX
- ✅ **<500ms** page transition time
- ✅ **<2s** initial load time
- ✅ **<100MB** memory usage during normal operation
- ✅ **No jank** during scroll animations

---

## 🧪 TEST SCENARIOS

### **1. TikTok-Style Animations (Priority: P0)**

#### **Test 1.1: Feed Page Animations**
**Location:** Feed Page  
**Features:** AnimatedFeedCard, stagger animations

**Steps:**
1. Open the app and navigate to Feed page
2. Observe feed cards loading with fade-in slide animation
3. Scroll down to load more posts
4. Observe new posts animating in

**Success Criteria:**
- ✅ Feed cards animate smoothly (60 FPS)
- ✅ No jank during scroll
- ✅ Stagger delay is noticeable but not excessive (<100ms between items)
- ✅ Animation completes within 300ms

**Performance Metrics:**
- Frame rate: _____ FPS (target: 60 FPS)
- Animation duration: _____ ms (target: <300ms)
- Jank count: _____ (target: 0)

---

#### **Test 1.2: Stories Animations**
**Location:** Stories Widget (top of Feed)  
**Features:** AnimatedStoryCircle, scale-in animations

**Steps:**
1. Open Feed page
2. Observe story circles at the top
3. Watch for scale-in animation
4. Scroll horizontally through stories

**Success Criteria:**
- ✅ Story circles animate in with scale effect
- ✅ Horizontal scroll is smooth
- ✅ No lag when tapping a story

**Performance Metrics:**
- Frame rate: _____ FPS (target: 60 FPS)
- Animation duration: _____ ms (target: <300ms)
- Tap response time: _____ ms (target: <100ms)

---

#### **Test 1.3: Explore Page Grid Animations**
**Location:** Explore Page  
**Features:** AnimatedGridItem, staggered grid animations

**Steps:**
1. Navigate to Explore page
2. Observe grid items loading with scale-in animation
3. Scroll down to load more content
4. Tap on a grid item

**Success Criteria:**
- ✅ Grid items animate in smoothly
- ✅ Stagger effect is visible
- ✅ Scroll performance is smooth
- ✅ Tap response is immediate

**Performance Metrics:**
- Frame rate: _____ FPS (target: 60 FPS)
- Grid load time: _____ ms (target: <500ms)
- Scroll jank: _____ (target: 0)

---

#### **Test 1.4: Button Animations**
**Location:** Throughout app (Like, Share, Bookmark buttons)  
**Features:** AnimatedButton, AnimatedIconButton

**Steps:**
1. Navigate to a post
2. Tap Like button rapidly (10 times)
3. Tap Share button
4. Tap Bookmark button
5. Observe scale animations

**Success Criteria:**
- ✅ Buttons respond to every tap
- ✅ Scale animation is smooth
- ✅ No lag or dropped taps
- ✅ Animation completes before next tap

**Performance Metrics:**
- Tap response time: _____ ms (target: <50ms)
- Animation duration: _____ ms (target: <200ms)
- Dropped taps: _____ (target: 0)

---

#### **Test 1.5: Counter Animations**
**Location:** Post likes, views, comments  
**Features:** AnimatedCounter

**Steps:**
1. Find a post with like count
2. Tap like button
3. Observe counter animation
4. Unlike and like again rapidly

**Success Criteria:**
- ✅ Counter animates smoothly
- ✅ Numbers transition without jank
- ✅ Rapid taps don't break animation

**Performance Metrics:**
- Animation smoothness: _____ (1-10 scale)
- Frame drops: _____ (target: 0)

---

### **2. Page Transitions (Priority: P0)**

#### **Test 2.1: Slide Up Transition**
**Location:** Post detail, Profile, Settings  
**Features:** TikTokPageRoute with slideUp

**Steps:**
1. Tap on a post to open detail view
2. Observe slide-up transition
3. Swipe down to dismiss
4. Repeat 5 times

**Success Criteria:**
- ✅ Transition is smooth (60 FPS)
- ✅ No stuttering during animation
- ✅ Gesture dismissal works smoothly

**Performance Metrics:**
- Transition duration: _____ ms (target: <300ms)
- Frame rate: _____ FPS (target: 60 FPS)

---

#### **Test 2.2: Fade Transition**
**Location:** Navigation between tabs  
**Features:** TikTokPageRoute with fade

**Steps:**
1. Navigate between Feed, Explore, Messages tabs
2. Observe fade transitions
3. Switch tabs rapidly

**Success Criteria:**
- ✅ Fade is smooth
- ✅ No white flash between transitions
- ✅ Rapid switching doesn't cause lag

**Performance Metrics:**
- Transition duration: _____ ms (target: <300ms)
- Tab switch lag: _____ ms (target: <100ms)

---

### **3. Staggered Grid Performance (Priority: P1)**

#### **Test 3.1: Instagram Explore Grid**
**Location:** Explore Page  
**Features:** MasonryGridView, 3-column layout

**Steps:**
1. Navigate to Explore page
2. Scroll down slowly
3. Scroll down rapidly
4. Fling scroll
5. Observe grid layout and performance

**Success Criteria:**
- ✅ Grid maintains 3-column layout
- ✅ Items load smoothly during scroll
- ✅ No jank during rapid scroll
- ✅ Fling scroll is smooth

**Performance Metrics:**
- Scroll FPS: _____ (target: 60 FPS)
- Item load time: _____ ms (target: <100ms)
- Jank during fling: _____ (target: 0)

---

#### **Test 3.2: Grid with Varied Heights**
**Location:** Explore Page  
**Features:** Masonry layout with different item heights

**Steps:**
1. Observe grid items with varied heights
2. Scroll through entire grid
3. Check for layout issues

**Success Criteria:**
- ✅ Items maintain proper spacing
- ✅ No overlapping items
- ✅ Layout is visually balanced

**Performance Metrics:**
- Layout calculation time: _____ ms
- Visual glitches: _____ (target: 0)

---

### **4. File Upload Performance (Priority: P1)**

#### **Test 4.1: Image Upload**
**Location:** Create Post, Edit Profile  
**Features:** FilePickerService, image validation

**Steps:**
1. Tap "Add Photo" button
2. Select 1 image from gallery
3. Observe upload progress
4. Repeat with 5 images
5. Repeat with 10 images (max)

**Success Criteria:**
- ✅ File picker opens quickly (<500ms)
- ✅ Image preview loads immediately
- ✅ Upload progress is visible
- ✅ Multiple uploads don't freeze UI

**Performance Metrics:**
- Picker open time: _____ ms (target: <500ms)
- Single image upload: _____ s (target: <5s)
- 10 images upload: _____ s (target: <30s)
- UI responsiveness: _____ (1-10 scale)

---

#### **Test 4.2: Video Upload**
**Location:** Create Post  
**Features:** FilePickerService, video validation

**Steps:**
1. Tap "Add Video" button
2. Select a video (10MB)
3. Observe upload progress
4. Try uploading a large video (50MB)

**Success Criteria:**
- ✅ Video picker opens quickly
- ✅ Video preview loads
- ✅ Upload progress is accurate
- ✅ Large videos show proper progress

**Performance Metrics:**
- Picker open time: _____ ms (target: <500ms)
- 10MB video upload: _____ s (target: <15s)
- 50MB video upload: _____ s (target: <60s)

---

#### **Test 4.3: File Validation**
**Location:** File upload flows  
**Features:** File size and type validation

**Steps:**
1. Try uploading an oversized image (>10MB)
2. Try uploading a non-image file
3. Try uploading an oversized video (>100MB)
4. Observe error messages

**Success Criteria:**
- ✅ Oversized files are rejected
- ✅ Invalid file types are rejected
- ✅ Error messages are clear
- ✅ No app crashes

**Performance Metrics:**
- Validation time: _____ ms (target: <100ms)
- Error message clarity: _____ (1-10 scale)

---

### **5. HTTP Client Performance (Priority: P2)**

#### **Test 5.1: API Request Performance**
**Location:** Throughout app (data fetching)  
**Features:** HttpClientService, Dio interceptors

**Steps:**
1. Open app (triggers initial API calls)
2. Navigate to different pages
3. Observe loading states
4. Test with slow network (throttle to 3G)

**Success Criteria:**
- ✅ Requests complete quickly on WiFi
- ✅ Loading indicators are shown
- ✅ Timeouts are handled gracefully
- ✅ Retry logic works on failures

**Performance Metrics:**
- WiFi request time: _____ ms (target: <1s)
- 3G request time: _____ ms (target: <5s)
- Timeout handling: _____ (Pass/Fail)

---

#### **Test 5.2: Error Handling**
**Location:** Throughout app  
**Features:** ErrorInterceptor, user-friendly messages

**Steps:**
1. Turn off internet connection
2. Try to load content
3. Observe error messages
4. Turn on internet
5. Retry failed requests

**Success Criteria:**
- ✅ Error messages are user-friendly
- ✅ Retry button is available
- ✅ App doesn't crash
- ✅ Recovery is smooth

**Performance Metrics:**
- Error detection time: _____ ms
- Recovery time: _____ ms
- User experience: _____ (1-10 scale)

---

### **6. Memory Performance (Priority: P0)**

#### **Test 6.1: Memory Usage During Normal Operation**
**Location:** Throughout app  
**Features:** All Phase 5 features

**Steps:**
1. Open app
2. Navigate through all pages
3. Scroll through feeds
4. Upload images
5. Monitor memory usage

**Success Criteria:**
- ✅ Memory stays under 100MB
- ✅ No memory leaks
- ✅ App doesn't crash on low-end devices

**Performance Metrics:**
- Initial memory: _____ MB
- Peak memory: _____ MB (target: <100MB)
- Memory after 10 min: _____ MB
- Crashes: _____ (target: 0)

---

#### **Test 6.2: Memory During Heavy Animation**
**Location:** Feed, Explore pages  
**Features:** Multiple animations running

**Steps:**
1. Scroll rapidly through Feed
2. Navigate to Explore
3. Scroll through grid
4. Monitor memory usage

**Success Criteria:**
- ✅ Memory doesn't spike excessively
- ✅ Animations don't cause OOM errors
- ✅ App remains responsive

**Performance Metrics:**
- Memory during animations: _____ MB
- Memory spikes: _____ MB
- OOM errors: _____ (target: 0)

---

## 📊 PERFORMANCE SUMMARY

### **Overall Performance Rating**
- Feed Animations: _____ / 10
- Page Transitions: _____ / 10
- Staggered Grids: _____ / 10
- File Uploads: _____ / 10
- HTTP Client: _____ / 10
- Memory Management: _____ / 10

**Overall Score:** _____ / 10

### **Critical Issues Found**
1. _____
2. _____
3. _____

### **Recommendations**
1. _____
2. _____
3. _____

---

## ✅ SIGN-OFF

**Tester Name:** _____________________  
**Device Tested:** _____________________  
**Date:** _____________________  
**Signature:** _____________________

---

**Notes:**
- Test on multiple devices for comprehensive coverage
- Document all performance metrics
- Report critical issues immediately
- Retest after fixes are applied

