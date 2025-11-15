# CircleCI MCP - CI/CD Automation Guide

**Last Updated:** October 17, 2025  
**Tool:** CircleCI  
**Status:** ✅ Enabled (Phase 1)  
**Website:** https://circleci.com

---

## 📋 OVERVIEW

CircleCI MCP provides automated CI/CD capabilities for the ChekMate project, including test automation, build verification, coverage reporting, and deployment pipelines.

---

## 🎯 PROJECT CONFIGURATION

### **Project Details**
- **Project Slug:** `circleci/Dgq4rnVu5NzPtG14JcVLsy/9V7jsYiK8dDGLSyi9ZRL7S`
- **Branch:** `master`
- **Config File:** `.circleci/config.yml`
- **Free Tier:** 2,500 credits/month

### **Current Pipeline**

**Jobs (7):**
1. `analyze` - Flutter code analysis
2. `test` - Run unit/widget tests
3. `verify_firebase` - Verify Firebase config
4. `verify_build_artifacts` - Check for build artifacts
5. `build_android` - Build Android APK
6. `build_ios` - Build iOS IPA
7. `coverage_report` - Generate coverage report

**Workflows (2):**
1. `build_and_test` - Runs on every commit
2. `nightly` - Scheduled daily at 2 AM UTC

---

## 💡 AVAILABLE MCP TOOLS

### **1. get_build_failure_logs**

**Purpose:** Retrieve failure logs from failed builds

**Usage:**
```
"Get CircleCI build failure logs for master branch"
"Show me the latest build failures"
```

**Parameters:**
- `projectSlug` - Project identifier
- `branch` - Branch name (e.g., "master")

**Output:**
- Failed job logs
- Error messages
- Stack traces

---

### **2. find_flaky_tests**

**Purpose:** Identify tests that fail intermittently

**Usage:**
```
"Find flaky tests in CircleCI"
"Show me unreliable tests"
```

**Output:**
- Test names
- Failure rate
- Recent failures

---

### **3. get_latest_pipeline_status**

**Purpose:** Check current pipeline status

**Usage:**
```
"Check CircleCI pipeline status"
"What's the status of the latest build?"
```

**Output:**
- Pipeline status (success/failed/running)
- Job statuses
- Duration
- Commit info

---

### **4. get_job_test_results**

**Purpose:** Get test results from a specific job

**Usage:**
```
"Get test results from CircleCI"
"Show me failed tests"
```

**Parameters:**
- `filterByTestsResult` - "failure" or "success"

**Output:**
- Test names
- Pass/fail status
- Error messages
- Test duration

---

### **5. config_helper**

**Purpose:** Validate and fix CircleCI config

**Usage:**
```
"Validate CircleCI config"
"Check .circleci/config.yml for errors"
```

**Input:**
- Config file contents

**Output:**
- Validation errors
- Suggestions for fixes

---

### **6. run_pipeline**

**Purpose:** Trigger a new pipeline run

**Usage:**
```
"Trigger CircleCI pipeline"
"Run CircleCI build"
```

**Parameters:**
- `projectSlug` - Project identifier
- `branch` - Branch name
- `configContent` - Optional custom config

**Output:**
- Pipeline URL
- Pipeline ID

---

### **7. list_followed_projects**

**Purpose:** List all CircleCI projects

**Usage:**
```
"List my CircleCI projects"
"Show CircleCI projects"
```

**Output:**
- Project names
- Project slugs

---

### **8. rerun_workflow**

**Purpose:** Rerun a failed workflow

**Usage:**
```
"Rerun failed CircleCI workflow"
"Retry CircleCI build"
```

**Parameters:**
- `workflowId` - Workflow identifier
- `fromFailed` - true/false

---

## 🔧 COMMON WORKFLOWS

### **Workflow 1: Check Build Status**

```
1. "Check CircleCI pipeline status"
2. Review output
3. If failed: "Get CircleCI build failure logs"
4. Fix issues
5. "Trigger CircleCI pipeline"
```

---

### **Workflow 2: Debug Test Failures**

```
1. "Get test results from CircleCI with failures only"
2. Review failed tests
3. Fix tests locally
4. Run tests: flutter test
5. "Trigger CircleCI pipeline"
6. Verify: "Check CircleCI pipeline status"
```

---

### **Workflow 3: Validate Config Changes**

```
1. Edit .circleci/config.yml
2. "Validate CircleCI config" (provide file contents)
3. Fix any errors
4. Commit changes
5. "Trigger CircleCI pipeline"
```

---

### **Workflow 4: Find Flaky Tests**

```
1. "Find flaky tests in CircleCI"
2. Review unreliable tests
3. Fix or mark as flaky
4. "Trigger CircleCI pipeline"
5. Monitor for stability
```

---

## 📊 PHASE-SPECIFIC USAGE

### **Phase 1: Foundation** ✅ COMPLETE

**Tasks:**
- ✅ Created `.circleci/config.yml`
- ✅ Configured 7 jobs
- ✅ Set up 2 workflows
- ✅ Validated configuration
- ✅ Set coverage threshold (15%)

**Results:**
- Pipeline configured
- All jobs passing
- Coverage reporting enabled

---

### **Phase 2: Voice/Video Features** (NEXT)

**Planned Usage:**
- 🔄 Add voice message tests to pipeline
- 🔄 Add video call tests to pipeline
- 🔄 Platform-specific testing (iOS/Android)
- 🔄 Monitor test coverage (maintain 15%+)

**New Jobs:**
```yaml
voice_tests:
  executor: flutter-executor
  steps:
    - setup_flutter
    - run: flutter test test/features/voice/

video_tests:
  executor: flutter-executor
  steps:
    - setup_flutter
    - run: flutter test test/features/video/
```

---

### **Phase 3-5: Advanced Features**

**Planned Enhancements:**
- Integration tests
- E2E tests
- Performance tests
- Visual regression tests (Playwright)

---

## 🎯 COVERAGE TRACKING

### **Current Coverage**
- **Target:** 15% (Phase 1)
- **Actual:** 15%+ achieved
- **Trend:** Increasing

### **Coverage Job**

```yaml
coverage_report:
  executor: flutter-executor
  steps:
    - setup_flutter
    - run:
        name: "Generate Coverage"
        command: flutter test --coverage
    - run:
        name: "Check Coverage Threshold"
        command: |
          THRESHOLD=15
          # Validation logic
    - store_artifacts:
        path: coverage/
```

### **Monitoring Coverage**

```
"Get CircleCI coverage report"
"Check test coverage percentage"
```

---

## 🚨 TROUBLESHOOTING

### **Problem: Build Failing**

**Steps:**
1. "Get CircleCI build failure logs"
2. Review error messages
3. Fix issues locally
4. Test: `flutter test`
5. "Trigger CircleCI pipeline"

---

### **Problem: Flaky Tests**

**Steps:**
1. "Find flaky tests in CircleCI"
2. Identify unreliable tests
3. Add retries or fix root cause
4. Monitor stability

---

### **Problem: Config Invalid**

**Steps:**
1. "Validate CircleCI config" (provide file)
2. Review errors
3. Fix config
4. "Trigger CircleCI pipeline"

---

### **Problem: Tests Timing Out**

**Solution:**
```yaml
test:
  executor: flutter-executor
  steps:
    - run:
        name: "Run Tests"
        command: flutter test
        no_output_timeout: 30m  # Increase timeout
```

---

## 💰 COST OPTIMIZATION

### **Free Tier Limits**
- 2,500 credits/month
- ~500 build minutes

### **Credit Usage**
- Small job: ~5 credits
- Medium job: ~10 credits
- Large job: ~20 credits

### **Optimization Tips**

1. **Cache Dependencies**
```yaml
- restore_cache:
    keys:
      - flutter-packages-{{ checksum "pubspec.lock" }}
- run: flutter pub get
- save_cache:
    key: flutter-packages-{{ checksum "pubspec.lock" }}
    paths:
      - ~/.pub-cache
```

2. **Parallel Jobs**
```yaml
workflows:
  build_and_test:
    jobs:
      - analyze
      - test
      - build_android:
          requires: [test]  # Only after tests pass
```

3. **Conditional Workflows**
```yaml
workflows:
  nightly:
    triggers:
      - schedule:
          cron: "0 2 * * *"  # Only run at 2 AM
```

---

## ✅ BEST PRACTICES

### **1. Always Validate Config**

Before committing:
```
"Validate CircleCI config"
```

### **2. Monitor Build Status**

After pushing:
```
"Check CircleCI pipeline status"
```

### **3. Fix Failures Quickly**

When build fails:
```
"Get CircleCI build failure logs"
```

### **4. Track Coverage**

Maintain 15%+ coverage:
```
"Get CircleCI coverage report"
```

### **5. Identify Flaky Tests**

Monthly:
```
"Find flaky tests in CircleCI"
```

---

## 🔗 INTEGRATION WITH OTHER TOOLS

### **CircleCI + Playwright**

```yaml
visual_tests:
  docker:
    - image: mcr.microsoft.com/playwright:v1.40.0-focal
  steps:
    - checkout
    - run: npm ci
    - run: npx playwright test
    - store_artifacts:
        path: playwright-report/
```

### **CircleCI + Exa**

Use Exa to find CI/CD best practices:
```
"Use Exa to search for Flutter CircleCI optimization tips"
```

---

## 🚀 QUICK REFERENCE

### **Common Commands**

```bash
# Check status
"Check CircleCI pipeline status"

# Get logs
"Get CircleCI build failure logs"

# Trigger build
"Trigger CircleCI pipeline"

# Validate config
"Validate CircleCI config"

# Get test results
"Get test results from CircleCI"

# Find flaky tests
"Find flaky tests in CircleCI"

# Rerun workflow
"Rerun failed CircleCI workflow"
```

### **Config File Location**

```
.circleci/config.yml
```

### **Project URL**

```
https://app.circleci.com/pipelines/circleci/Dgq4rnVu5NzPtG14JcVLsy/9V7jsYiK8dDGLSyi9ZRL7S
```

---

## 📅 MAINTENANCE

### **Weekly Tasks**
- Review build status
- Check for flaky tests
- Monitor coverage trends

### **Monthly Tasks**
- Optimize pipeline performance
- Review credit usage
- Update dependencies

### **Quarterly Tasks**
- Audit test suite
- Review CI/CD strategy
- Update documentation

---

**Next Steps:**
1. Monitor Phase 1 pipeline
2. Plan Phase 2 test additions
3. Integrate Playwright visual tests
4. Optimize for cost efficiency

**Related Documentation:**
- `README.md` - Tool overview
- `PLAYWRIGHT_MCP_GUIDE.md` - Visual testing
- `.circleci/config.yml` - Pipeline configuration

