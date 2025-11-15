# Files to DELETE - Obsolete/Redundant

This document lists files and directories that are safe to delete as they are obsolete, redundant, or empty.

## Empty Directories

### platform/
**Status**: DELETE - Empty and redundant
**Justification**: 
- All three subdirectories (android/, ios/, web/) are empty
- Platform-specific configs are in `flutter_chekmate/android/`, `flutter_chekmate/ios/`, `flutter_chekmate/web/`
- Per README line 371-374, platform/ should contain configs, but they're actually in flutter_chekmate/
- Redundant with flutter_chekmate platform directories

**Action**: Delete entire `platform/` directory

### config/
**Status**: DELETE - Empty directory
**Justification**: 
- Directory exists but is completely empty
- Per README line 375, config/ should contain "Environment and configuration files"
- No files present, likely unused

**Action**: Delete `config/` directory (or verify if it should contain files)

## Duplicate Files (After Archiving)

### Root Level Duplicates
**Status**: DELETE - After archiving originals
**Files**:
- `ChekMate (Copy)/` - Duplicate (original in archive/)
- `ml-prediction-models.js` - Duplicate (original in archive/)
- `data-lake-query-interface.html` - Duplicate (original in archive/)

**Action**: Delete after confirming originals are safely archived

## Generated/Build Files (If Not in .gitignore)

### flutter_chekmate/build/
**Status**: DELETE - Should be in .gitignore
**Justification**: 
- Generated build artifacts
- Should not be in version control
- Can be regenerated

**Action**: Verify .gitignore includes `build/`, then delete

### flutter_chekmate/coverage/
**Status**: DELETE - Should be in .gitignore
**Justification**: 
- Generated coverage reports
- Should not be in version control
- Can be regenerated

**Action**: Verify .gitignore includes `coverage/`, then delete

### flutter_chekmate/test-results/
**Status**: DELETE - Should be in .gitignore
**Justification**: 
- Generated test results
- Should not be in version control
- Can be regenerated

**Action**: Verify .gitignore includes `test-results/`, then delete

## Node.js Artifacts (KEEP - Playwright Required)

### flutter_chekmate/node_modules/
**Status**: KEEP - Required for Playwright
**Justification**: 
- Node.js dependencies for Playwright E2E testing
- Playwright is actively used (playwright.config.ts exists and configured)
- Already in .gitignore (line 43 of flutter_chekmate/.gitignore)

**Action**: KEEP - Essential for testing infrastructure

### flutter_chekmate/package-lock.json
**Status**: KEEP - Required for Playwright
**Justification**: 
- Node.js package lock file
- Required for Playwright dependency management
- Ensures consistent test environment

**Action**: KEEP - Essential for Playwright

### flutter_chekmate/package.json
**Status**: KEEP - Required for Playwright
**Justification**: 
- Node.js package configuration
- Defines Playwright and testing dependencies
- Required for E2E testing setup

**Action**: KEEP - Essential for Playwright

### flutter_chekmate/playwright.config.ts
**Status**: KEEP - Playwright configuration
**Justification**: 
- Active Playwright test configuration
- Configured for Flutter Web PWA testing
- Essential for E2E testing

**Action**: KEEP - Core testing file

## Temporary Analysis Files

### Root Level Analysis Files
**Status**: DELETE - Temporary files
**Files**:
- `flutter_analyze_output.txt`
- `flutter_analyze_errors.txt`
- `flutter_analyze_current.txt`
- `dart_files_list.txt`

**Action**: Delete (these are temporary analysis outputs)

### flutter_chekmate/ Temporary Files
**Status**: DELETE - Temporary code generation
**Files**:
- `temp_shimmer_loading.txt`
- `temp_shimmer_skeletons.txt`
- `temp_shimmer_skeletons_full.txt`

**Action**: Delete (temporary code generation files)

## Redundant Documentation

### GITHUB_ENTERPRISE_CLEANUP_PLAN.md
**Status**: DELETE or ARCHIVE - Historical plan
**Justification**: 
- Appears to be a previous cleanup plan
- May be superseded by current consolidation

**Action**: Archive if historical value, delete if obsolete

### PAGES_AND_ROUTING.md
**Status**: REVIEW - May be redundant
**Justification**: 
- Routing is documented in `docs/ROUTING_ARCHITECTURE.md`
- May be duplicate or outdated

**Action**: Compare with ROUTING_ARCHITECTURE.md, delete if redundant

### Figma_Routing_guide.md
**Status**: REVIEW - May be redundant
**Justification**: 
- Located in flutter_chekmate/
- May duplicate docs/ROUTING_ARCHITECTURE.md

**Action**: Compare with ROUTING_ARCHITECTURE.md, delete if redundant

## Flutter IDE Files

### flutter_chekmate/*.iml
**Status**: DELETE - IDE-specific files
**Files**:
- `flutter_chekmate.iml`
- `flutter_chekmate_android.iml`

**Justification**: 
- IntelliJ/Android Studio project files
- Should be in .gitignore
- IDE-specific, not needed in repository

**Action**: Delete and add to .gitignore

## Service Account Keys (SECURITY)

### flutter_chekmate/scripts/serviceAccountKey.json
**Status**: DELETE IMMEDIATELY - Security risk
**Justification**: 
- Contains service account credentials
- Should NEVER be in version control
- Major security risk

**Action**: 
1. DELETE immediately
2. Add to .gitignore
3. Rotate credentials if this was committed
4. Use environment variables instead

---

## Delete Action Plan

### Immediate (Security)
1. **DELETE**: `flutter_chekmate/scripts/serviceAccountKey.json`
2. **VERIFY**: Check git history for this file
3. **ROTATE**: All credentials that may have been exposed

### High Priority (Cleanup)
1. **DELETE**: `platform/` directory (empty, redundant)
2. **DELETE**: `config/` directory (empty)
3. **DELETE**: Temporary `.txt` files (root and flutter_chekmate/)
4. **DELETE**: Duplicate files after archiving

### Medium Priority (Review First)
1. **KEEP**: Node.js files (Playwright is actively used - CONFIRMED)
2. **REVIEW**: Build artifacts (verify .gitignore)
3. **REVIEW**: Redundant documentation files

### Low Priority (IDE Files)
1. **DELETE**: `.iml` files
2. **UPDATE**: .gitignore to exclude IDE files

---

## Summary

**Total Items to Delete**: ~15+ files/directories
**Security Risks**: 1 (serviceAccountKey.json - CRITICAL)
**Empty Directories**: 2 (platform/, config/)
**Temporary Files**: 7+ files
**Impact**: Medium - Cleanup will improve repository clarity

