# ChekMate App Navigation Flow Chart

**Version**: 1.0 | **Last Updated**: November 29, 2025

---

## 🚀 App Entry Flow (Numerical Order)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           APP LAUNCH                                         │
│                              │                                               │
│                              ▼                                               │
│                    ┌─────────────────┐                                       │
│                    │  1. SPLASH      │                                       │
│                    │    /splash      │                                       │
│                    └────────┬────────┘                                       │
│                             │                                                │
│              ┌──────────────┼──────────────┐                                │
│              │              │              │                                │
│              ▼              ▼              ▼                                │
│     ┌────────────┐  ┌────────────┐  ┌────────────┐                         │
│     │ NOT LOGGED │  │ LOGGED IN  │  │ LOGGED IN  │                         │
│     │    IN      │  │ ONBOARDING │  │ ONBOARDING │                         │
│     │            │  │ INCOMPLETE │  │  COMPLETE  │                         │
│     └─────┬──────┘  └─────┬──────┘  └─────┬──────┘                         │
│           │               │               │                                 │
│           ▼               ▼               ▼                                 │
│     ┌──────────┐   ┌──────────┐    ┌──────────┐                            │
│     │ 2. LOGIN │   │ 3. ONBOARD│    │ 4. HOME  │                            │
│     │ /auth/   │   │ /onboard/ │    │    /     │                            │
│     │  login   │   │  welcome  │    │          │                            │
│     └──────────┘   └──────────┘    └──────────┘                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📱 Authentication Flow (Section 2)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AUTHENTICATION                                       │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                      2.1 LOGIN PAGE                                 │     │
│  │                        /auth/login                                  │     │
│  │                                                                     │     │
│  │   User Actions:                                                     │     │
│  │   ├── [Email/Password Login] ──────────► Check Onboarding ──┐      │     │
│  │   ├── [Google Sign-In] ────────────────► Check Onboarding ──┤      │     │
│  │   ├── [Apple Sign-In] ─────────────────► Check Onboarding ──┤      │     │
│  │   ├── [Forgot Password] ───────────────► Reset Email Dialog │      │     │
│  │   └── [Create Account] ────────────────► 2.2 Signup Page    │      │     │
│  │                                                              │      │     │
│  │                              ┌───────────────────────────────┘      │     │
│  │                              ▼                                      │     │
│  │                    ┌─────────────────┐                              │     │
│  │                    │ Onboarding Done?│                              │     │
│  │                    └────────┬────────┘                              │     │
│  │                    YES │         │ NO                               │     │
│  │                        ▼         ▼                                  │     │
│  │                   ┌───────┐  ┌───────────┐                          │     │
│  │                   │ HOME  │  │ ONBOARDING│                          │     │
│  │                   │  /    │  │  WELCOME  │                          │     │
│  │                   └───────┘  └───────────┘                          │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                      2.2 SIGNUP PAGE                                │     │
│  │                        /auth/signup                                 │     │
│  │                                                                     │     │
│  │   User Actions:                                                     │     │
│  │   ├── [Add Profile Photo] ─────────────► Image Picker              │     │
│  │   ├── [Enter Name/Email/Password] ─────► Form Validation           │     │
│  │   ├── [Create Account] ────────────────► 3.1 Onboarding Welcome    │     │
│  │   └── [Already have account?] ─────────► 2.1 Login Page            │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                  2.3 TWO-FACTOR VERIFICATION                        │     │
│  │                  /auth/two-factor-verification                      │     │
│  │                                                                     │     │
│  │   User Actions:                                                     │     │
│  │   ├── [Enter Code] ────────────────────► Verify & Continue         │     │
│  │   └── [Resend Code] ───────────────────► Send New Code             │     │
│  └────────────────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Onboarding Flow (Section 3) - NEW USERS ONLY

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ONBOARDING (5 Steps)                                 │
│                    Only shown AFTER signup for NEW users                     │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  3.1 WELCOME SCREEN                                                  │    │
│  │      /onboarding/welcome                                             │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Get Started] ────────────────────► 3.2 Interests Screen       │    │
│  │  └── [Skip] ───────────────────────────► Confirm Dialog ──► HOME    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  3.2 INTERESTS SCREEN                                                │    │
│  │      /onboarding/interests                                           │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Select 3+ Interests] ────────────► Enable Continue Button     │    │
│  │  ├── [Continue] ───────────────────────► 3.3 Location Screen        │    │
│  │  └── [Back] ───────────────────────────► 3.1 Welcome Screen         │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  3.3 LOCATION SCREEN                                                 │    │
│  │      /onboarding/location                                            │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Enable Location] ────────────────► Request Permission         │    │
│  │  ├── [Skip Location] ──────────────────► 3.4 Profile Photo          │    │
│  │  ├── [Continue] ───────────────────────► 3.4 Profile Photo          │    │
│  │  └── [Back] ───────────────────────────► 3.2 Interests Screen       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  3.4 PROFILE PHOTO SCREEN                                            │    │
│  │      /onboarding/profile-photo                                       │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Take Photo] ─────────────────────► Camera                     │    │
│  │  ├── [Choose from Gallery] ────────────► Image Picker               │    │
│  │  ├── [Continue] ───────────────────────► 3.5 Completion Screen      │    │
│  │  └── [Back] ───────────────────────────► 3.3 Location Screen        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                      │                                       │
│                                      ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  3.5 COMPLETION SCREEN                                               │    │
│  │      /onboarding/completion                                          │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Start Exploring] ────────────────► HOME (/)                   │    │
│  │  │   (Sets onboardingCompleted = true in Firestore)                 │    │
│  │  └── [Back] ───────────────────────────► 3.4 Profile Photo          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🏠 Main App Flow (Section 4) - BOTTOM NAVIGATION

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MAIN APP - BOTTOM NAV                                │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     BOTTOM NAVIGATION BAR                            │    │
│  │  ┌──────────┬──────────┬──────────┬──────────┐                      │    │
│  │  │  🏠 Home │ 💬 Msgs  │ 🔔 Alerts│ 👤 Profile│                      │    │
│  │  │  (idx 0) │  (idx 1) │  (idx 2) │  (idx 3) │                      │    │
│  │  └────┬─────┴────┬─────┴────┬─────┴────┬─────┘                      │    │
│  │       │          │          │          │                             │    │
│  │       ▼          ▼          ▼          ▼                             │    │
│  │   ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐                        │    │
│  │   │ 4.1   │  │ 4.2   │  │ 4.3   │  │ 4.4   │                        │    │
│  │   │ HOME  │  │ MSGS  │  │NOTIFS │  │PROFILE│                        │    │
│  │   │  /    │  │/msgs  │  │/notif │  │/profile│                       │    │
│  │   └───────┘  └───────┘  └───────┘  └───────┘                        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🏠 4.1 HOME PAGE - Top Navigation & Actions

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         4.1 HOME PAGE (/)                                    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                       TOP TAB NAVIGATION                             │    │
│  │  ┌─────────┬──────────┬─────────┬────────┬───────────┐              │    │
│  │  │ For You │ Following│ Explore │  Live  │ Subscribe │              │    │
│  │  └────┬────┴────┬─────┴────┬────┴───┬────┴─────┬─────┘              │    │
│  │       │         │          │        │          │                     │    │
│  │       ▼         ▼          ▼        ▼          ▼                     │    │
│  │   ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐                 │    │
│  │   │4.1.1  │ │4.1.2  │ │4.1.3  │ │4.1.4  │ │4.1.5  │                 │    │
│  │   │For You│ │Follow │ │Explore│ │ Live  │ │Subscr │                 │    │
│  │   │ Feed  │ │ Feed  │ │  /exp │ │ /live │ │ /sub  │                 │    │
│  │   └───────┘ └───────┘ └───────┘ └───────┘ └───────┘                 │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    HOME PAGE ACTIONS                                 │    │
│  │                                                                      │    │
│  │  From Feed Posts:                                                    │    │
│  │  ├── [Tap Post] ───────────────────────► Post Detail (/post/:id)    │    │
│  │  ├── [Tap Avatar/Username] ────────────► User Profile (/profile/:id)│    │
│  │  ├── [Like Button] ────────────────────► Toggle Like (API call)     │    │
│  │  ├── [Chek Button] ────────────────────► Toggle Chek (API call)     │    │
│  │  ├── [Comment Button] ─────────────────► Comments Sheet             │    │
│  │  ├── [Share Button] ───────────────────► Share Sheet                │    │
│  │  └── [Bookmark Button] ────────────────► Toggle Bookmark            │    │
│  │                                                                      │    │
│  │  From Header:                                                        │    │
│  │  ├── [+ Create Post FAB] ──────────────► 5.1 Create Post            │    │
│  │  ├── [Rate Date Button] ───────────────► 5.2 Rate Date              │    │
│  │  └── [Search Icon] ────────────────────► Search Modal               │    │
│  │                                                                      │    │
│  │  From Stories Row:                                                   │    │
│  │  ├── [Tap Story Circle] ───────────────► Story Viewer               │    │
│  │  └── [+ Add Story] ────────────────────► Create Story               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 💬 4.2 MESSAGES PAGE

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      4.2 MESSAGES PAGE (/messages)                           │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    MESSAGES PAGE ACTIONS                             │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Tap Conversation] ───────────────► 4.2.1 Chat Page            │    │
│  │  ├── [New Message FAB] ────────────────► User Search Modal          │    │
│  │  ├── [Long Press Conversation] ────────► Context Menu               │    │
│  │  │   ├── [Delete] ─────────────────────► Confirm Delete             │    │
│  │  │   ├── [Mute] ───────────────────────► Toggle Mute                │    │
│  │  │   └── [Archive] ────────────────────► Move to Archive            │    │
│  │  └── [Search Messages] ────────────────► Search Filter              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              4.2.1 CHAT PAGE (/chat/:conversationId)                 │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Send Text Message] ──────────────► Send to Firebase           │    │
│  │  ├── [Send Image] ─────────────────────► Image Picker → Upload      │    │
│  │  ├── [Send Voice Message] ─────────────► Voice Recorder             │    │
│  │  ├── [Tap User Avatar] ────────────────► User Profile               │    │
│  │  ├── [Video Call Button] ──────────────► Video Call Page (WebRTC)   │    │
│  │  ├── [Voice Call Button] ──────────────► Voice Call Page (WebRTC)   │    │
│  │  └── [Back Arrow] ─────────────────────► Messages List              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔔 4.3 NOTIFICATIONS PAGE

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                   4.3 NOTIFICATIONS PAGE (/notifications)                    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                  NOTIFICATIONS PAGE ACTIONS                          │    │
│  │                                                                      │    │
│  │  Notification Types & Actions:                                       │    │
│  │  ├── [Like Notification] ──────────────► Post Detail                │    │
│  │  ├── [Comment Notification] ───────────► Post Detail (comments)     │    │
│  │  ├── [Follow Notification] ────────────► User Profile               │    │
│  │  ├── [Message Notification] ───────────► Chat Page                  │    │
│  │  ├── [Mention Notification] ───────────► Post Detail                │    │
│  │  └── [System Notification] ────────────► Relevant Page              │    │
│  │                                                                      │    │
│  │  Header Actions:                                                     │    │
│  │  ├── [Mark All Read] ──────────────────► Clear Unread Badges        │    │
│  │  └── [Settings Icon] ──────────────────► Notification Settings      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 👤 4.4 PROFILE PAGE

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      4.4 PROFILE PAGE (/profile)                             │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                     MY PROFILE PAGE ACTIONS                          │    │
│  │                                                                      │    │
│  │  Profile Header:                                                     │    │
│  │  ├── [Edit Profile Button] ────────────► Edit Profile Page          │    │
│  │  ├── [Settings Gear Icon] ─────────────► Settings Menu              │    │
│  │  └── [Share Profile] ──────────────────► Share Sheet                │    │
│  │                                                                      │    │
│  │  Profile Stats:                                                      │    │
│  │  ├── [Posts Count] ────────────────────► My Posts Grid              │    │
│  │  ├── [Followers Count] ────────────────► Followers List             │    │
│  │  └── [Following Count] ────────────────► Following List             │    │
│  │                                                                      │    │
│  │  Profile Tabs:                                                       │    │
│  │  ├── [Posts Tab] ──────────────────────► Grid of My Posts           │    │
│  │  ├── [Saved Tab] ──────────────────────► Bookmarked Posts           │    │
│  │  └── [Tagged Tab] ─────────────────────► Posts I'm Tagged In        │    │
│  │                                                                      │    │
│  │  Settings Menu Options:                                              │    │
│  │  ├── [Theme Settings] ─────────────────► 4.4.1 Theme Settings       │    │
│  │  ├── [Location Settings] ──────────────► 4.4.2 Location Settings    │    │
│  │  ├── [Interests] ──────────────────────► 4.4.3 Interests Management │    │
│  │  ├── [Notification Schedule] ──────────► 4.4.4 Notification Schedule│    │
│  │  ├── [Language] ───────────────────────► Language Settings          │    │
│  │  ├── [Privacy & Security] ─────────────► Privacy Settings           │    │
│  │  ├── [Help & Support] ─────────────────► Help Page                  │    │
│  │  └── [Logout] ─────────────────────────► Confirm → Login Page       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      PROFILE SETTINGS PAGES                          │    │
│  │                                                                      │    │
│  │  4.4.1 Theme Settings (/profile/theme-settings)                      │    │
│  │  ├── [Light/Dark/System Toggle] ───────► Apply Theme                │    │
│  │  ├── [Custom Primary Color] ───────────► Color Picker               │    │
│  │  └── [Back] ───────────────────────────► Profile Page               │    │
│  │                                                                      │    │
│  │  4.4.2 Location Settings (/profile/location-settings)               │    │
│  │  ├── [Enable/Disable Location] ────────► Toggle Permission          │    │
│  │  ├── [Set Custom Location] ────────────► Location Picker            │    │
│  │  └── [Back] ───────────────────────────► Profile Page               │    │
│  │                                                                      │    │
│  │  4.4.3 Interests Management (/profile/interests-management)         │    │
│  │  ├── [Add/Remove Interests] ───────────► Update Firestore           │    │
│  │  ├── [Save Changes] ───────────────────► Confirm & Back             │    │
│  │  └── [Back] ───────────────────────────► Profile Page               │    │
│  │                                                                      │    │
│  │  4.4.4 Notification Schedule (/profile/notification-schedule)       │    │
│  │  ├── [Set Quiet Hours] ────────────────► Time Picker                │    │
│  │  ├── [Toggle Notification Types] ──────► Enable/Disable             │    │
│  │  └── [Back] ───────────────────────────► Profile Page               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## ✏️ Section 5: Full-Screen Action Pages

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      FULL-SCREEN ACTION PAGES                                │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              5.1 CREATE POST PAGE (/create-post)                     │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Add Photo] ──────────────────────► Image Picker               │    │
│  │  ├── [Add Video] ──────────────────────► Video Picker → Editor      │    │
│  │  ├── [Write Caption] ──────────────────► Text Input                 │    │
│  │  ├── [Add Location] ───────────────────► "Coming Soon"              │    │
│  │  ├── [Tag People] ─────────────────────► "Coming Soon"              │    │
│  │  ├── [Select Template] ────────────────► Template Picker            │    │
│  │  ├── [Post Button] ────────────────────► Upload → Home Feed         │    │
│  │  └── [X Close] ────────────────────────► Confirm Discard → Home     │    │
│  │                                                                      │    │
│  │  Sub-pages:                                                          │    │
│  │  └── 5.1.1 Video Editor (/create-post/video-editor)                 │    │
│  │      ├── [Trim Video] ─────────────────► Trim Controls              │    │
│  │      ├── [Add Music] ──────────────────► "Coming Soon"              │    │
│  │      ├── [Add Voiceover] ──────────────► Voice Recorder             │    │
│  │      ├── [Add Effects] ────────────────► Effects Panel              │    │
│  │      └── [Done] ───────────────────────► Back to Create Post        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              5.2 RATE DATE PAGE (/rate-date)                         │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Select Rating] ──────────────────► WOW / GTFOH / ChekMate     │    │
│  │  ├── [Write Experience] ───────────────► Text Input                 │    │
│  │  ├── [Add Photos] ─────────────────────► Image Picker               │    │
│  │  ├── [Select Template] ────────────────► Template Options           │    │
│  │  │   ├── First Date Template                                        │    │
│  │  │   ├── Red Flag Alert Template                                    │    │
│  │  │   ├── Success Story Template                                     │    │
│  │  │   ├── Catfish Alert Template                                     │    │
│  │  │   ├── Dating Advice Template                                     │    │
│  │  │   ├── Venue Review Template                                      │    │
│  │  │   └── General Experience Template                                │    │
│  │  ├── [Post Rating] ────────────────────► Upload → Home Feed         │    │
│  │  └── [X Close] ────────────────────────► Confirm Discard → Home     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              5.3 USER PROFILE PAGE (/profile/:userId)                │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Follow/Unfollow Button] ─────────► Toggle Follow              │    │
│  │  ├── [Message Button] ─────────────────► Chat Page                  │    │
│  │  ├── [Tap Post] ───────────────────────► Post Detail                │    │
│  │  ├── [Report User] ────────────────────► Report Dialog              │    │
│  │  ├── [Block User] ─────────────────────► Confirm Block              │    │
│  │  └── [Back Arrow] ─────────────────────► Previous Page              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              5.4 POST DETAIL PAGE (/post/:postId)                    │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Like/Unlike] ────────────────────► Toggle Like                │    │
│  │  ├── [Chek/Unchek] ────────────────────► Toggle Chek                │    │
│  │  ├── [Add Comment] ────────────────────► Comment Input              │    │
│  │  ├── [Share] ──────────────────────────► Share Sheet                │    │
│  │  ├── [Bookmark] ───────────────────────► Toggle Bookmark            │    │
│  │  ├── [Tap Username] ───────────────────► User Profile               │    │
│  │  ├── [Report Post] ────────────────────► Report Dialog              │    │
│  │  └── [Back/Close] ─────────────────────► Previous Page              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              5.5 SUBSCRIBE PAGE (/subscribe)                         │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Select Plan] ────────────────────► Highlight Plan             │    │
│  │  ├── [Subscribe Button] ───────────────► Payment Flow               │    │
│  │  ├── [Restore Purchases] ──────────────► Check Subscriptions        │    │
│  │  └── [Back/Close] ─────────────────────► Previous Page              │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📺 Section 6: Live & Stories (Fully Implemented)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LIVE & STORIES                                       │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              6.1 LIVE PAGE (/live)                                   │    │
│  │              ✅ FULLY IMPLEMENTED - WebRTC + Firebase                │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Go Live Button] ─────────────────► Go Live Page (Broadcast)   │    │
│  │  ├── [Tap Live Stream] ────────────────► Watch Live Page (Viewer)   │    │
│  │  ├── [Category Filter] ────────────────► Filter Streams             │    │
│  │  ├── [Send Chat Message] ──────────────► Real-time Chat             │    │
│  │  ├── [Like Stream] ────────────────────► Increment Likes            │    │
│  │  └── [Toggle Camera/Mic] ──────────────► WebRTC Controls            │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │              6.2 STORY VIEWER                                        │    │
│  │              ✅ Viewer Works - Creation Partial                      │    │
│  │                                                                      │    │
│  │  User Actions:                                                       │    │
│  │  ├── [Tap Left] ───────────────────────► Previous Story             │    │
│  │  ├── [Tap Right] ──────────────────────► Next Story                 │    │
│  │  ├── [Hold] ───────────────────────────► Pause Story                │    │
│  │  ├── [Swipe Down] ─────────────────────► Close Viewer               │    │
│  │  ├── [Reply Input] ────────────────────► Send Reply Message         │    │
│  │  └── [Tap Username] ───────────────────► User Profile               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🗺️ Complete Route Map

| # | Route Path | Page Name | Transition | Nav Bar |
|---|------------|-----------|------------|---------|
| 1 | `/splash` | SplashScreen | Fade | Hidden |
| 2.1 | `/auth/login` | LoginPage | Fade | Hidden |
| 2.2 | `/auth/signup` | SignUpPage | Fade | Hidden |
| 2.3 | `/auth/two-factor-verification` | TwoFactorVerificationPage | Fade | Hidden |
| 3.1 | `/onboarding/welcome` | WelcomeScreen | SharedAxis | Hidden |
| 3.2 | `/onboarding/interests` | InterestsScreen | SharedAxis | Hidden |
| 3.3 | `/onboarding/location` | LocationScreen | SharedAxis | Hidden |
| 3.4 | `/onboarding/profile-photo` | ProfilePhotoScreen | SharedAxis | Hidden |
| 3.5 | `/onboarding/completion` | CompletionScreen | SharedAxis | Hidden |
| 4.1 | `/` | HomePage | Default | Visible |
| 4.1.3 | `/explore` | ExplorePage | FadeThrough | Visible |
| 4.1.4 | `/live` | LivePageNew | SlideUp | Visible |
| 4.1.5 | `/subscribe` | SubscribePage | SharedAxis | Visible |
| 4.2 | `/messages` | MessagesPage | SlideRight | Visible |
| 4.2.1 | `/chat/:conversationId` | ChatPage | SlideUp | Hidden |
| 4.3 | `/notifications` | NotificationsPage | SlideRight | Visible |
| 4.4 | `/profile` | MyProfilePage | SharedAxis | Visible |
| 4.4.1 | `/profile/theme-settings` | ThemeSettingsPage | SlideRight | Hidden |
| 4.4.2 | `/profile/location-settings` | LocationSettingsPage | SlideRight | Hidden |
| 4.4.3 | `/profile/interests-management` | InterestsManagementPage | SlideRight | Hidden |
| 4.4.4 | `/profile/notification-schedule-settings` | NotificationScheduleSettingsPage | SlideRight | Hidden |
| 5.1 | `/create-post` | CreatePostPage | SlideUp | Hidden |
| 5.2 | `/rate-date` | RateDatePage | SlideUp | Visible |
| 5.3 | `/profile/:userId` | UserProfilePage | SharedAxis | Hidden |
| 5.4 | `/post/:postId` | PostDetailModal | SlideUp | Hidden |

---

## 🔄 State Management Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         RIVERPOD PROVIDERS                                   │
│                                                                              │
│  Authentication:                                                             │
│  ├── authControllerProvider ──────────► Manages login/logout/signup         │
│  ├── authStateProvider ───────────────► Current auth state                  │
│  └── isAuthenticatedProvider ─────────► Boolean auth check                  │
│                                                                              │
│  Navigation:                                                                 │
│  ├── appRouterEnhancedProvider ───────► GoRouter instance                   │
│  ├── bottomNavTabProvider ────────────► Current bottom tab                  │
│  └── topNavTabProvider ───────────────► Current top tab (Home)              │
│                                                                              │
│  Onboarding:                                                                 │
│  ├── onboardingStateProvider ─────────► Onboarding progress                 │
│  └── isOnboardingCompletedProvider ───► Firestore check                     │
│                                                                              │
│  Feed:                                                                       │
│  ├── feedProvider ────────────────────► Posts stream                        │
│  ├── postsProvider ───────────────────► Posts CRUD                          │
│  └── feedAlgorithmProvider ───────────► Hybrid algorithm                    │
│                                                                              │
│  User:                                                                       │
│  ├── currentUserProvider ─────────────► Current user data                   │
│  ├── userProfileProvider ─────────────► Profile data                        │
│  └── wisdomScoreProvider ─────────────► Gamification score                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## ✅ Feature Implementation Status

| Feature | Status | Location |
|---------|--------|----------|
| Video/Voice Calls | ✅ IMPLEMENTED | Chat Page - WebRTC |
| Live Streaming | ✅ IMPLEMENTED | /live - WebRTC + Firebase |
| Music Library | 🟡 UI Only | Video Editor |
| Tag People | 🟡 UI Only | Create Post |
| Location Search | 🟡 UI Only | Create Post |
| Notification Settings | ✅ IMPLEMENTED | Profile Settings |

---

**Document Version**: 1.0  
**Last Updated**: November 29, 2025  
**Maintained By**: ChekMate Development Team
