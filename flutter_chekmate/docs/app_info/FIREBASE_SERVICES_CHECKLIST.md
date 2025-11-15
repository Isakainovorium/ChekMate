# 🔥 Firebase Services Checklist

## ✅ **DONE: Firebase Config Updated!**

Your `firebase_options.dart` has been updated with your Firebase project credentials!

**Project:** chekmate-a0423

---

## 🎯 **Next: Enable Firebase Services**

Go to your Firebase Console: https://console.firebase.google.com/project/chekmate-a0423

### **1. Enable Authentication** ⏳

1. Click **"Build"** in left sidebar
2. Click **"Authentication"**
3. Click **"Get started"** button

**Enable Email/Password:**
- Click "Email/Password" provider
- Toggle "Enable" to ON
- Click "Save"

**Enable Google Sign-In:**
- Click "Google" provider
- Toggle "Enable" to ON
- Select your email from dropdown
- Click "Save"

---

### **2. Create Firestore Database** ⏳

1. Click **"Build"** → **"Firestore Database"**
2. Click **"Create database"**
3. Select **"Start in test mode"**
4. Click "Next"
5. Choose location: **us-central1** (or closest to you)
6. Click "Enable"
7. Wait 1-2 minutes for creation

---

### **3. Enable Storage** ⏳

1. Click **"Build"** → **"Storage"**
2. Click **"Get started"**
3. Select **"Start in test mode"**
4. Click "Next"
5. Use same location as Firestore
6. Click "Done"

---

## 🚀 **After Enabling Services**

Once you've enabled all three services above:

1. **Go to your Flutter terminal** (where the app is running)
2. **Press `r`** to hot reload
3. **Test the app:**
   - Try signing up with email/password
   - Try logging in
   - Create a post
   - Upload an image

---

## ✅ **Verification**

Your app should now:
- ✅ Allow user registration
- ✅ Allow user login
- ✅ Save data to Firestore
- ✅ Upload images to Storage
- ✅ Track analytics

---

## 🆘 **If You See Errors**

**"Firebase: Error (auth/operation-not-allowed)"**
→ Enable Email/Password authentication in Firebase Console

**"Missing or insufficient permissions"**
→ Make sure Firestore is in test mode

**"Storage: User does not have permission"**
→ Make sure Storage is in test mode

---

## 📋 **Quick Links**

- **Firebase Console**: https://console.firebase.google.com/project/chekmate-a0423
- **Authentication**: https://console.firebase.google.com/project/chekmate-a0423/authentication
- **Firestore**: https://console.firebase.google.com/project/chekmate-a0423/firestore
- **Storage**: https://console.firebase.google.com/project/chekmate-a0423/storage

---

**Once you've enabled these services, just press `r` in your terminal and Firebase will be fully connected!** 🎉


