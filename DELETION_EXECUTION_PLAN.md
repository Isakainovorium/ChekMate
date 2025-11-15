# Deletion Execution Plan

This plan outlines the step-by-step execution of file deletions based on the QA analysis, with Playwright files preserved and service account keys properly ignored.

## Pre-Execution Checklist

- [x] Playwright files confirmed to keep (playwright.config.ts exists)
- [x] Service account key added to .gitignore (root and flutter_chekmate/)
- [x] All QA reports reviewed
- [x] Backup/archive strategy confirmed

## Execution Steps

### Step 1: Security - Add Service Account Key to .gitignore ✅

**Status**: COMPLETE
- Added to root `.gitignore`
- Already in `flutter_chekmate/.gitignore` (line 144)
- File will remain locally but won't be tracked by git

**Note**: The file `flutter_chekmate/scripts/serviceAccountKey.json` will remain on your local machine but will be ignored by git, so it won't be exposed publicly.

### Step 2: Delete Empty Directories

#### 2.1 Delete `platform/` directory
```bash
# Platform configs are in flutter_chekmate/android, ios, web
# This directory is empty and redundant
rm -rf platform/
```

**Files to delete**:
- `platform/android/` (empty)
- `platform/ios/` (empty)
- `platform/web/` (empty)
- `platform/` (entire directory)

**Justification**: Empty, redundant with flutter_chekmate platform directories

#### 2.2 Delete `config/` directory
```bash
# Directory is completely empty
rm -rf config/
```

**Files to delete**:
- `config/` (entire directory - empty)

**Justification**: Empty directory, no files present

### Step 3: Delete Temporary Analysis Files

#### 3.1 Root Level Temporary Files
```bash
# Delete temporary Flutter analysis outputs
rm flutter_analyze_output.txt
rm flutter_analyze_errors.txt
rm flutter_analyze_current.txt
rm dart_files_list.txt
```

**Files to delete**:
- `flutter_analyze_output.txt`
- `flutter_analyze_errors.txt`
- `flutter_analyze_current.txt`
- `dart_files_list.txt`

**Justification**: Temporary analysis outputs, not permanent documentation

#### 3.2 Flutter ChekMate Temporary Files
```bash
# Delete temporary code generation files
rm flutter_chekmate/temp_shimmer_loading.txt
rm flutter_chekmate/temp_shimmer_skeletons.txt
rm flutter_chekmate/temp_shimmer_skeletons_full.txt
```

**Files to delete**:
- `flutter_chekmate/temp_shimmer_loading.txt`
- `flutter_chekmate/temp_shimmer_skeletons.txt`
- `flutter_chekmate/temp_shimmer_skeletons_full.txt`

**Justification**: Temporary code generation files, no longer needed

### Step 4: Delete Duplicate Files

#### 4.1 Root Level Duplicates
```bash
# Delete duplicates (originals are in archive/)
rm -rf "ChekMate (Copy)/"
rm ml-prediction-models.js
rm data-lake-query-interface.html
```

**Files to delete**:
- `ChekMate (Copy)/` (duplicate of archive/ChekMate (Copy)/)
- `ml-prediction-models.js` (duplicate of archive/ml-prediction-models.js)
- `data-lake-query-interface.html` (duplicate of archive/data-lake-query-interface.html)

**Justification**: Duplicates of files already safely archived

### Step 5: Delete IDE-Specific Files

#### 5.1 Flutter IDE Files
```bash
# Delete IntelliJ/Android Studio project files
rm flutter_chekmate/flutter_chekmate.iml
rm flutter_chekmate/android/flutter_chekmate_android.iml
```

**Files to delete**:
- `flutter_chekmate/flutter_chekmate.iml`
- `flutter_chekmate/android/flutter_chekmate_android.iml`

**Justification**: IDE-specific files, should be in .gitignore (already is)

### Step 6: Delete Build Artifacts (If Not in .gitignore)

#### 6.1 Verify .gitignore Coverage
**Check**: Verify these are in .gitignore:
- `build/` - ✅ Already in .gitignore (line 7, 112)
- `coverage/` - ✅ Already in .gitignore (line 98)
- `test-results/` - ✅ Already in flutter_chekmate/.gitignore (line 40)

**Action**: Since these are already in .gitignore, they should not be committed. However, if they were previously committed, they can be deleted:

```bash
# Only delete if they were previously committed
# These should regenerate automatically
rm -rf flutter_chekmate/build/
rm -rf flutter_chekmate/coverage/
rm -rf flutter_chekmate/test-results/
```

**Note**: These will regenerate on next build/test run. Safe to delete if they exist in git.

### Step 7: Review and Delete Redundant Documentation

#### 7.1 Review Documentation Files
**Files to review** (compare before deleting):
- `GITHUB_ENTERPRISE_CLEANUP_PLAN.md` - Historical plan, may archive
- `PAGES_AND_ROUTING.md` - Compare with docs/ROUTING_ARCHITECTURE.md
- `flutter_chekmate/Figma_Routing_guide.md` - Compare with docs/ROUTING_ARCHITECTURE.md

**Action**: Review these files first, then decide:
- If redundant → Delete
- If unique content → Keep or Archive

### Step 8: Files to KEEP (Playwright)

**DO NOT DELETE** - These are required for Playwright testing:
- ✅ `flutter_chekmate/node_modules/` - Playwright dependencies
- ✅ `flutter_chekmate/package.json` - Playwright configuration
- ✅ `flutter_chekmate/package-lock.json` - Dependency lock file
- ✅ `flutter_chekmate/playwright.config.ts` - Playwright test config
- ✅ `flutter_chekmate/test/e2e/` - E2E test files

**Justification**: Playwright is actively used for E2E testing

## Execution Summary

### Directories to Delete: 2
1. `platform/` (empty, redundant)
2. `config/` (empty)

### Files to Delete: ~15
1. Temporary analysis files (7 files)
2. Duplicate files (3 files)
3. IDE files (2 files)
4. Redundant documentation (3 files - after review)

### Files to KEEP: 5+ (Playwright)
1. `flutter_chekmate/node_modules/`
2. `flutter_chekmate/package.json`
3. `flutter_chekmate/package-lock.json`
4. `flutter_chekmate/playwright.config.ts`
5. `flutter_chekmate/test/e2e/` directory

### Security: 1
1. ✅ `flutter_chekmate/scripts/serviceAccountKey.json` - Added to .gitignore (will remain locally but not tracked)

## Post-Execution Verification

After deletion, verify:
- [ ] Playwright still works (`npm test` or `npx playwright test`)
- [ ] Flutter app still builds (`flutter build`)
- [ ] No broken imports or references
- [ ] Service account key is in .gitignore (not tracked)
- [ ] Git status shows only intended changes

## Rollback Plan

If anything breaks:
```bash
# Restore from git (if files were tracked)
git checkout HEAD -- <file>

# Or restore from backup (if files weren't tracked)
# Files in archive/ are safe backups
```

---

## Ready to Execute

This plan is ready for execution. All deletions are safe and reversible (via git or archive).

**Estimated Time**: 5-10 minutes
**Risk Level**: Low (all deletions are safe, Playwright preserved, service key protected)

