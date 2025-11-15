# AI-Assisted Flutter App Restoration Workflow Rules

**Version:** 1.0  
**Date:** November 13, 2025  
**Purpose:** Comprehensive workflow rules for AI-assisted Flutter app restoration using MCP tools  
**Based on:** Research synthesis from 5+ authoritative sources + GitHub examples + Best practices

---

## 🎯 Core Principles

### 1. **Incremental Development with Validation Gates**
- **Never build everything at once** - Work in small, testable increments
- **Validate after each phase** - Run tests, analyze, and verify before proceeding
- **Commit frequently** - Save progress after each successful validation
- **Rollback capability** - Always maintain ability to revert if validation fails

### 2. **Multi-Tool Orchestration**
- **Use the right tool for the right job** - Leverage MCP tools strategically
- **Cross-validate information** - Use multiple sources before implementing
- **Document decisions** - Store architectural decisions in Memory MCP
- **Research before coding** - Always research patterns before implementing

### 3. **Clean Architecture Compliance**
- **Follow feature-first organization** - Domain/Data/Presentation layers per feature
- **Maintain separation of concerns** - Business logic separate from UI
- **Dependency injection** - Use Riverpod providers for all dependencies
- **Testability first** - Write testable code from the start

### 4. **Date Tracking & Documentation**
- **Always use actual dates** - Use current date (MM/DD/YYYY format) in all documentation
- **Track progress by date** - Document when work was completed, not generic dates
- **Date in commit messages** - Include actual date in commit messages
- **Date in Memory MCP** - Store dates with all architectural decisions
- **Progress tracking** - Use dates to track restoration timeline

**Date Format:** MM/DD/YYYY (e.g., 11/13/2025)

### 5. **Accuracy & Information Currency**
- **Always use updated information** - Verify all information is current before using
- **Cross-reference sources** - Validate information from multiple sources
- **Check for updates** - Use Browser MCP to verify latest documentation versions
- **Verify package versions** - Ensure dependencies match current requirements
- **Update outdated patterns** - Replace deprecated patterns with current best practices
- **Be as accurate as possible** - Double-check all facts, dates, and technical details
- **Validate against latest standards** - Ensure compliance with current Flutter/Dart standards

### 6. **Elegant File Structure**
- **Follow Clean Architecture** - Maintain elegant, logical file organization
- **Feature-first organization** - Group related files by feature, not by type
- **Consistent naming** - Use clear, descriptive, consistent file names
- **Proper directory structure** - Maintain elegant hierarchy (domain/data/presentation)
- **Logical grouping** - Group related files together
- **Minimal nesting** - Avoid excessive directory depth
- **Self-documenting structure** - File structure should communicate organization
- **Follow project conventions** - Maintain consistency with existing structure

### 7. **Proper Phase Execution**
- **Work in proper phases** - Complete each phase fully before moving to next
- **No phase skipping** - Never skip phases or combine phases prematurely
- **Phase validation gates** - Each phase must pass validation before proceeding
- **Sequential execution** - Follow phase order strictly (1 → 2 → 3 → 4 → 5)
- **Phase documentation** - Document completion of each phase with date
- **Phase rollback** - Be able to rollback to previous phase if current fails
- **Phase dependencies** - Understand and respect phase dependencies

### 8. **Enterprise-Grade Code Quality**
- **Professional code standards** - Code must meet elite-level human full stack software engineer quality
- **No emojis in code** - NEVER use emojis in code, comments, or documentation
- **Clean, readable code** - Code should be self-documenting and professional
- **Industry best practices** - Follow enterprise software development standards
- **Production-ready quality** - Every line of code should be production-ready
- **Code review standards** - Code should pass strict enterprise code review
- **Maintainability** - Code must be maintainable by other engineers
- **Performance optimized** - Consider performance implications of all code
- **Security conscious** - Follow security best practices in all implementations
- **Scalability** - Design code to scale with application growth

**CODE QUALITY REQUIREMENTS:**
- ✅ No emojis anywhere in codebase
- ✅ Professional naming conventions
- ✅ Comprehensive error handling
- ✅ Proper logging and monitoring
- ✅ Clean, readable code structure
- ✅ Well-documented code
- ✅ Follows Flutter/Dart style guide
- ✅ Enterprise-grade architecture patterns
- ✅ Production-ready error handling
- ✅ Comprehensive test coverage

---

## 📋 Phase-by-Phase Workflow Rules

### **PHASE 1: Research & Discovery (BEFORE ANY CODE)**

#### Rule 1.1: Multi-Source Research (USE UPDATED INFORMATION)
**MUST DO:**
1. **Use Browser MCP** to access official documentation (ALWAYS CHECK FOR UPDATES):
   - Flutter docs: `docs.flutter.dev` (verify latest version)
   - GoRouter docs: `pub.dev/packages/go_router` (check latest release)
   - Riverpod docs: `riverpod.dev` (verify current version)
   - Firebase docs: `firebase.google.com/docs` (check latest updates)
   - **ALWAYS verify information is current** - Check publication dates, version numbers
   - **ALWAYS cross-reference** - Use multiple sources to ensure accuracy

2. **Use GitHub MCP** to find real-world examples:
   - Search: "Flutter GoRouter Riverpod integration"
   - Search: "Flutter Clean Architecture main.dart"
   - Search: "Flutter Firebase initialization pattern"
   - Review at least 3-5 working examples before implementing

3. **Use Git/GitKraken MCP** to understand project history:
   - Check commit history for deleted files
   - Review previous implementations
   - Understand architectural decisions
   - Restore files from git history when possible

4. **Use Sequential Thinking MCP** for complex problems:
   - Break down restoration into steps
   - Analyze dependencies
   - Plan implementation order
   - Identify risks and blockers

5. **Store findings in Memory MCP**:
   - Architectural decisions (with date: MM/DD/YYYY)
   - Pattern choices (with date: MM/DD/YYYY)
   - File locations
   - Dependencies discovered
   - **ALWAYS include actual date** when storing observations

**NEVER:**
- Start coding without researching patterns
- Implement without checking existing codebase structure
- Skip validation steps
- Ignore git history

#### Rule 1.2: Pattern Validation
**MUST DO:**
1. Find at least 2-3 working examples of each pattern
2. Compare patterns with project requirements
3. Validate against Clean Architecture principles
4. Check compatibility with existing codebase
5. Document pattern choice in Memory MCP

---

### **PHASE 2: Core Infrastructure (FOUNDATION FIRST)**

#### Rule 2.1: Build Order (STRICT SEQUENCE)
**MUST FOLLOW THIS ORDER:**

1. **main.dart** (App Entry Point)
   - Initialize WidgetsFlutterBinding
   - Initialize Firebase (platform-specific)
   - Setup ProviderScope (Riverpod)
   - Configure error handling
   - Setup router
   - **VALIDATE:** App runs without errors

2. **Route Constants** (`lib/core/router/route_constants.dart`)
   - Define all route paths as constants
   - Use typed route names
   - **VALIDATE:** All routes defined, no duplicates

3. **Router Provider** (`lib/core/router/app_router_provider.dart`)
   - Create Riverpod provider for GoRouter
   - Configure route definitions
   - Setup auth guards
   - **VALIDATE:** Router provider compiles

4. **App Router** (`lib/core/router/app_router.dart`)
   - Define all GoRoute configurations
   - Setup redirects and guards
   - Configure transitions
   - **VALIDATE:** All routes accessible, navigation works

5. **Navigation State** (`lib/core/navigation/nav_state.dart`)
   - Create navigation state providers
   - Setup bottom nav state
   - Setup top tab state
   - **VALIDATE:** Navigation state updates correctly

**VALIDATION GATES:**
- After each file: Run `flutter analyze`
- After router: Test navigation manually
- After state: Verify state updates
- **NEVER proceed to next phase until current phase validates**
- **ALWAYS complete phase fully** before moving to next phase
- **ALWAYS verify accuracy** of all implementations
- **ALWAYS maintain elegant structure** throughout phase

#### Rule 2.2: File Creation Protocol (ELEGANT STRUCTURE)
**MUST DO:**
1. **Check git history first** - Use Git/GitKraken to find deleted files
2. **Restore from history if possible** - Better than recreating
3. **If creating new:**
   - Research pattern first (Browser + GitHub MCP) - **USE UPDATED INFORMATION**
   - Verify pattern is current and not deprecated
   - Plan elegant file structure - Follow Clean Architecture
   - Create minimal working version
   - Add comprehensive comments
   - Write tests immediately
   - Validate before proceeding

4. **Maintain Elegant File Structure:**
   - Follow feature-first organization
   - Use consistent naming conventions
   - Maintain proper directory hierarchy
   - Group related files logically
   - Avoid excessive nesting
   - Make structure self-documenting

5. **Document in Memory MCP:**
   - File purpose (with date: MM/DD/YYYY)
   - Dependencies (verify versions are current)
   - Integration points
   - Test coverage
   - **ALWAYS include actual date** when documenting files
   - **ALWAYS verify information accuracy** before documenting

---

### **PHASE 3: Feature Pages (INCREMENTAL BUILD)**

#### Rule 3.1: Page Creation Workflow
**FOR EACH PAGE:**

1. **Research Phase:**
   - Use Browser MCP: Access Flutter widget documentation
   - Use GitHub MCP: Find similar page implementations
   - Use Filesystem MCP: Check existing page patterns in codebase
   - Document pattern choice in Memory MCP

2. **Design Phase:**
   - Use Sequential Thinking MCP: Break down page into components
   - Identify required UI components (from our 56 components)
   - Plan state management (Riverpod providers)
   - Plan navigation integration

3. **Implementation Phase:**
   - Create page file with minimal structure
   - Add UI components incrementally
   - Add state management
   - Add navigation integration
   - **VALIDATE:** Page renders, navigation works

4. **Testing Phase:**
   - Write widget tests
   - Test navigation
   - Test state management
   - **VALIDATE:** All tests pass

5. **Integration Phase:**
   - Add route to router
   - Test deep linking
   - Test navigation guards
   - **VALIDATE:** Full integration works

**NEVER:**
- Create multiple pages simultaneously
- Skip testing
- Integrate without validation
- Proceed to next page until current page is complete

#### Rule 3.2: Component Integration
**MUST DO:**
1. **Verify component exists** - Check `lib/shared/ui/components/`
2. **Check component exports** - Verify in `lib/shared/ui/index.dart`
3. **Review component API** - Read component file for props/usage
4. **Find usage examples** - Use GitHub MCP to find real examples
5. **Test component in isolation** - Before integrating into page
6. **Document usage** - In Memory MCP

---

### **PHASE 4: Integration & Validation (CONTINUOUS)**

#### Rule 4.1: Continuous Validation
**AFTER EACH CHANGE:**

1. **Static Analysis:**
   ```bash
   flutter analyze
   ```
   - **REQUIREMENT:** 0 errors before proceeding
   - Fix warnings if critical
   - Document info-level issues

2. **Build Verification:**
   ```bash
   flutter build web --release
   ```
   - **REQUIREMENT:** Successful build
   - Check for compilation errors
   - Verify build output

3. **Test Execution:**
   ```bash
   flutter test
   ```
   - **REQUIREMENT:** All tests pass
   - Fix failing tests immediately
   - Add tests for new code

4. **Manual Testing:**
   - Test affected features manually
   - Verify navigation flows
   - Check error handling
   - Test edge cases

#### Rule 4.2: Git Workflow
**MUST DO:**
1. **Before starting work:**
   - Check git status
   - Create feature branch if needed
   - Ensure clean working directory

2. **During work:**
   - Commit after each validated phase
   - Write descriptive commit messages
   - Include what was changed and why

3. **After validation:**
   - Commit validated changes
   - Push to remote
   - Document in Memory MCP

**COMMIT MESSAGE FORMAT:**
```
[Phase] [Type]: Brief description
Date: MM/DD/YYYY

- What was changed
- Why it was changed
- Validation status
```

**Example:**
```
[Phase 1] [Core]: Create main.dart with Firebase initialization
Date: 11/13/2025

- Added main.dart with WidgetsFlutterBinding
- Initialized Firebase with platform-specific options
- Setup ProviderScope for Riverpod
- Validation: App runs, Firebase connects
```

**DATE TRACKING REQUIREMENTS:**
- **ALWAYS** include actual date in commit messages
- **ALWAYS** use current date (MM/DD/YYYY format)
- **ALWAYS** include date when documenting in Memory MCP
- **ALWAYS** track completion dates for each phase
- **NEVER** use generic dates like "January 2025" or "Today"

---

### **PHASE 5: Testing & Quality Assurance (MANDATORY)**

#### Rule 5.1: Test Coverage Requirements
**MUST HAVE TESTS FOR:**

1. **Core Infrastructure:**
   - Router configuration tests
   - Provider tests
   - Navigation state tests
   - Error handling tests

2. **Feature Pages:**
   - Widget rendering tests
   - User interaction tests
   - State management tests
   - Navigation tests

3. **Components:**
   - Component rendering tests
   - Prop validation tests
   - Interaction tests

**TEST WRITING PROTOCOL:**
1. Write test before or immediately after implementation
2. Test happy path first
3. Test error cases
4. Test edge cases
5. **VALIDATE:** All tests pass before proceeding

#### Rule 5.2: Quality Gates
**BEFORE CONSIDERING COMPLETE:**

1. **Code Quality:**
   - ✅ `flutter analyze` - 0 errors
   - ✅ All linter rules pass
   - ✅ Code follows project conventions
   - ✅ Documentation complete

2. **Test Coverage:**
   - ✅ All new code has tests
   - ✅ All tests pass
   - ✅ Integration tests pass
   - ✅ Manual testing complete

3. **Build Status:**
   - ✅ Web build successful
   - ✅ Android build successful (if applicable)
   - ✅ iOS build successful (if applicable)
   - ✅ No compilation warnings

4. **Integration:**
   - ✅ All routes accessible
   - ✅ Navigation works
   - ✅ State management works
   - ✅ Firebase connected
   - ✅ Error handling works

---

## 🔧 MCP Tool Usage Guidelines

### **Browser MCP**
**USE FOR:**
- Accessing official documentation
- Reading API references
- Finding best practices
- Checking version compatibility

**WHEN TO USE:**
- Before implementing new features
- When encountering errors
- When unsure about API usage
- When validating patterns

**BEST PRACTICES:**
- Always verify information from official sources
- Cross-reference with GitHub examples
- Document findings in Memory MCP

### **GitHub MCP**
**USE FOR:**
- Finding working code examples
- Understanding real-world patterns
- Learning from production code
- Validating implementation approaches

**WHEN TO USE:**
- Before implementing new patterns
- When stuck on implementation
- When validating architecture decisions
- When looking for best practices

**BEST PRACTICES:**
- Review multiple examples (3-5 minimum)
- Prefer well-maintained repositories
- Check for similar project structures
- Document useful patterns in Memory MCP

### **Git/GitKraken MCP**
**USE FOR:**
- Finding deleted files in history
- Understanding project evolution
- Restoring previous implementations
- Reviewing architectural decisions

**WHEN TO USE:**
- Before recreating deleted files
- When understanding project history
- When restoring lost code
- When reviewing previous patterns

**BEST PRACTICES:**
- Always check git history first
- Restore from history when possible
- Review commit messages for context
- Document restoration decisions

### **Filesystem MCP**
**USE FOR:**
- Analyzing project structure
- Finding file patterns
- Understanding organization
- Validating file locations

**WHEN TO USE:**
- When understanding project structure
- When finding similar files
- When validating file organization
- When planning new files

**BEST PRACTICES:**
- Use directory tree for overview
- Search for patterns across files
- Validate against Clean Architecture
- Document structure decisions

### **Memory MCP**
**USE FOR:**
- Storing architectural decisions
- Remembering file locations
- Tracking patterns used
- Building knowledge base

**WHEN TO USE:**
- After making architectural decisions
- When discovering important patterns
- When documenting file purposes
- When storing learnings

**BEST PRACTICES:**
- Store decisions immediately
- Link related entities
- Add observations with context
- Review before making similar decisions

### **Sequential Thinking MCP**
**USE FOR:**
- Breaking down complex problems
- Planning implementation order
- Analyzing dependencies
- Solving difficult challenges

**WHEN TO USE:**
- When facing complex problems
- When planning multi-step tasks
- When analyzing dependencies
- When stuck on implementation

**BEST PRACTICES:**
- Think through problems step-by-step
- Question assumptions
- Revise approach when needed
- Document thought process

### **Dart MCP**
**USE FOR:**
- Analyzing Dart code structure
- Understanding dependencies
- Finding imports and references
- Code analysis

**WHEN TO USE:**
- When analyzing code structure
- When understanding dependencies
- When finding references
- When debugging issues

---

## 🚨 Critical Rules (NEVER VIOLATE)

### **Rule CR1: Never Skip Validation**
- **ALWAYS** validate after each phase
- **NEVER** proceed with errors
- **ALWAYS** fix issues immediately
- **NEVER** accumulate technical debt

### **Rule CR2: Research Before Implementation & Use Updated Information**
- **ALWAYS** research patterns first using current, updated sources
- **NEVER** implement without examples
- **ALWAYS** validate against latest best practices (check for updates)
- **NEVER** guess at implementations
- **ALWAYS** verify information is current and accurate
- **NEVER** use outdated documentation or deprecated patterns
- **ALWAYS** cross-reference multiple sources for accuracy

### **Rule CR3: Incremental Development**
- **ALWAYS** work in small increments
- **NEVER** build everything at once
- **ALWAYS** test incrementally
- **NEVER** skip testing phases

### **Rule CR4: Documentation & Date Tracking**
- **ALWAYS** document decisions with actual dates (MM/DD/YYYY)
- **NEVER** skip Memory MCP entries
- **ALWAYS** write clear commit messages with dates
- **NEVER** leave code undocumented
- **ALWAYS** use actual current date, never generic dates
- **NEVER** use placeholder dates like "January 2025"

### **Rule CR5: Clean Architecture & Elegant File Structure**
- **ALWAYS** follow Clean Architecture
- **NEVER** mix layers
- **ALWAYS** use dependency injection
- **NEVER** create tight coupling
- **ALWAYS** maintain elegant file structure
- **NEVER** create messy or disorganized file layouts
- **ALWAYS** follow feature-first organization
- **NEVER** break project conventions

### **Rule CR6: Proper Phase Execution**
- **ALWAYS** work in proper phases sequentially
- **NEVER** skip phases or combine phases prematurely
- **ALWAYS** complete phase validation before proceeding
- **NEVER** start next phase until current phase is fully complete
- **ALWAYS** document phase completion with date
- **NEVER** proceed with incomplete phases

### **Rule CR7: Enterprise-Grade Code Quality & No Emojis**
- **ALWAYS** write enterprise-grade, production-ready code
- **NEVER** use emojis in code, comments, or documentation
- **ALWAYS** follow professional coding standards
- **NEVER** write code that wouldn't pass enterprise code review
- **ALWAYS** ensure code quality matches elite-level human full stack engineer standards
- **NEVER** compromise on code quality or professionalism
- **ALWAYS** write maintainable, scalable code
- **NEVER** use casual or unprofessional language in code
- **ALWAYS** follow industry best practices
- **NEVER** skip error handling or edge cases

---

## 📊 Success Metrics

### **Phase Completion Criteria**

**Phase 1 (Core Infrastructure):**
- ✅ main.dart runs without errors
- ✅ Router configured and functional
- ✅ Navigation state working
- ✅ All tests passing
- ✅ Build successful

**Phase 2 (Feature Pages):**
- ✅ All pages created
- ✅ All pages accessible via routing
- ✅ All pages render correctly
- ✅ All pages have tests
- ✅ Integration complete

**Phase 3 (Integration):**
- ✅ All routes functional
- ✅ Navigation flows complete
- ✅ State management working
- ✅ Firebase connected
- ✅ Error handling implemented

**Phase 4 (Quality Assurance):**
- ✅ 0 analysis errors
- ✅ All tests passing
- ✅ Build successful
- ✅ Documentation complete
- ✅ Matches deployment report

---

## 🔄 Workflow Checklist

### **Before Starting Any Task:**
- [ ] Research patterns using Browser + GitHub MCP (**verify information is updated/current**)
- [ ] Check git history for existing implementations
- [ ] Review project structure using Filesystem MCP (ensure elegant structure)
- [ ] Plan approach using Sequential Thinking MCP
- [ ] Verify all information is accurate and current
- [ ] Plan elegant file structure following Clean Architecture
- [ ] Document plan in Memory MCP (with actual date: MM/DD/YYYY)
- [ ] Note current date for tracking (e.g., 11/13/2025)
- [ ] Identify which phase this task belongs to

### **During Implementation:**
- [ ] Follow Clean Architecture principles
- [ ] Maintain elegant file structure
- [ ] Use updated, accurate information only
- [ ] Verify accuracy of all implementations
- [ ] Work in proper phases (complete current phase before next)
- [ ] Write enterprise-grade, production-ready code
- [ ] NO EMOJIS - Remove all emojis from code, comments, and documentation
- [ ] Follow professional coding standards (elite-level human engineer quality)
- [ ] Write tests alongside code
- [ ] Validate after each change
- [ ] Commit frequently with clear messages (include date: MM/DD/YYYY)
- [ ] Document decisions in Memory MCP (with actual date)
- [ ] Track progress by date for each completed task
- [ ] Cross-reference sources for accuracy
- [ ] Ensure code is maintainable and scalable
- [ ] Follow enterprise security best practices

### **After Completion:**
- [ ] Run `flutter analyze` - 0 errors
- [ ] Run `flutter test` - All passing
- [ ] Run `flutter build` - Successful
- [ ] Manual testing complete
- [ ] Documentation updated
- [ ] Memory MCP updated

---

## 📚 Reference Sources

1. **Flutter Official Documentation** - docs.flutter.dev
2. **GoRouter Package** - pub.dev/packages/go_router
3. **Riverpod Documentation** - riverpod.dev
4. **Firebase Documentation** - firebase.google.com/docs
5. **Clean Architecture Principles** - Based on research synthesis
6. **GitHub Examples** - Real-world Flutter implementations
7. **Project Documentation** - DEPLOYMENT_REPORT_2025_10_27.md

---

## 🎯 Final Reminder

**These rules are designed to ensure:**
- ✅ Robust, maintainable code
- ✅ Proper architecture compliance
- ✅ Comprehensive testing
- ✅ Knowledge preservation
- ✅ Incremental, validated progress
- ✅ **Accurate, updated information** - Always use current, verified information
- ✅ **Elegant file structure** - Maintain clean, logical organization
- ✅ **Proper phase execution** - Complete phases sequentially and fully

**Follow these rules strictly to achieve production-ready restoration.**

**Key Principles:**
1. **Always use updated information** - Verify currency and accuracy
2. **Be as accurate as possible** - Double-check all facts and details
3. **Maintain elegant file structure** - Follow Clean Architecture principles
4. **Work in proper phases** - Complete each phase fully before proceeding
5. **Enterprise-grade code quality** - Match elite-level human full stack engineer standards
6. **NO EMOJIS** - Never use emojis in code, comments, or documentation

---

**Last Updated:** November 13, 2025  
**Maintained By:** AI Development Workflow  
**Status:** Active

---

## 📅 Date Tracking Protocol

### **Current Date:** November 13, 2025

### **Date Usage Requirements:**

1. **Commit Messages:**
   - Format: `Date: MM/DD/YYYY` (e.g., `Date: 11/13/2025`)
   - Include in every commit message
   - Use actual date when commit is made

2. **Memory MCP Entries:**
   - Always include date in observations
   - Format: `[MM/DD/YYYY] Description`
   - Example: `[11/13/2025] Created main.dart with Firebase initialization`

3. **Documentation:**
   - Use actual dates in all documentation
   - Track completion dates for phases
   - Include dates in progress reports

4. **Progress Tracking:**
   - Document start date for each phase
   - Document completion date for each phase
   - Track daily progress with dates

### **Date Format Standard:**
- **Format:** MM/DD/YYYY
- **Example:** 11/13/2025 (November 13, 2025)
- **Never use:** Generic dates, placeholders, or relative dates

### **Date Update Protocol:**
- Update date references when working on new days
- Always use the actual current date
- Never use future dates or placeholder dates

