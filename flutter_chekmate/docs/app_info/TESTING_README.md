# 🧪 ChekMate Testing - Quick Start

## ⚡ **FAST FLUTTER TESTING ONLY**

We use **Flutter's native testing** for maximum speed and reliability.

### **🚀 Run All Tests (One Command)**
```bash
# Windows
.\run_tests.bat

# PowerShell/Cross-platform  
.\run_tests.ps1
```

### **🎯 Manual Commands**
```bash
# Unit & Widget Tests (fast - seconds)
flutter test

# Integration Tests (medium - 10-30 seconds)
flutter test integration_test

# With Coverage Report
flutter test --coverage
```

---

## 📊 **What Gets Tested**

✅ **Unit Tests** - Services, models, utilities  
✅ **Widget Tests** - UI components  
✅ **Integration Tests** - Complete user flows  
✅ **Coverage Reports** - Code coverage metrics

---

## ⏱️ **Performance**

| Test Type | Duration |
|-----------|----------|
| Unit Tests | 2-5 seconds |
| Widget Tests | 5-10 seconds |
| Integration Tests | 10-30 seconds |
| **Total Suite** | **< 1 minute** |

---

## 📁 **Test Files**

```
test/                    # Unit & Widget Tests
├── models/             # Model tests
├── services/           # Service tests  
├── widgets/            # Widget tests
└── widget_test.dart    # Main app test

integration_test/        # Integration Tests
└── app_test.dart       # End-to-end flows
```

---

## 🔧 **Troubleshooting**

**Tests not found?**
- Make sure files end with `_test.dart`
- Check you're in the `flutter_chekmate/` directory

**Tests failing?**
- Run with verbose: `flutter test --verbose`
- Check specific test: `flutter test test/specific_test.dart`

---

## 📚 **More Info**

See `FLUTTER_TESTING_GUIDE.md` for detailed documentation.

---

**🎉 That's it! Fast, simple Flutter testing with no external dependencies.**
