# ChekMate MCP Tools Reference & Workflow Guide

**Last Updated:** October 17, 2025  
**Purpose:** Comprehensive reference for all enabled MCP (Model Context Protocol) tools and their optimal usage in the ChekMate development workflow  
**Status:** Active - Phase 1 Complete, Phase 2 Ready

---

## 📋 TABLE OF CONTENTS

1. [Overview](#overview)
2. [Enabled MCP Tools](#enabled-mcp-tools)
3. [Tool Selection Matrix](#tool-selection-matrix)
4. [Workflow Integration](#workflow-integration)
5. [Phase-Specific Tool Usage](#phase-specific-tool-usage)
6. [Best Practices](#best-practices)
7. [Quick Reference](#quick-reference)

---

## 1. OVERVIEW

### **What are MCP Tools?**

MCP (Model Context Protocol) tools are specialized integrations that extend AI assistant capabilities beyond the codebase. They provide:

- **Real-time information access** (web search, documentation)
- **CI/CD integration** (automated testing, deployment)
- **Visual testing** (UI validation, screenshot comparison)
- **Documentation retrieval** (package docs, API references)

### **ChekMate's MCP Stack**

We have **5 primary MCP tools** enabled:

1. **Exa MCP** - AI-powered web search
2. **LangChain MCP** - Documentation access
3. **CircleCI MCP** - CI/CD automation
4. **Context7 MCP** - Package documentation
5. **Playwright MCP** - Visual testing & browser automation

---

## 2. ENABLED MCP TOOLS

### **Tool 1: Exa MCP** 🔍

**Type:** Web Search & Research  
**Provider:** Exa Labs (https://exa.ai)  
**Status:** ✅ Enabled  
**Cost:** Free tier + paid ($0.001-0.01 per search)

**Capabilities:**
- Real-time semantic web search
- Domain-specific filtering (GitHub, Stack Overflow, docs)
- Content extraction from web pages
- Historical data search (any time period)
- Deep research (1000s of results)

**Best For:**
- Finding recent GitHub issues
- Stack Overflow solutions
- Real-world code examples
- Current trends and news
- Production app references

**Example Usage:**
```
"Use Exa to find Flutter 3.24 camera plugin issues from last 30 days"
"Search GitHub for Flutter apps using agora_rtc_engine with Riverpod"
"Find Stack Overflow answers about Firebase Auth in Flutter"
```

**Documentation:** `docs/tools/EXA_MCP_GUIDE.md`

---

### **Tool 2: LangChain MCP** 📚

**Type:** Documentation Access  
**Provider:** LangChain (https://langchain.com)  
**Status:** ✅ Enabled (configured in Phase 0)  
**Cost:** Based on LangChain plan

**Capabilities:**
- Access to official package documentation
- API reference retrieval
- Framework guides (Flutter, Firebase, etc.)
- Structured documentation search
- Code examples from official sources

**Best For:**
- Official API references
- Package setup guides
- Framework documentation
- Migration guides
- Official code examples

**Example Usage:**
```
"Show me the official Firebase Auth setup guide"
"Get the API reference for image_picker package"
"Find Riverpod provider configuration docs"
```

**Configuration:** `C:\Users\IsaKai2296\.chekmate\langchain.env`  
**Documentation:** `docs/LANGCHAIN_MCP_SETUP.md`

---

### **Tool 3: CircleCI MCP** 🔄

**Type:** CI/CD Automation  
**Provider:** CircleCI (https://circleci.com)  
**Status:** ✅ Enabled (configured in Phase 1)  
**Cost:** Free tier (2,500 credits/month)

**Capabilities:**
- Trigger pipeline runs
- Get build failure logs
- Find flaky tests
- Check pipeline status
- Download usage data
- Analyze resource usage
- Rerun workflows
- Validate config files

**Best For:**
- Automated testing
- Build verification
- Test coverage reporting
- CI/CD troubleshooting
- Pipeline optimization

**Project:** `circleci/Dgq4rnVu5NzPtG14JcVLsy/9V7jsYiK8dDGLSyi9ZRL7S`  
**Branch:** `master`  
**Configuration:** `.circleci/config.yml`  
**Documentation:** `docs/tools/CIRCLECI_MCP_GUIDE.md`

---

### **Tool 4: Context7 MCP** 📖

**Type:** Package Documentation Retrieval  
**Provider:** Context7  
**Status:** ✅ Enabled  
**Cost:** Free

**Capabilities:**
- Resolve package/library IDs
- Fetch up-to-date documentation
- Topic-focused documentation
- Version-specific docs
- Code snippet retrieval

**Best For:**
- Package-specific documentation
- Version compatibility checks
- API usage examples
- Library integration guides

**Example Usage:**
```
"Get documentation for firebase_auth package"
"Show me agora_rtc_engine API reference"
"Find Riverpod hooks documentation"
```

**Documentation:** `docs/tools/CONTEXT7_MCP_GUIDE.md`

---

### **Tool 5: Playwright MCP** 🎭

**Type:** Visual Testing & Browser Automation  
**Provider:** Microsoft Playwright  
**Status:** ✅ Enabled  
**Cost:** Free (open source)

**Capabilities:**
- Browser automation (Chrome, Firefox, Safari)
- Visual regression testing
- Screenshot capture
- UI interaction testing
- Accessibility testing
- Network request monitoring
- Cross-browser testing

**Best For:**
- End-of-phase visual validation
- UI regression testing
- Screenshot comparison
- Accessibility audits
- Cross-platform testing

**Planned Usage:**
- **Phase 1:** Visual baseline capture
- **Phase 2:** Voice/video UI testing
- **Phase 3:** Multi-photo post UI validation
- **Phase 4:** Notification UI testing
- **Phase 5:** Full app visual regression suite

**Documentation:** `docs/tools/PLAYWRIGHT_MCP_GUIDE.md`

---

## 3. TOOL SELECTION MATRIX

### **When to Use Which Tool?**

| Scenario | Primary Tool | Secondary Tool | Tertiary Tool |
|----------|-------------|----------------|---------------|
| **Official API reference** | Context7 | LangChain | - |
| **Real-world examples** | Exa | GitHub Search | - |
| **Debugging errors** | Exa (Stack Overflow) | LangChain | Context7 |
| **Package setup** | Context7 | LangChain | Exa |
| **CI/CD issues** | CircleCI | Exa | - |
| **Visual testing** | Playwright | - | - |
| **Recent trends** | Exa | - | - |
| **Migration guides** | LangChain | Context7 | Exa |
| **Test coverage** | CircleCI | - | - |
| **UI validation** | Playwright | - | - |

---

## 4. WORKFLOW INTEGRATION

### **Development Workflow**

```
┌─────────────────────────────────────────────────────────────┐
│                    CHEKMATE DEVELOPMENT WORKFLOW             │
└─────────────────────────────────────────────────────────────┘

1. PLANNING PHASE
   ├─ Context7: Get package documentation
   ├─ LangChain: Official framework guides
   └─ Exa: Real-world examples & best practices

2. IMPLEMENTATION PHASE
   ├─ Codebase Retrieval: Existing patterns
   ├─ Context7: API references
   └─ Exa: Troubleshooting (as needed)

3. TESTING PHASE
   ├─ CircleCI: Run automated tests
   ├─ Playwright: Visual validation
   └─ CircleCI: Coverage reports

4. DEBUGGING PHASE
   ├─ Exa: Search error messages
   ├─ CircleCI: Build logs
   └─ LangChain: Official troubleshooting

5. DEPLOYMENT PHASE
   ├─ CircleCI: Build & deploy
   ├─ Playwright: Pre-deployment visual tests
   └─ CircleCI: Monitor pipeline
```

---

## 5. PHASE-SPECIFIC TOOL USAGE

### **Phase 1: Critical Fixes & Foundation** ✅ COMPLETE

**Tools Used:**
- ✅ CircleCI: Pipeline setup, test automation
- ✅ LangChain: Firebase documentation
- ✅ Context7: Package references

**Deliverables:**
- CircleCI pipeline configured
- 113 tests passing
- 15% coverage achieved

---

### **Phase 2: Voice/Video Features** (NEXT)

**Recommended Tools:**
- 🔍 **Exa:** Search for agora_rtc_engine issues, WebRTC examples
- 📚 **Context7:** agora_rtc_engine API reference
- 📖 **LangChain:** Camera/microphone permission guides
- 🔄 **CircleCI:** Automated testing for voice/video features
- 🎭 **Playwright:** Visual testing for video UI components

**Example Queries:**
```
Exa: "Find Flutter agora_rtc_engine iOS permission issues 2025"
Context7: "Get agora_rtc_engine documentation"
LangChain: "Show camera plugin setup guide"
CircleCI: "Run tests for voice message feature"
Playwright: "Capture screenshot of video call UI"
```

---

### **Phase 3-5: Advanced Features**

See individual phase documentation in `docs/tools/PHASE_TOOL_USAGE.md`

---

## 6. BEST PRACTICES

### **Cost Optimization**

1. **Use free tools first:** Context7, Playwright, CircleCI (free tier)
2. **Strategic Exa usage:** Only for complex/current issues
3. **Batch queries:** Combine related questions
4. **Cache results:** Document findings for reuse

### **Efficiency Tips**

1. **Start specific:** Use Context7/LangChain for known packages
2. **Escalate to Exa:** When official docs don't have answers
3. **Automate with CircleCI:** Don't manually run tests
4. **Visual validation:** Use Playwright at end of each phase

### **Quality Assurance**

1. **Always verify:** Cross-reference information from multiple tools
2. **Test before commit:** Use CircleCI to catch issues early
3. **Visual regression:** Use Playwright to prevent UI breaks
4. **Document decisions:** Record tool usage in ADRs

---

## 7. QUICK REFERENCE

### **Tool Access Commands**

```bash
# Exa Search
"Use Exa to search for [query]"

# LangChain Documentation
"Use LangChain to get [package] documentation"

# Context7 Package Docs
"Get Context7 documentation for [package]"

# CircleCI Operations
"Trigger CircleCI pipeline"
"Get CircleCI build logs"
"Check CircleCI test results"

# Playwright Visual Testing
"Use Playwright to capture screenshot"
"Run Playwright visual tests"
```

### **Configuration Files**

```
LangChain:   C:\Users\IsaKai2296\.chekmate\langchain.env
CircleCI:    .circleci/config.yml
Playwright:  (to be created in Phase 2)
```

### **Documentation Index**

- `EXA_MCP_GUIDE.md` - Exa search strategies
- `LANGCHAIN_MCP_SETUP.md` - LangChain configuration
- `CIRCLECI_MCP_GUIDE.md` - CI/CD workflows
- `CONTEXT7_MCP_GUIDE.md` - Package documentation
- `PLAYWRIGHT_MCP_GUIDE.md` - Visual testing setup
- `PLAYWRIGHT_MCP_COMMANDS.md` - Playwright command reference ⭐ NEW
- `HYBRID_VISUAL_TESTING_WORKFLOW.md` - Hybrid visual testing workflow ⭐ NEW
- `PHASE_TOOL_USAGE.md` - Phase-specific tool recommendations

---

**Next Steps:**
1. Review individual tool guides
2. Set up Playwright for Phase 2
3. Create visual testing baseline
4. Integrate tools into daily workflow

**Maintained by:** ChekMate Development Team  
**Last Review:** October 17, 2025  
**Next Review:** Before Phase 2 start

