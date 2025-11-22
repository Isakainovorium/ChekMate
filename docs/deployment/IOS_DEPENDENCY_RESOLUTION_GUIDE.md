# iOS Dependency Resolution Guide - Best Practices

**Last Updated**: November 21, 2025  
**For**: ChekMate iOS Deployment

---

## 🎯 Root Cause Analysis

### The Problem
Firebase SDK + Google Sign-In dependency conflicts in CocoaPods due to:
1. **Incompatible SDK versions** (GoogleSignIn 8.0 vs Firebase 10.22.0)
2. **Insufficient iOS deployment target** (iOS 15.0 too low for modern SDKs)
3. **Pod version conflicts** across transitive dependencies

### The Solution
**Raise iOS deployment target to 17.0** and let CocoaPods resolve dependencies automatically.

---

## ✅ Best Practice Configuration

### 1. iOS Deployment Target

**Minimum**: iOS 17.0 (as of Nov 2025)

**Why**:
- GoogleSignIn 7.x+ requires iOS 15.5+
- GoogleSignIn 8.0 requires iOS 16.0+
- Firebase SDK 10.22.0 works best with iOS 15.5+
- iOS 17.0 provides **maximum compatibility** with all modern SDKs

**Implementation**:
```ruby
# Podfile
platform :ios, '17.0'
$iOSVersion = '17.0'
```

---

### 2. Complete Podfile Configuration

```ruby
# iOS 17.0 provides excellent compatibility with latest Firebase and Google SDKs
platform :ios, '17.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# Set minimum iOS version for all pods
$iOSVersion = '17.0'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  # Set deployment target for all pods to ensure compatibility
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=*]"] = "armv7"
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
  end
  
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      # Ensure all pods use iOS 17.0 minimum
      if Gem::Version.new($iOSVersion) > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iOSVersion
      end
    end
  end
end
```

---

### 3. pubspec.yaml Dependencies

**Current Working Versions**:
```yaml
dependencies:
  # Firebase
  firebase_core: ^2.27.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.15.8
  firebase_analytics: ^10.8.9
  firebase_storage: ^11.6.9
  firebase_messaging: ^14.7.19
  firebase_crashlytics: ^3.4.9
  
  # Authentication
  google_sign_in: ^6.1.6  # Compatible with Firebase SDK 10.22.0
  sign_in_with_apple: ^5.0.0
```

**Key Point**: `google_sign_in: ^6.1.6` uses GoogleSignIn SDK 7.x which is compatible with Firebase.

---

## 🚫 What NOT to Do

### ❌ Don't Force Specific Pod Versions
```ruby
# WRONG - Creates conflicts
pod 'GoogleSignIn', '~> 7.1'
```

**Why**: Let CocoaPods resolve dependencies automatically with the correct iOS deployment target.

### ❌ Don't Use Low iOS Deployment Targets
```ruby
# WRONG - Too low for modern SDKs
platform :ios, '13.0'  # or 14.0, 15.0
```

**Why**: Modern Firebase and Google SDKs require iOS 15.5+ minimum.

### ❌ Don't Skip post_install Configuration
```ruby
# WRONG - Incomplete
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

**Why**: All pods must enforce the same deployment target.

---

## 🔍 Troubleshooting Decision Tree

### Error: "requires a higher minimum deployment target"

**Solution**:
1. ✅ Raise `platform :ios` to `'17.0'`
2. ✅ Set `$iOSVersion = '17.0'`
3. ✅ Add post_install enforcement (see above)

### Error: "CocoaPods could not find compatible versions for pod X"

**Check**:
1. Is iOS deployment target >= 17.0? ✅
2. Are pubspec.yaml versions compatible? ✅
3. Is post_install enforcing deployment target? ✅

**Solution**:
- Update to iOS 17.0
- Remove explicit pod version overrides
- Let CocoaPods auto-resolve

### Error: "GoogleUtilities/Environment" version conflict

**Root Cause**: GoogleSignIn 8.0 requires GoogleUtilities 8.x, but Firebase requires 7.x

**Solution**:
- Use `google_sign_in: ^6.1.6` (uses GoogleSignIn SDK 7.x)
- Set iOS deployment target to 17.0
- Remove explicit pod versions

---

## 📊 Compatibility Matrix

| iOS Version | GoogleSignIn SDK | Firebase SDK | Status |
|-------------|------------------|--------------|--------|
| 13.0        | 7.x ❌ / 8.0 ❌   | 10.22.0 ⚠️    | ❌ Too Low |
| 15.0        | 7.x ⚠️ / 8.0 ❌   | 10.22.0 ✅    | ⚠️ Marginal |
| 15.5        | 7.x ✅ / 8.0 ⚠️   | 10.22.0 ✅    | ✅ Minimum |
| 17.0        | 7.x ✅ / 8.0 ✅   | 10.22.0 ✅    | ✅ **Recommended** |

---

## 🎯 Step-by-Step Fix Process

### When You Encounter Dependency Conflicts:

1. **Identify the Error Type**
   - Deployment target too low?
   - Version conflict?
   - Missing dependencies?

2. **Check iOS Deployment Target**
   ```ruby
   platform :ios, '17.0'  # Must be 17.0
   ```

3. **Verify pubspec.yaml Versions**
   ```yaml
   google_sign_in: ^6.1.6  # NOT 6.2.x
   ```

4. **Ensure post_install Enforcement**
   - Must set deployment target on ALL pods
   - Must exclude armv7 architecture

5. **Clean and Rebuild**
   ```bash
   cd flutter_chekmate
   flutter clean
   flutter pub get
   cd ios
   pod deintegrate
   pod install
   ```

6. **Commit and Push**
   ```bash
   git add Podfile pubspec.yaml
   git commit -m "Fix: Update iOS deployment target to 17.0"
   git push origin master
   ```

7. **Trigger CI Build**
   - Use master branch
   - Verify build passes CocoaPods step

---

## 📝 CI/CD Best Practices

### codemagic.yaml

**Already Configured**:
```yaml
scripts:
  - name: Install dependencies
    script: |
      cd flutter_chekmate
      # Remove Generated.xcconfig if it exists (contains local paths)
      rm -f ios/Flutter/Generated.xcconfig
      flutter pub get
```

**Why**: Generated.xcconfig contains machine-specific paths and must be regenerated in CI.

---

## 🔄 Future Updates

### When Updating Firebase or Google Sign-In:

1. **Check Compatibility**
   - Visit https://pub.dev/packages/google_sign_in
   - Check "Versions" tab for latest compatible version
   - Read changelog for breaking changes

2. **Test Locally First**
   ```bash
   flutter pub upgrade google_sign_in
   cd ios && pod update
   ```

3. **Verify Build**
   ```bash
   flutter build ios --release
   ```

4. **Update Documentation**
   - Update this guide with new versions
   - Note any configuration changes

---

## 📚 References

- [Flutter Google Sign-In Package](https://pub.dev/packages/google_sign_in)
- [Firebase Flutter Plugins](https://firebase.flutter.dev/)
- [CocoaPods Dependency Resolution](https://guides.cocoapods.org/using/the-podfile.html)
- [iOS Deployment Target Guide](https://developer.apple.com/documentation/xcode/choosing-a-deployment-target)

---

## ✅ Success Criteria

Build succeeds when:
- ✅ CocoaPods resolves all dependencies
- ✅ No version conflicts
- ✅ No deployment target errors
- ✅ IPA builds successfully
- ✅ File size < 200MB

---

**Last Verified**: November 21, 2025  
**Next Review**: When updating Firebase or Google Sign-In packages
