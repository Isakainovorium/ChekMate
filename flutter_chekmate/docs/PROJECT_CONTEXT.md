# ChekMate Project Context

**Last Updated:** October 16, 2025  
**Current Phase:** Phase 0 - Setup & Planning  
**Project Status:** Planning Complete, Implementation Starting  
**Maintainer:** ChekMate Development Team

---

## 📋 TABLE OF CONTENTS

1. [Project Overview](#project-overview)
2. [Architectural Decision Records (ADR)](#architectural-decision-records-adr)
3. [User Preferences & Coding Style](#user-preferences--coding-style)
4. [Strategic Decisions](#strategic-decisions)
5. [Technology Stack](#technology-stack)
6. [Key Implementation Patterns](#key-implementation-patterns)
7. [Critical Context](#critical-context)

---

## 1. PROJECT OVERVIEW

### **What is ChekMate?**
ChekMate is a Flutter-based social media/dating hybrid mobile application that combines features from TikTok, Instagram, Bumble, and Hinge.

### **Target Audience**
Young adults (18-35) looking for authentic connections through visual content and interactive features.

### **Core Features**
- TikTok-like camera and video editing
- Instagram-style multi-photo posts and stories
- Bumble-inspired voice prompts and voice messages
- Location-based matching and tagging
- Real-time messaging with rich media
- Live streaming capabilities
- Push notifications and engagement features

### **Current State**
- **Codebase:** 173 Dart files, 130.95 MB total (126 MB build artifacts)
- **Test Coverage:** 4% (7 test files)
- **Dependencies:** 70 packages (19 actively used, 51 to implement)
- **Architecture:** Mixed patterns, needs Clean Architecture migration
- **Firebase:** Using dangerous "any" versions (critical security issue)

### **Project Goals**
1. Implement all 51 unused packages for competitive feature parity
2. Achieve 80%+ test coverage
3. Migrate to Clean Architecture (3-layer: Data, Domain, Presentation)
4. Fix Firebase version security issues
5. Remove 126 MB build artifacts (96% size reduction)
6. Establish production-ready CI/CD pipeline

---

## 2. ARCHITECTURAL DECISION RECORDS (ADR)

### **ADR-001: Keep All 70 Dependencies**
- **Date:** October 16, 2025
- **Status:** ✅ APPROVED
- **Decision:** Keep all 70 packages, implement 51 unused packages instead of removing 23
- **Rationale:**
  - User challenged initial recommendation to remove 23 packages
  - Competitive analysis shows all packages provide strategic value
  - Real bloat is 126 MB build artifacts (96%), not 2-3 MB dependencies (2%)
  - Missing features hurt more than app size for social/dating apps
  - Voice features specifically requested by user (record package)
- **Consequences:**
  - 51 new features to implement over 6 weeks
  - Competitive parity with TikTok, Instagram, Bumble
  - Larger dependency footprint, but justified by features
- **References:** `docs/WHY_KEEP_ALL_70_DEPENDENCIES.md`, `docs/DEPENDENCY_ANALYSIS_REPORT.md`

### **ADR-002: Voice Message Duration Limit**
- **Date:** October 16, 2025
- **Status:** ✅ DECIDED, NOT YET IMPLEMENTED
- **Decision:** 60 seconds maximum for voice messages
- **Rationale:**
  - Instagram-style voice messages (quick, personal)
  - Not podcast-length recordings
  - Reduces storage costs
  - Encourages concise communication
- **Implementation:**
  - Validate in use case layer (`SendVoiceMessageUseCase`)
  - Enforce in Firebase Security Rules
  - Show timer UI during recording
  - Warn user at 50 seconds
- **References:** `docs/IMPLEMENTATION_ROADMAP_ALL_70_PACKAGES.md` (Phase 2)

### **ADR-003: Clean Architecture Pattern**
- **Date:** October 16, 2025
- **Status:** ✅ DECIDED, NOT YET IMPLEMENTED
- **Decision:** Adopt Clean Architecture with 3 layers (Data, Domain, Presentation)
- **Rationale:**
  - Current codebase has duplicate structures (lib/features/ vs lib/pages/)
  - Mixed state management patterns
  - Difficult to test business logic
  - Industry standard for Flutter apps
- **Implementation:**
  - Feature-first organization: `lib/features/{feature_name}/`
  - Each feature has data/, domain/, presentation/ folders
  - Domain layer is pure Dart (no Flutter/Firebase dependencies)
  - Repositories defined in domain, implemented in data
- **References:** `docs/IMPLEMENTATION_BEST_PRACTICES.md` (Section 1)

### **ADR-004: Riverpod for State Management**
- **Date:** October 16, 2025
- **Status:** ✅ DECIDED, PARTIALLY IMPLEMENTED
- **Decision:** Use Riverpod as primary state management solution
- **Rationale:**
  - Already declared in pubspec.yaml
  - Compile-time safety
  - Better testability than Provider
  - Supports code generation (riverpod_annotation, riverpod_generator)
- **Implementation:**
  - Use Provider for dependencies (services, repositories)
  - Use StateProvider for simple toggles
  - Use FutureProvider for one-time async data
  - Use StreamProvider for real-time data (Firestore)
  - Use StateNotifierProvider for complex state
- **References:** `docs/IMPLEMENTATION_BEST_PRACTICES.md` (Section 2)

### **ADR-005: Context Management System**
- **Date:** October 16, 2025
- **Status:** ✅ APPROVED, IN PROGRESS
- **Decision:** Use documentation-based context management + LangChain MCP
- **Rationale:**
  - 6-week project needs persistent context across AI sessions
  - Documentation-based approach is version controlled and human-readable
  - LangChain MCP provides real-time access to latest package docs
  - Complementary tools (memory vs real-time knowledge)
- **Implementation:**
  - PROJECT_CONTEXT.md: Architectural decisions, preferences, status
  - PHASE_TRACKER.md: Real-time progress tracking
  - AI_ASSISTANT_BRIEFING.md: Quick-start for any AI
  - LangChain MCP: Real-time documentation access during implementation
- **References:** This document, `docs/LANGCHAIN_MCP_SETUP.md`

### **ADR-006: Firebase Version Security Fix**
- **Date:** October 16, 2025
- **Status:** ✅ CRITICAL, NOT YET IMPLEMENTED
- **Decision:** Fix all Firebase packages using "any" versions immediately in Phase 1
- **Rationale:**
  - Using "any" versions is a critical security vulnerability
  - Can break app with automatic updates
  - Production apps must use pinned versions
- **Implementation:**
  - firebase_core: ^2.24.2
  - firebase_auth: ^4.16.0
  - cloud_firestore: ^4.14.0
  - firebase_storage: ^11.6.0
  - firebase_messaging: ^14.7.10
  - firebase_analytics: ^10.8.0
  - firebase_crashlytics: ^3.4.9
- **Priority:** P0-CRITICAL (Phase 1, Week 1)
- **References:** `docs/IMPLEMENTATION_ROADMAP_ALL_70_PACKAGES.md` (Phase 1)

### **ADR-007: Test Coverage Target**
- **Date:** October 16, 2025
- **Status:** ✅ DECIDED, NOT YET IMPLEMENTED
- **Decision:** Achieve 80%+ test coverage across all features
- **Rationale:**
  - Current coverage is 4% (7 test files for 173 source files)
  - Production apps need comprehensive testing
  - Prevents regressions during 6-week implementation
- **Implementation:**
  - Write tests alongside feature implementation (not after)
  - Unit tests: 80%+ for business logic (use cases, services)
  - Widget tests: 70%+ for UI components
  - Integration tests: Key user flows (login, create post, send message)
  - Golden tests: Critical UI components
- **References:** `docs/IMPLEMENTATION_BEST_PRACTICES.md` (Section 3)

### **ADR-008: CircleCI MCP Integration**
- **Date:** October 16, 2025
- **Status:** ✅ APPROVED, CONNECTED
- **Decision:** Integrate CircleCI MCP for automated CI/CD monitoring and testing
- **Rationale:**
  - Automate testing for all 51 package implementations
  - Platform-specific testing (iOS vs Android) critical for voice/video features
  - Real-time build monitoring and failure analysis
  - Flaky test detection to maintain 80%+ coverage target
  - Complements LangChain MCP (CircleCI monitors builds, LangChain provides docs for fixes)
- **Implementation:**
  - Project: ChekMate (circleci/Dgq4rnVu5NzPtG14JcVLsy/9V7jsYiK8dDGLSyi9ZRL7S)
  - Branch: master
  - Config: .circleci/config.yml (to be created in Phase 1)
  - Integration: AI-assisted pipeline triggering, log analysis, test result monitoring
- **Impact:** Automated quality assurance, faster iteration, early bug detection
- **References:** `docs/CIRCLECI_MCP_INTEGRATION.md`

### **ADR-009: Voice Recording Package Selection**
- **Date:** October 17, 2025
- **Status:** ✅ DECIDED, READY FOR IMPLEMENTATION (Phase 2)
- **Decision:** Use `record` package (v5.0.0) for voice message recording
- **Rationale:**
  - Already in pubspec.yaml (`record: ^5.0.0`)
  - Cross-platform support (iOS, Android, Web, Windows, macOS, Linux)
  - No external dependencies (uses native APIs: AVAudioRecorder for iOS, MediaRecorder for Android)
  - Built-in permission handling with `hasPermission()` method
  - Multiple audio formats (AAC, Opus, WAV, PCM)
  - Stream and file-based recording support
  - Mature package with 22 code snippets in Context7
  - Clean, simple API
- **Implementation:**
  - **Audio Format:** AAC LC (m4a) - best compatibility and compression
  - **Configuration:**
    - Bitrate: 64 kbps (sufficient for voice, small file size)
    - Sample Rate: 22.05 kHz (good for voice quality)
    - Channels: Mono (voice doesn't need stereo)
    - Auto-gain: Enabled (normalize volume)
    - Echo Cancel: Enabled (remove echo)
    - Noise Suppress: Enabled (remove background noise)
  - **File Size:** ~300-400 KB for 60-second message
  - **Storage:** Record to temp directory → Upload to Firebase Storage → Delete local file
  - **Duration Limit:** 60 seconds (auto-stop with Timer)
  - **Permissions:**
    - iOS: `NSMicrophoneUsageDescription` in Info.plist
    - Android: `RECORD_AUDIO` permission in AndroidManifest.xml
- **Alternatives Considered:**
  - `flutter_sound`: More complex API, larger package
  - `audio_recorder`: Less maintained, fewer features
  - Native platform channels: Too much boilerplate
- **Consequences:**
  - Simple, clean implementation
  - Small file sizes (~300-400 KB per message)
  - Good voice quality
  - Cross-platform consistency
  - Built-in permission handling reduces code
- **References:** `docs/research/voice_recording.md`, `docs/PHASE_2_DETAILED_TASK_BREAKDOWN.md`

### **ADR-010: Firebase Storage Integration**
- **Date:** October 17, 2025
- **Status:** ✅ DECIDED, READY FOR IMPLEMENTATION (Phase 2)
- **Decision:** Use Firebase Cloud Storage for voice message file storage
- **Rationale:**
  - Already in pubspec.yaml (`firebase_storage: ^11.5.6`)
  - Scalable cloud storage for user-generated content
  - Built-in security rules (Firebase Security Rules v2)
  - Upload/download with progress tracking
  - Custom metadata support (userId, duration, messageId)
  - CDN-backed downloads (fast global access)
  - Integration with Firebase Authentication
  - Resumable uploads (automatic retry on network failure)
- **Implementation:**
  - **File Organization:** `voice_messages/{userId}/{fileName}`
  - **Security Rules:**
    - Require authentication for all operations
    - User can only upload to their own folder
    - Validate file type (audio/*) and size (5 MB max)
    - Require metadata (userId, duration)
    - Make files immutable (no updates, only create/delete)
    - Public read for voice messages (for chat playback)
  - **Metadata:**
    - contentType: `audio/m4a`
    - userId: Owner's Firebase Auth UID
    - messageId: Unique message identifier
    - duration: Recording duration in seconds
    - uploadedAt: ISO 8601 timestamp
  - **Upload Strategy:**
    - Resumable uploads with progress tracking
    - Retry logic (3 attempts)
    - Monitor network status
    - Delete local file after successful upload
  - **Download Strategy:**
    - Cache downloads in temp directory
    - Check cache before downloading
    - Monitor download progress
  - **Cost Optimization:**
    - Use 64 kbps bitrate (not 128 kbps) → 50% cost reduction
    - Implement 30-day auto-delete lifecycle rule
    - Cache downloads to reduce bandwidth
- **Cost Estimation (1,000 active users):**
  - Storage: ~$3.12/month (120 GB)
  - Uploads: ~$6.00/month (120 GB)
  - Downloads: ~$14.40/month (120 GB)
  - **Total:** ~$23.52/month
- **Alternatives Considered:**
  - AWS S3: More complex setup, no Firebase integration
  - Google Cloud Storage: Same backend, but Firebase SDK is simpler
  - Self-hosted: Too much infrastructure overhead
- **Consequences:**
  - Simple integration with Firebase Auth
  - Robust security rules
  - Scalable and reliable
  - Moderate costs (~$0.02/user/month)
  - CDN-backed downloads (fast)
- **References:** `docs/research/firebase_storage.md`, `docs/PHASE_2_DETAILED_TASK_BREAKDOWN.md`

---

## 3. USER PREFERENCES & CODING STYLE

### **Communication Style**
- Prefers systematic, SCRUM-based approach with phased roadmaps
- Values detailed planning before implementation
- Appreciates visual aids (Mermaid diagrams, tables)
- Wants comprehensive documentation
- Challenges recommendations (tests judgment)

### **Development Preferences**
- **Prefers fixing existing component wiring** over creating new files
- **Prefers TikTok/Instagram-style animations** that are visually impressive but performant
- **No major architectural changes** without clear justification
- **Systematic integration approach** with clear phases and milestones

### **Component Library**
- Built 56 enterprise-grade UI components across 5 categories:
  - Form components
  - Layout components
  - Feedback components
  - Data Display components
  - Loading/Progress components
- Only 4 components currently used (52 unused)
- Maintains comprehensive inventory in `superflex/FINAL_CHUNK_SUMMARY.md`

### **Code Quality Standards**
- Clean Architecture patterns (3-layer)
- Riverpod for state management
- 80%+ test coverage
- Meaningful variable/function names
- Comments explain "why", not "what"
- Files under 300 lines (split if larger)
- One class per file (except small helpers)

### **Git Workflow**
- Feature branches: `feature/{phase}-{package-name}-{description}`
- Commit format: `<type>(<scope>): <subject>` with body and footer
- Never commit to main directly (always use PRs)
- Delete merged branches
- Reference issues in commits (Closes #123)

---

## 4. STRATEGIC DECISIONS

### **Decision: Keep All 70 Packages (Oct 16, 2025)**
**Context:** Initial analysis recommended removing 23 "unused" packages to reduce bloat.

**User Challenge:** "record needs to stay that feature should be in the create post page inc take photo. go more in deoth as to why u want to delete those dependecie bc to mee they seem like features that would add to our app, even if we must implement another page. i test your judgment"

**Outcome:** Complete strategic pivot
- KEEP all 70 packages (0 removals)
- IMPLEMENT 51 unused packages
- Focus on removing 126 MB build artifacts (real bloat)
- Prioritize voice features (user-requested)

**Impact:**
- 6-week implementation roadmap (272 hours)
- Competitive parity with TikTok, Instagram, Bumble
- Voice messages, multi-photo posts, zoom, animations, notifications
- Feature-complete social/dating app

### **Decision: Use Both Context Docs + LangChain MCP (Oct 16, 2025)**
**Context:** User has LangChain API key, asked if it would help.

**Analysis:**
- Context docs solve: Memory across sessions, decision tracking
- LangChain MCP solves: Real-time documentation access, current examples
- Not overkill: Different purposes, complementary tools

**Outcome:** Implement both
- Context management system (this file, PHASE_TRACKER.md, AI_ASSISTANT_BRIEFING.md)
- LangChain MCP integration (for Phase 1-5 implementation)

---

## 5. TECHNOLOGY STACK

### **Frontend Framework**
- **Flutter:** Cross-platform mobile framework (iOS + Android)
- **Dart:** Programming language
- **Version:** (Check pubspec.yaml for current Flutter SDK version)

### **State Management**
- **flutter_riverpod:** Primary state management
- **riverpod_annotation:** Code generation annotations
- **riverpod_generator:** Code generation tool

### **Navigation**
- **go_router:** Declarative routing

### **Backend & Services**
- **Firebase Core:** firebase_core ^2.24.2 (to be fixed in Phase 1)
- **Authentication:** firebase_auth, google_sign_in, sign_in_with_apple
- **Database:** cloud_firestore
- **Storage:** firebase_storage
- **Messaging:** firebase_messaging
- **Analytics:** firebase_analytics
- **Crashlytics:** firebase_crashlytics

### **Media & Files**
- **Images:** image_picker, cached_network_image
- **Video:** video_player, camera
- **Audio:** record (voice messages, voiceovers)
- **Permissions:** permission_handler
- **File System:** path_provider, file_picker

### **UI & Theming**
- **Icons:** cupertino_icons
- **Fonts:** google_fonts
- **Images:** flutter_svg, cached_network_image
- **Loading:** shimmer, lottie
- **Animations:** flutter_animate, animations
- **Layouts:** flutter_staggered_grid_view, carousel_slider
- **Zoom:** photo_view

### **Networking**
- **HTTP Client:** dio
- **Connectivity:** connectivity_plus

### **Local Storage**
- **Preferences:** shared_preferences
- **Database:** hive, hive_flutter

### **Utilities**
- **Internationalization:** intl
- **UUID:** uuid
- **URL Launcher:** url_launcher
- **Share:** share_plus
- **Device Info:** package_info_plus, device_info_plus

### **Location**
- **GPS:** geolocator
- **Geocoding:** geocoding

### **Notifications**
- **Local:** flutter_local_notifications
- **Push:** firebase_messaging

### **Dev Tools**
- **UI Catalog:** widgetbook, widgetbook_annotation
- **Emoji Picker:** emoji_picker_flutter

---

## 6. KEY IMPLEMENTATION PATTERNS

### **Feature Structure**
```
lib/features/{feature_name}/
├── data/
│   ├── models/           # JSON serialization
│   ├── repositories/     # Repository implementations
│   └── datasources/      # Firebase/local data sources
├── domain/
│   ├── entities/         # Pure Dart business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business logic (one per file)
└── presentation/
    ├── pages/            # Full-screen pages
    ├── widgets/          # Reusable widgets
    └── providers/        # Riverpod providers
```

### **Naming Conventions**
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `lowerCamelCase`
- Private members: `_leadingUnderscore`

### **Import Order**
1. Dart imports
2. Flutter imports
3. Package imports (alphabetical)
4. Project imports (alphabetical)

---

## 7. CRITICAL CONTEXT

### **Must Remember Across Sessions**
1. **Keep all 70 packages** - Zero removals, 51 implementations
2. **Voice features are user priority** - Phase 2, record package
3. **Firebase versions are critical security issue** - Fix in Phase 1
4. **80%+ test coverage required** - Write tests alongside features
5. **Clean Architecture mandatory** - 3-layer pattern for all features
6. **Context docs must be updated** - Update PHASE_TRACKER.md after each phase

### **Current Project Phase**
- **Phase:** Phase 0 - Setup & Planning
- **Status:** Context management system being created
- **Next:** Configure LangChain MCP, then start Phase 1

### **Completed Deliverables (Oct 16, 2025)**
- ✅ IMPLEMENTATION_ROADMAP_ALL_70_PACKAGES.md (1,313 lines)
- ✅ Mermaid diagrams (Gantt chart + dependency flowchart)
- ✅ Task list (40+ tasks across 5 phases)
- ✅ ENTERPRISE_GRADE_RESTRUCTURING_PLAN.md (updated)
- ✅ IMPLEMENTATION_BEST_PRACTICES.md + PART2 (726 lines)
- ✅ DEPENDENCY_ANALYSIS_REPORT.md (817 lines)
- ✅ WHY_KEEP_ALL_70_DEPENDENCIES.md (300 lines)

### **Links to Key Documentation**
- Implementation Roadmap: `docs/IMPLEMENTATION_ROADMAP_ALL_70_PACKAGES.md`
- Phase Tracker: `docs/PHASE_TRACKER.md`
- AI Briefing: `docs/AI_ASSISTANT_BRIEFING.md`
- Best Practices: `docs/IMPLEMENTATION_BEST_PRACTICES.md`
- Dependency Analysis: `docs/DEPENDENCY_ANALYSIS_REPORT.md`
- LangChain Setup: `docs/LANGCHAIN_MCP_SETUP.md`

---

**Last Updated:** October 16, 2025  
**Next Update:** After Phase 0 completion  
**Maintainer:** ChekMate Development Team

