# Files to KEEP - Essential Project Files

This document lists all files and directories that are essential to the ChekMate Flutter application and should be preserved.

## Core Application Files

### flutter_chekmate/
**Status**: KEEP - Main Flutter application
**Justification**: 
- Contains the entire Flutter application code
- Matches README.md project structure specification
- Includes all 70+ UI components documented in COMPONENTS_GUIDE.md
- Contains platform-specific configs (android/, ios/, web/) as per README
- Has complete routing structure per ROUTING_ARCHITECTURE.md
- Includes all features documented in FEATURES_AND_COMPONENTS_OVERVIEW.md

**Key Subdirectories**:
- `lib/` - All application code (core, features, pages, shared)
- `android/` - Android platform configuration (per README line 369)
- `ios/` - iOS platform configuration (per README line 368)
- `web/` - Web platform configuration (per README line 370)
- `assets/` - Images, icons, animations (per README line 367)
- `test/` - Test files
- `pubspec.yaml` - Flutter dependencies

## Documentation

### docs/
**Status**: KEEP - All documentation
**Justification**:
- Contains authoritative reference documents:
  - COMPONENTS_GUIDE.md (70+ components reference)
  - ROUTING_ARCHITECTURE.md (GoRouter structure)
  - FEATURES_AND_COMPONENTS_OVERVIEW.md (Feature mapping)
  - QUICK_REFERENCE.md (Quick lookup guide)
- Contains deployment guides (deployment/, codemagic/, firebase/)
- Contains architecture documentation (architecture/)
- All referenced in README.md

### README.md
**Status**: KEEP - Primary project documentation
**Justification**: Main project documentation referenced throughout the plan

## Configuration Files

### codemagic.yaml
**Status**: KEEP - CI/CD configuration
**Justification**: Referenced in README.md line 744, essential for automated builds

### .gitignore
**Status**: KEEP - Git configuration
**Justification**: Essential for version control

### LICENSE
**Status**: KEEP - Project license
**Justification**: Referenced in README.md line 1523, required for open source projects

## Scripts (Selective)

### scripts/
**Status**: KEEP - Selected scripts only
**Justification**: 
- `encode_firebase.ps1` - Firebase configuration encoding
- `export-script.sh` - Export functionality
- `generate_icons.bat` / `generate_icons.sh` - Icon generation

**Note**: Review individual scripts for actual usage

## Root Level Files

### CODEMAGIC_PRE_BUILD_CHECKLIST.md
**Status**: KEEP - Build checklist
**Justification**: Referenced in build process

### GITHUB_ENTERPRISE_CLEANUP_PLAN.md
**Status**: REVIEW - May be historical
**Justification**: Could be archived if no longer relevant

## flutter_chekmate/docs/
**Status**: KEEP - Flutter-specific documentation
**Justification**: Contains implementation guides, phase trackers, and development documentation

## flutter_chekmate/scripts/
**Status**: KEEP - Flutter build scripts
**Justification**: Contains demo account setup and other Flutter-specific scripts

---

## Summary

**Total Essential Directories**: 3 major (flutter_chekmate/, docs/, scripts/)
**Total Essential Files**: README.md, LICENSE, codemagic.yaml, .gitignore
**Status**: All core application files are present and match README specifications

