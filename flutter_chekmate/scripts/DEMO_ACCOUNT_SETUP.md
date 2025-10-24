# ChekMate Demo Account Setup Guide

**Purpose:** Create a pre-authenticated demo account with sample data for client testing

---

## 🎯 **What This Creates**

### **Demo Account Credentials:**
- **Email:** `demouser123@chekmate.app`
- **Password:** `DemoPass123!`
- **Username:** `demouser123`
- **Display Name:** `Demo User`

### **Pre-Populated Data:**
- ✅ **Profile:** Complete with avatar, cover photo, bio, interests
- ✅ **Posts:** 3 sample posts with images, likes, comments
- ✅ **Stories:** 2 active stories (24-hour expiry)
- ✅ **Followers:** 42 followers (sample data)
- ✅ **Following:** 38 following (sample data)
- ✅ **Location:** San Francisco, CA
- ✅ **Verified Badge:** Blue checkmark
- ✅ **Onboarding:** Completed (skip onboarding flow)

---

## 📋 **Prerequisites**

### **1. Node.js**
- **Required:** Node.js 14+ and npm
- **Check:** `node --version` and `npm --version`
- **Install:** https://nodejs.org/

### **2. Firebase Service Account Key**
- **Required:** Admin SDK private key JSON file
- **How to get:**
  1. Go to [Firebase Console](https://console.firebase.google.com/)
  2. Select **ChekMate** project
  3. Click **⚙️ Settings** → **Project settings**
  4. Go to **Service accounts** tab
  5. Click **Generate new private key**
  6. Download the JSON file
  7. Rename to `serviceAccountKey.json`
  8. Move to `flutter_chekmate/scripts/` directory

⚠️ **IMPORTANT:** Never commit `serviceAccountKey.json` to Git! It's already in `.gitignore`.

---

## 🚀 **Setup Instructions**

### **Step 1: Install Dependencies**

```bash
# Navigate to scripts directory
cd flutter_chekmate/scripts

# Initialize npm (if not already done)
npm init -y

# Install Firebase Admin SDK
npm install firebase-admin
```

### **Step 2: Download Service Account Key**

1. Go to: https://console.firebase.google.com/project/chekmate-a0423/settings/serviceaccounts/adminsdk
2. Click **"Generate new private key"**
3. Click **"Generate key"** in the confirmation dialog
4. Save the downloaded JSON file as `serviceAccountKey.json`
5. Move it to `flutter_chekmate/scripts/` directory

**Verify file location:**
```
flutter_chekmate/
  scripts/
    create_demo_account.js
    serviceAccountKey.json  ← Should be here
    DEMO_ACCOUNT_SETUP.md
```

### **Step 3: Run the Script**

```bash
# Make sure you're in the scripts directory
cd flutter_chekmate/scripts

# Run the demo account creation script
node create_demo_account.js
```

**Expected Output:**
```
🚀 Starting demo account creation...

Creating demo user in Firebase Auth...
✅ Demo user created with UID: abc123xyz...

Creating demo user document in Firestore...
✅ Demo user document created

Creating sample posts...
✅ Created 3 sample posts

Creating sample stories...
✅ Created 2 sample stories

Creating sample follower/following relationships...
✅ Created 3 sample follower relationships

✅ Demo account creation complete!

📋 Demo Account Credentials:
   Email: demouser123@chekmate.app
   Password: DemoPass123!
   UID: abc123xyz...

🎉 Client can now log in and test all features!
```

---

## 📝 **Update GitHub Release Notes**

After creating the demo account, update the GitHub Release description to include the demo credentials.

### **Add This Section to Release Notes:**

```markdown
## 🎮 Demo Account (Quick Start)

**Want to skip sign-up and test immediately?** Use our pre-configured demo account:

### **Demo Credentials:**
- **Email:** `demouser123@chekmate.app`
- **Password:** `DemoPass123!`

### **What's Pre-Loaded:**
- ✅ Complete profile with avatar and bio
- ✅ 3 sample posts with images
- ✅ 2 active stories
- ✅ 42 followers, 38 following
- ✅ Sample interests and location
- ✅ Verified badge (blue checkmark)

### **How to Use:**
1. Download and install the APK
2. Open ChekMate app
3. Tap **"Sign In"**
4. Enter demo credentials above
5. Explore all features immediately!

**Note:** This is a shared demo account. Any changes you make will be visible to other testers.
```

---

## 🔄 **Updating the GitHub Release**

### **Method 1: Via Web Browser**

1. Go to: https://github.com/Isakainovorium/ChekMate/releases/tag/v1.0.0-beta
2. Click **"Edit release"**
3. Add the demo account section to the description
4. Click **"Update release"**

### **Method 2: Via GitHub CLI**

```bash
# Update release description
gh release edit v1.0.0-beta --notes-file updated_release_notes.md
```

---

## 🧪 **Testing the Demo Account**

### **Verify Demo Account Works:**

1. **Install APK** on Android device
2. **Open ChekMate** app
3. **Tap "Sign In"**
4. **Enter credentials:**
   - Email: `demouser123@chekmate.app`
   - Password: `DemoPass123!`
5. **Verify features:**
   - ✅ Profile loads with avatar and bio
   - ✅ Posts appear in feed
   - ✅ Stories are visible
   - ✅ Follower/following counts show
   - ✅ All features accessible

---

## 🔧 **Troubleshooting**

### **Error: "Cannot find module 'firebase-admin'"**
**Solution:** Run `npm install firebase-admin` in the scripts directory

### **Error: "Service account key not found"**
**Solution:** 
1. Verify `serviceAccountKey.json` is in `flutter_chekmate/scripts/`
2. Check file name is exactly `serviceAccountKey.json`
3. Ensure it's a valid JSON file

### **Error: "Permission denied"**
**Solution:** 
1. Verify you downloaded the correct service account key
2. Ensure the key has admin permissions
3. Check Firebase project ID matches `chekmate-a0423`

### **Error: "User already exists"**
**Solution:** 
- The script will detect existing user and skip creation
- It will still create posts, stories, and relationships
- To start fresh, delete the user from Firebase Console first

### **Demo account not showing posts/stories**
**Solution:**
1. Check Firestore console: https://console.firebase.google.com/project/chekmate-a0423/firestore
2. Verify `posts` and `stories` collections exist
3. Re-run the script: `node create_demo_account.js`

---

## 🗑️ **Deleting Demo Account (Optional)**

If you need to remove the demo account:

### **Via Firebase Console:**
1. Go to [Firebase Console](https://console.firebase.google.com/project/chekmate-a0423)
2. **Authentication** → Find `demouser123@chekmate.app` → Delete
3. **Firestore** → `users` collection → Find demo user doc → Delete
4. **Firestore** → `posts` collection → Delete demo posts
5. **Firestore** → `stories` collection → Delete demo stories

### **Via Script (Create this if needed):**
```javascript
// delete_demo_account.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function deleteDemoAccount() {
  const auth = admin.auth();
  const firestore = admin.firestore();
  
  try {
    // Get user by email
    const user = await auth.getUserByEmail('demouser123@chekmate.app');
    
    // Delete auth user
    await auth.deleteUser(user.uid);
    
    // Delete Firestore documents
    await firestore.collection('users').doc(user.uid).delete();
    
    // Delete posts
    const posts = await firestore.collection('posts')
      .where('userId', '==', user.uid).get();
    posts.forEach(doc => doc.ref.delete());
    
    // Delete stories
    const stories = await firestore.collection('stories')
      .where('userId', '==', user.uid).get();
    stories.forEach(doc => doc.ref.delete());
    
    console.log('✅ Demo account deleted');
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

deleteDemoAccount();
```

---

## 📊 **Demo Account Statistics**

After creation, the demo account will have:

| Metric | Value |
|--------|-------|
| **Posts** | 3 |
| **Stories** | 2 (active for 24 hours) |
| **Followers** | 42 |
| **Following** | 38 |
| **Likes Received** | 479 (across all posts) |
| **Comments Received** | 80 (across all posts) |
| **Shares Received** | 26 (across all posts) |
| **Story Views** | 156 (across all stories) |
| **Profile Completeness** | 100% |
| **Verification Status** | ✅ Verified |

---

## 🎯 **Benefits for Client Testing**

### **Immediate Access:**
- ✅ No sign-up friction
- ✅ Skip onboarding flow
- ✅ Instant feature exploration

### **Realistic Data:**
- ✅ Pre-populated content
- ✅ Realistic engagement metrics
- ✅ Sample social connections

### **Professional Impression:**
- ✅ Shows app with data
- ✅ Demonstrates all features
- ✅ Polished user experience

---

## 📞 **Support**

If you encounter issues:
1. Check Firebase Console for errors
2. Verify service account key permissions
3. Review script output for error messages
4. Check Firestore security rules allow writes

---

## ✅ **Checklist**

Before sharing with client:

- [ ] Node.js installed
- [ ] Firebase Admin SDK installed (`npm install firebase-admin`)
- [ ] Service account key downloaded and placed in `scripts/` directory
- [ ] Script executed successfully (`node create_demo_account.js`)
- [ ] Demo account tested (can log in)
- [ ] Posts and stories visible in app
- [ ] GitHub Release notes updated with demo credentials
- [ ] Client notified of demo account availability

---

**Ready to create the demo account? Run:**
```bash
cd flutter_chekmate/scripts
node create_demo_account.js
```

