# Files to ARCHIVE - Historical/Reference Material

This document lists files and directories that have historical value but are not part of the current active application. These should be moved to an `archive/` directory.

## Already Archived

### archive/
**Status**: ALREADY ARCHIVED - Keep as is
**Contents**:
- `ChekMate (Copy)/` - React/TypeScript prototype
- `ChekMate (Copy).zip` - Compressed prototype
- `data-lake-query-interface.html` - Old interface
- `ml-prediction-models.js` - Old ML models
- `project-package-export.md` - Old export documentation

**Justification**: Already in archive/, contains historical React/TypeScript prototype code

## Development History

### phase_progression/
**Status**: ARCHIVE - Historical development notes
**Justification**: 
- Contains build failure analysis and phase completion notes
- Historical reference only, not needed for current development
- Per README line 383, this is for "Development phase tracking" (historical)

**Files to Archive**:
- `BUILD_4_FAILURE_NEW_APPROACH.md`
- `BUILD_4_STATUS.md`
- `BUILD_FAILURE_ANALYSIS.md`
- `BUILD_FIX_IMPLEMENTATION.md`
- `PHASE_1_COMPLETE.md`
- `phase_notes.md`

## Temporary/Generated Files

### Root Level Temporary Files
**Status**: ARCHIVE or DELETE - Temporary analysis files
**Files**:
- `flutter_analyze_output.txt` - Flutter analysis output (temporary)
- `flutter_analyze_errors.txt` - Flutter analysis errors (temporary)
- `flutter_analyze_current.txt` - Current analysis (temporary)
- `dart_files_list.txt` - File listing (temporary)
- `project-package-export.md` - Old export (duplicate of archive)

**Justification**: These appear to be temporary analysis outputs, not permanent documentation

### flutter_chekmate/ Temporary Files
**Status**: ARCHIVE or DELETE - Temporary code generation files
**Files**:
- `temp_shimmer_loading.txt`
- `temp_shimmer_skeletons.txt`
- `temp_shimmer_skeletons_full.txt`

**Justification**: Temporary files from code generation, likely no longer needed

## Duplicate/Redundant Files

### Root Level Duplicates
**Status**: ARCHIVE - Duplicate files
**Files**:
- `ChekMate (Copy)/` - Duplicate of archive/ChekMate (Copy)/
- `ml-prediction-models.js` - Duplicate of archive/ml-prediction-models.js
- `data-lake-query-interface.html` - Duplicate of archive/data-lake-query-interface.html
- `export-script.sh` - May be duplicate (check if in scripts/)

**Justification**: These are duplicates of files already in archive/

## Historical Documentation

### flutter_chekmate/docs/ (Selective)
**Status**: REVIEW - Some may be historical
**Justification**: 
- Contains extensive documentation (152+ files from enterprise-monorepo merge)
- Many are completion reports and phase summaries
- Keep implementation guides, archive completion reports

**Files to Consider Archiving**:
- `*_COMPLETE.md` files (completion reports)
- `*_SUMMARY.md` files (historical summaries)
- `SPRINT_*_REPORT.md` files (sprint reports)
- `CHECKPOINT_*.md` files (checkpoint documentation)

**Files to KEEP**:
- `PHASE_TRACKER.md` - Active tracking
- Implementation guides
- Setup guides
- Architecture documentation

## Build Artifacts

### flutter_chekmate/build/
**Status**: ARCHIVE or DELETE - Generated build files
**Justification**: 
- Generated during build process
- Should be in .gitignore
- Can be regenerated

### flutter_chekmate/coverage/
**Status**: ARCHIVE or DELETE - Test coverage reports
**Justification**: 
- Generated during testing
- Can be regenerated
- Should be in .gitignore

### flutter_chekmate/test-results/
**Status**: ARCHIVE or DELETE - Test result artifacts
**Justification**: 
- Generated during testing
- Can be regenerated
- Should be in .gitignore

---

## Archive Action Plan

1. **Move to archive/**:
   - `phase_progression/` → `archive/phase_progression/`
   - Root level temporary `.txt` files → `archive/temp_analysis/`
   - `flutter_chekmate/temp_*.txt` → `archive/temp_codegen/`
   - Duplicate root files → `archive/duplicates/`

2. **Review and Archive**:
   - Historical completion reports in `flutter_chekmate/docs/`
   - Build artifacts (if not in .gitignore)

3. **Clean Up**:
   - Remove duplicate files after archiving
   - Update .gitignore to exclude build artifacts

---

## Summary

**Total Items to Archive**: ~20+ files/directories
**Primary Categories**: Historical notes, temporary files, duplicates, build artifacts
**Impact**: Low - These are not part of active development

