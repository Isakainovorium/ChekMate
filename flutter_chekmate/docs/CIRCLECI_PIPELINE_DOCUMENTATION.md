# CircleCI Pipeline Documentation

**ChekMate Flutter App - Comprehensive CI/CD Guide**  
**Version:** 2.1.0  
**Last Updated:** October 18, 2025  
**Phase:** 5 - Polish & Differentiation

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Pipeline Architecture](#pipeline-architecture)
3. [Executors](#executors)
4. [Commands](#commands)
5. [Jobs](#jobs)
6. [Workflows](#workflows)
7. [Performance Testing](#performance-testing)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)
10. [Maintenance](#maintenance)

---

## 🎯 OVERVIEW

### Purpose
The CircleCI pipeline for ChekMate provides automated testing, validation, and quality assurance for the Flutter application across multiple platforms (iOS, Android) and feature areas.

### Key Features
- ✅ **Multi-Platform Testing** - iOS and Android specific tests
- ✅ **Performance Monitoring** - Video and animation performance tracking
- ✅ **Security Validation** - Firebase version checking, build artifact verification
- ✅ **Code Quality** - Static analysis, formatting checks, test coverage
- ✅ **Feature Validation** - FCM, location services, animations, image processing
- ✅ **Automated Reporting** - Coverage reports, performance metrics, test results

### Pipeline Evolution
- **Phase 1:** Basic Flutter testing (analyze, test, coverage)
- **Phase 2:** Platform-specific testing (iOS, Android, video performance)
- **Phase 3:** Image processing validation (SVG, multi-photo, carousel)
- **Phase 4:** Advanced integrations (FCM, location services)
- **Phase 5:** Animation performance testing (flutter_animate, shared elements)

---

## 🏗️ PIPELINE ARCHITECTURE

### Workflow Stages

```
┌─────────────────────────────────────────────────────────────┐
│                    PHASE 1: VERIFICATION                     │
│  (Parallel - All must pass before proceeding)                │
├─────────────────────────────────────────────────────────────┤
│  • verify_firebase          • verify_fcm_packages            │
│  • verify_build_artifacts   • verify_location_packages       │
│  • verify_svg               • verify_animation_packages      │
│  • verify_images                                             │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              PHASE 2: ANALYSIS & TESTING                     │
│  (Parallel - After verification)                             │
├─────────────────────────────────────────────────────────────┤
│  • analyze (static analysis, formatting)                     │
│  • test (unit tests with coverage)                           │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│         PHASE 3: PLATFORM-SPECIFIC TESTING                   │
│  (Parallel - After tests)                                    │
├─────────────────────────────────────────────────────────────┤
│  • test_android (Android build, permissions, APK)            │
│  • test_ios (iOS build, permissions, app bundle)             │
│  • test_video_performance (video player metrics)             │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│          PHASE 4: ADVANCED TESTING                           │
│  (Parallel - After platform tests)                           │
├─────────────────────────────────────────────────────────────┤
│  • test_fcm_ios (iOS FCM, APNs, notifications)               │
│  • test_fcm_android (Android FCM, channels)                  │
│  • test_location_services (geolocator, geocoding)            │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│       PHASE 5: ANIMATION PERFORMANCE TESTING                 │
│  (After tests)                                               │
├─────────────────────────────────────────────────────────────┤
│  • test_animation_performance (flutter_animate, 60 FPS)      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│            PHASE 6: COVERAGE REPORTING                       │
│  (After all tests)                                           │
├─────────────────────────────────────────────────────────────┤
│  • coverage_report (lcov, HTML reports, thresholds)          │
└─────────────────────────────────────────────────────────────┘
```

### Execution Time
- **Verification Phase:** ~2-3 minutes
- **Analysis & Testing:** ~5-8 minutes
- **Platform Testing:** ~15-20 minutes (iOS takes longer)
- **Advanced Testing:** ~10-15 minutes
- **Animation Performance:** ~3-5 minutes
- **Coverage Reporting:** ~2-3 minutes
- **Total Pipeline:** ~40-55 minutes

---

## 🖥️ EXECUTORS

### flutter-executor
**Purpose:** Linux-based Flutter environment for most jobs

**Configuration:**
```yaml
docker:
  - image: ghcr.io/cirruslabs/flutter:3.24.3
resource_class: medium
working_directory: ~/project/flutter_chekmate
environment:
  FLUTTER_HOME: /sdks/flutter
```

**Used By:**
- analyze
- test
- verify_* jobs
- test_android
- test_video_performance
- test_fcm_android
- test_location_services
- test_animation_performance
- coverage_report

### macOS Executor (iOS Testing)
**Purpose:** macOS environment for iOS-specific testing

**Configuration:**
```yaml
macos:
  xcode: "15.0.0"
working_directory: ~/project/flutter_chekmate
environment:
  FLUTTER_VERSION: "3.24.3"
```

**Used By:**
- test_ios
- test_fcm_ios

**Note:** macOS executors are more expensive and slower to provision. Use sparingly.

---

## 🔧 COMMANDS

### setup_flutter
**Purpose:** Initialize Flutter SDK and dependencies

**Steps:**
1. Checkout code from repository
2. Run `flutter doctor -v` (verify Flutter installation)
3. Run `flutter pub get` (install dependencies)
4. Run `flutter pub run build_runner build --delete-conflicting-outputs` (generate Riverpod code)

**Usage:**
```yaml
steps:
  - setup_flutter
```

**Duration:** ~2-3 minutes

---

### verify_firebase_versions
**Purpose:** Ensure Firebase packages use pinned versions (no 'any')

**Checks:**
- Scans `pubspec.yaml` for Firebase packages with 'any' version
- Fails if any Firebase package uses 'any'
- Passes if all Firebase packages have specific versions

**Why Important:**
- Security: Prevents unexpected breaking changes
- Reproducibility: Ensures consistent builds
- Compliance: Meets production deployment standards

**Example Output:**
```
✅ All Firebase packages have specific versions
```

---

### verify_animation_packages
**Purpose:** Verify animation packages are configured for Phase 5

**Checks:**
- flutter_animate package (TikTok-style animations)
- animations package (shared element transitions)
- flutter_staggered_grid_view package (Instagram Explore-style grids)

**Example Output:**
```
✅ flutter_animate package found
flutter_animate version: ^4.5.0
✅ animations package found
animations version: ^2.0.8
✅ flutter_staggered_grid_view package found
flutter_staggered_grid_view version: ^0.7.0
```

---

### verify_no_build_artifacts
**Purpose:** Ensure build/ directory is not committed to repository

**Checks:**
- Verifies build/ directory does not exist in repository
- Fails if build/ directory is found
- Passes if no build artifacts are committed

**Why Important:**
- Repository size: Build artifacts can be 100+ MB
- Clean repository: Only source code should be versioned
- CI/CD efficiency: Faster clones and checkouts

---

## 📊 JOBS

### Job 1: analyze
**Purpose:** Static code analysis and formatting checks

**Steps:**
1. Setup Flutter
2. Run `flutter analyze --no-fatal-infos`
3. Run `flutter format --set-exit-if-changed lib/ test/`

**Success Criteria:**
- No analysis errors
- Code is properly formatted

**Duration:** ~3-4 minutes

---

### Job 2: test
**Purpose:** Run unit tests with coverage

**Steps:**
1. Setup Flutter
2. Run `flutter test --coverage`
3. Generate HTML coverage report with lcov
4. Store coverage artifacts

**Artifacts:**
- `coverage/lcov.info` - Coverage data
- `coverage/html/` - HTML coverage report

**Duration:** ~4-6 minutes

---

### Job 7: test_android
**Purpose:** Android-specific testing and build verification

**Steps:**
1. Setup Flutter
2. Run Android-specific tests
3. Verify Android permissions (microphone, camera, storage)
4. Build Android APK (`flutter build apk --debug`)
5. Verify APK is valid

**Artifacts:**
- `build/app/outputs/flutter-apk/app-debug.apk`

**Duration:** ~8-12 minutes

---

### Job 8: test_ios
**Purpose:** iOS-specific testing and build verification

**Steps:**
1. Install Flutter on macOS
2. Run iOS-specific tests
3. Verify iOS permissions (microphone, camera, photo library)
4. Build iOS app (`flutter build ios --debug --no-codesign`)
5. Verify app bundle is valid

**Artifacts:**
- `build/ios/iphoneos/Runner.app`

**Duration:** ~12-18 minutes (macOS provisioning is slow)

---

### Job 12: test_animation_performance
**Purpose:** Validate animation implementations and performance

**Steps:**
1. Setup Flutter
2. Verify animation packages (flutter_animate, animations)
3. Check animation widget implementations
4. Run animation performance tests
5. Generate animation performance report

**Checks:**
- TikTok-style animations file exists
- Shared element transitions file exists
- Hero animations file exists
- Animation methods implemented (fadeIn, slideIn, scale)

**Performance Targets:**
- **Target FPS:** 60 FPS (16.67ms per frame)
- **Animation Duration:** 200-400ms
- **Jank Threshold:** <16.67ms frame time

**Artifacts:**
- `animation_performance_report.md` - Detailed performance analysis
- `animation_performance_results.json` - Test results

**Duration:** ~3-5 minutes

---

## 🔄 WORKFLOWS

### build_and_test (Main Workflow)
**Trigger:** Every commit to any branch

**Stages:**
1. Verification (parallel)
2. Analysis & Testing (parallel, after verification)
3. Platform Testing (parallel, after tests)
4. Advanced Testing (parallel, after platform tests)
5. Animation Performance (after tests)
6. Coverage Reporting (after all tests)

**Total Duration:** ~40-55 minutes

---

### nightly (Scheduled Workflow)
**Trigger:** Daily at midnight UTC (cron: "0 0 * * *")

**Branches:** master, main only

**Purpose:**
- Comprehensive testing during off-hours
- Catch issues that may not appear in PR testing
- Generate nightly performance reports

**Same stages as build_and_test workflow**

---

## 🚀 PERFORMANCE TESTING

### Animation Performance Testing

**What We Test:**
1. **Package Verification**
   - flutter_animate installed and configured
   - animations package installed
   - flutter_staggered_grid_view installed

2. **Implementation Verification**
   - TikTok-style animations file exists
   - Shared element transitions implemented
   - Hero animations implemented
   - Animation methods present (fadeIn, slideIn, scale, etc.)

3. **Performance Metrics** (Future)
   - Frame rate during animations (target: 60 FPS)
   - Animation smoothness (jank detection)
   - Memory usage during animations
   - CPU usage during animations

**Performance Report Contents:**
- Package versions
- Animation implementations found
- Performance targets (60 FPS, 16.67ms frame time)
- Recommendations for optimization
- Next steps for device-based testing

**Example Report:**
```markdown
# Animation Performance Report

**Date:** 2025-10-18
**Branch:** master
**Commit:** abc123

## Package Versions
- flutter_animate: ^4.5.0
- animations: ^2.0.8

## Animation Implementations
### TikTok-Style Animations
- Animation methods found: 15
- ✅ TikTok-style animations implemented

### Shared Element Transitions
- ✅ Shared element transitions implemented

### Hero Animations
- ✅ Hero animations implemented

## Performance Targets
- **Target FPS:** 60 FPS (16.67ms per frame)
- **Animation Duration:** 200-400ms
- **Jank Threshold:** <16.67ms frame time

## Recommendations
- ✅ Use flutter_animate for declarative animations
- ✅ Implement shared element transitions
- ✅ Use Hero widgets for image transitions
- 📊 Add device-based FPS testing
```

---

## 🔍 TROUBLESHOOTING

### Common Issues

#### 1. Firebase Version Check Fails
**Error:** `ERROR: Found Firebase packages with 'any' version!`

**Solution:**
```yaml
# ❌ Bad
firebase_core: any

# ✅ Good
firebase_core: ^2.24.2
```

Update all Firebase packages in `pubspec.yaml` to specific versions.

---

#### 2. Build Artifacts in Repository
**Error:** `ERROR: build/ directory found in repository!`

**Solution:**
```bash
# Remove build directory
git rm -r build/

# Update .gitignore
echo "build/" >> .gitignore

# Commit changes
git add .gitignore
git commit -m "Remove build artifacts and update .gitignore"
```

---

#### 3. iOS Build Fails
**Error:** `ERROR: iOS app bundle not found`

**Possible Causes:**
- Xcode version mismatch
- Missing iOS dependencies
- Code signing issues

**Solution:**
```bash
# Clean iOS build
cd ios
pod deintegrate
pod install
cd ..

# Rebuild
flutter clean
flutter pub get
flutter build ios --debug --no-codesign
```

---

#### 4. Animation Performance Tests Fail
**Error:** `❌ ERROR: flutter_animate package not found`

**Solution:**
```bash
# Add flutter_animate to pubspec.yaml
flutter pub add flutter_animate

# Add animations package
flutter pub add animations

# Run pub get
flutter pub get
```

---

## ✅ BEST PRACTICES

### 1. Keep Pipeline Fast
- Use parallel jobs where possible
- Cache dependencies (Flutter SDK, pub cache)
- Minimize macOS executor usage (expensive)
- Run expensive tests only on main branches

### 2. Fail Fast
- Run verification jobs first (fast, catch common issues)
- Run static analysis before tests
- Use `--no-fatal-infos` for analyze (warnings don't fail build)

### 3. Comprehensive Testing
- Test on both iOS and Android
- Include platform-specific permission checks
- Validate build artifacts (APK, app bundle)
- Monitor performance metrics

### 4. Clear Reporting
- Store artifacts for debugging
- Generate human-readable reports
- Include version information in reports
- Provide actionable recommendations

### 5. Security & Quality
- Pin all dependency versions
- Verify no build artifacts in repository
- Maintain test coverage thresholds
- Run security scans (future enhancement)

---

## 🛠️ MAINTENANCE

### Regular Tasks

#### Weekly
- Review failed builds and fix issues
- Check coverage trends (should be increasing)
- Monitor pipeline duration (should be <60 minutes)

#### Monthly
- Update Flutter SDK version in executor
- Update Xcode version for iOS testing
- Review and update dependency versions
- Optimize slow jobs

#### Quarterly
- Review and update performance targets
- Add new verification checks as features are added
- Update documentation with new jobs/workflows
- Conduct pipeline performance audit

### Adding New Jobs

**Template:**
```yaml
new_job_name:
  executor: flutter-executor
  steps:
    - setup_flutter
    - run:
        name: "Descriptive Step Name"
        command: |
          echo "What this step does..."
          # Your commands here
    - store_artifacts:
        path: output/
        destination: artifacts/
```

**Checklist:**
- [ ] Add job to appropriate workflow stage
- [ ] Set correct dependencies (requires)
- [ ] Store relevant artifacts
- [ ] Update this documentation
- [ ] Test on feature branch first

---

## 📚 ADDITIONAL RESOURCES

### CircleCI Documentation
- [CircleCI Docs](https://circleci.com/docs/)
- [Flutter Orb](https://circleci.com/developer/orbs/orb/circleci/flutter)
- [Workflows](https://circleci.com/docs/workflows/)

### ChekMate Documentation
- [PHASE_TRACKER.md](./PHASE_TRACKER.md) - Project progress
- [PROJECT_CONTEXT.md](./PROJECT_CONTEXT.md) - Architecture decisions
- [IMPLEMENTATION_BEST_PRACTICES.md](./IMPLEMENTATION_BEST_PRACTICES.md) - Coding standards

### CircleCI MCP Tools
- `config_helper_CircleCI` - Validate config syntax
- `run_pipeline_CircleCI` - Trigger pipelines
- `get_build_failure_logs_CircleCI` - Debug failures
- `find_flaky_tests_CircleCI` - Identify flaky tests

---

**Last Updated:** October 18, 2025  
**Maintained By:** ChekMate Development Team  
**Questions?** See [CIRCLECI_MCP_INTEGRATION.md](./CIRCLECI_MCP_INTEGRATION.md)

