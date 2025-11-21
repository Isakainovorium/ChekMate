# Phase 1: Firebase Deployment Guide

## 📋 Pre-Deployment Checklist

- [ ] All code is committed and tested
- [ ] Firebase project is created and configured
- [ ] Firebase CLI is installed and authenticated
- [ ] Firestore is enabled in Firebase Console
- [ ] Authentication is configured
- [ ] Storage is configured (for future media)

---

## 🔧 Step 1: Create Firestore Collections

### Via Firebase Console

1. Go to **Firebase Console** → Your Project → **Firestore Database**
2. Click **Create Database**
3. Choose **Production mode** (we'll add security rules)
4. Select your region (closest to your users)

### Create Collections

#### Collection 1: `story_templates`
```
Collection: story_templates
Documents: (auto-generated from pre-made templates)

Document Structure:
{
  "id": "first_date_red_flags",
  "title": "First Date Red Flags",
  "description": "Document red flags you noticed on a first date",
  "category": "first_date",
  "icon": "flag",
  "color": "#FF6B6B",
  "difficulty": "Beginner",
  "estimated_minutes": 15,
  "sections": [...],
  "version": "1.0",
  "is_active": true,
  "cover_image_url": null,
  "tags": ["first date", "warning signs", "safety", "red flags"],
  "usage_count": 0,
  "average_rating": 0,
  "created_by": "system",
  "created_at": Timestamp,
  "updated_at": Timestamp,
  "metadata": {}
}
```

#### Collection 2: `user_story_submissions`
```
Collection: user_story_submissions
Documents: (created by users)

Document Structure:
{
  "id": "submission_uuid",
  "template_id": "first_date_red_flags",
  "user_id": "user_uid",
  "responses": [
    {
      "section_id": "venue",
      "response": ["Taken to sketchy area"],
      "metadata": {},
      "timestamp": Timestamp
    }
  ],
  "title": "My First Date Experience",
  "summary": "Had some red flags on this date...",
  "tags": ["first date", "red flags"],
  "privacy": "friends",
  "is_completed": true,
  "created_at": Timestamp,
  "updated_at": Timestamp,
  "completed_at": Timestamp,
  "metadata": {}
}
```

#### Collection 3: `community_guides`
```
Collection: community_guides
Documents: (created by users)

Document Structure:
{
  "id": "guide_uuid",
  "title": "How to Spot Red Flags Early",
  "description": "A comprehensive guide...",
  "category": "safety",
  "content": "...",
  "author_id": "user_uid",
  "author_name": "Username",
  "tags": ["safety", "red flags"],
  "upvotes": 0,
  "downvotes": 0,
  "views": 0,
  "is_featured": false,
  "created_at": Timestamp,
  "updated_at": Timestamp,
  "metadata": {}
}
```

#### Collection 4: `guide_votes`
```
Collection: guide_votes
Documents: (one per user vote)

Document Structure:
{
  "id": "vote_uuid",
  "guide_id": "guide_uuid",
  "user_id": "user_uid",
  "vote_type": "upvote",
  "created_at": Timestamp
}
```

---

## 🔐 Step 2: Deploy Security Rules

### Via Firebase Console

1. Go to **Firestore Database** → **Rules** tab
2. Replace the default rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return request.auth.token.admin == true;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function isEmailVerified() {
      return request.auth.token.email_verified == true;
    }
    
    // ===== STORY TEMPLATES =====
    // Public read, admin write
    match /story_templates/{templateId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
      
      // Subcollection: template_analytics
      match /analytics/{analyticsId} {
        allow read: if isAuthenticated();
        allow write: if isAdmin();
      }
    }
    
    // ===== USER STORY SUBMISSIONS =====
    // User ownership
    match /user_story_submissions/{submissionId} {
      allow read: if isAuthenticated() && (
        isOwner(resource.data.user_id) ||
        resource.data.privacy == 'public'
      );
      allow create: if isAuthenticated() && 
        isOwner(request.resource.data.user_id);
      allow update, delete: if isAuthenticated() && 
        isOwner(resource.data.user_id);
      
      // Subcollection: comments
      match /comments/{commentId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated();
        allow update, delete: if isAuthenticated() && 
          isOwner(resource.data.user_id);
      }
    }
    
    // ===== COMMUNITY GUIDES =====
    // Authenticated read, verified email create
    match /community_guides/{guideId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && isEmailVerified();
      allow update, delete: if isAuthenticated() && 
        isOwner(resource.data.author_id);
      
      // Subcollection: comments
      match /comments/{commentId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated();
        allow update, delete: if isAuthenticated() && 
          isOwner(resource.data.user_id);
      }
    }
    
    // ===== GUIDE VOTES =====
    // Authenticated users can vote
    match /guide_votes/{voteId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated() && 
        isOwner(resource.data.user_id);
    }
    
    // ===== USER PROFILES (for guide authors) =====
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && isOwner(userId);
    }
    
    // ===== ANALYTICS =====
    match /analytics/{analyticsId} {
      allow read: if isAdmin();
      allow write: if isAdmin();
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click **Publish**

---

## 📊 Step 3: Seed Pre-made Templates

### Option A: Via Firebase Console (Manual)

1. Go to **Firestore Database** → **story_templates** collection
2. Click **Add document**
3. Set document ID to template ID (e.g., `first_date_red_flags`)
4. Add fields from `premade_templates.dart`

### Option B: Via Firebase Admin SDK (Recommended)

Create a script `scripts/seed_templates.js`:

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const templates = [
  {
    id: 'first_date_red_flags',
    title: 'First Date Red Flags',
    description: 'Document red flags you noticed on a first date',
    category: 'first_date',
    icon: 'flag',
    color: '#FF6B6B',
    difficulty: 'Beginner',
    estimated_minutes: 15,
    sections: [
      // ... sections from premade_templates.dart
    ],
    version: '1.0',
    is_active: true,
    tags: ['first date', 'warning signs', 'safety', 'red flags'],
    usage_count: 0,
    average_rating: 0,
    created_by: 'system',
    created_at: admin.firestore.Timestamp.now(),
    updated_at: admin.firestore.Timestamp.now(),
  },
  // ... other templates
];

async function seedTemplates() {
  try {
    for (const template of templates) {
      await db.collection('story_templates').doc(template.id).set(template);
      console.log(`✓ Created template: ${template.title}`);
    }
    console.log('✓ All templates seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('✗ Error seeding templates:', error);
    process.exit(1);
  }
}

seedTemplates();
```

Run:
```bash
node scripts/seed_templates.js
```

### Option C: Via Flutter App (During First Run)

Add to your app initialization:

```dart
Future<void> _seedTemplatesIfNeeded() async {
  final firestore = FirebaseFirestore.instance;
  final templatesRef = firestore.collection('story_templates');
  
  // Check if templates already exist
  final snapshot = await templatesRef.limit(1).get();
  if (snapshot.docs.isNotEmpty) {
    print('Templates already seeded');
    return;
  }
  
  // Seed templates
  final templates = PremadeTemplates.getAllTemplates();
  for (final template in templates) {
    await templatesRef.doc(template.id).set(template.toJson());
    print('Seeded: ${template.title}');
  }
}
```

Call during app startup:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _seedTemplatesIfNeeded();
  runApp(const MyApp());
}
```

---

## 🔍 Step 4: Verify Deployment

### Check Collections Exist
```bash
firebase firestore:list-collections
```

### Check Security Rules
```bash
firebase firestore:get-rules
```

### Test Read Access
```dart
final templates = await FirebaseFirestore.instance
    .collection('story_templates')
    .get();
print('Found ${templates.docs.length} templates');
```

### Test Write Access
```dart
await FirebaseFirestore.instance
    .collection('user_story_submissions')
    .add({
      'template_id': 'first_date_red_flags',
      'user_id': currentUser.uid,
      'title': 'Test',
      'summary': 'Test submission',
      'responses': [],
      'privacy': 'private',
      'is_completed': false,
      'created_at': FieldValue.serverTimestamp(),
    });
```

---

## 📈 Step 5: Enable Monitoring

### Set Up Firestore Monitoring

1. Go to **Firebase Console** → **Firestore Database** → **Monitoring**
2. Enable the following metrics:
   - Document reads
   - Document writes
   - Document deletes
   - Network bandwidth

### Set Up Alerts

1. Go to **Google Cloud Console** → **Monitoring** → **Alerting**
2. Create alerts for:
   - High read/write rates
   - Quota exceeded
   - Errors

### Enable Audit Logs

1. Go to **Google Cloud Console** → **Audit Logs**
2. Enable Data Access logs for Firestore

---

## 🚀 Step 6: Production Deployment

### Before Going Live

- [ ] Test all CRUD operations
- [ ] Test security rules with different user roles
- [ ] Load test with expected user volume
- [ ] Verify offline persistence works
- [ ] Check error handling
- [ ] Monitor quota usage

### Deployment Steps

1. **Backup existing data** (if any)
   ```bash
   firebase firestore:export gs://your-bucket/backup
   ```

2. **Deploy security rules**
   ```bash
   firebase deploy --only firestore:rules
   ```

3. **Deploy indexes** (if needed)
   ```bash
   firebase deploy --only firestore:indexes
   ```

4. **Monitor for 24 hours**
   - Check error rates
   - Monitor quota usage
   - Verify user submissions are working

---

## 🔄 Step 7: Ongoing Maintenance

### Weekly Tasks
- [ ] Check Firestore quota usage
- [ ] Review error logs
- [ ] Monitor performance metrics

### Monthly Tasks
- [ ] Backup data
- [ ] Review security rules
- [ ] Analyze usage patterns
- [ ] Update templates if needed

### Quarterly Tasks
- [ ] Performance optimization
- [ ] Security audit
- [ ] Capacity planning

---

## 🆘 Troubleshooting

### Issue: Permission Denied on Read
**Solution**: Check security rules allow authenticated users to read templates
```javascript
allow read: if isAuthenticated();
```

### Issue: Permission Denied on Write
**Solution**: Check user is owner of document
```javascript
allow write: if isAuthenticated() && isOwner(resource.data.user_id);
```

### Issue: Templates Not Appearing
**Solution**: Verify templates are seeded
```bash
firebase firestore:list-documents story_templates
```

### Issue: High Quota Usage
**Solution**: 
- Implement caching
- Reduce read frequency
- Use batch operations
- Consider Firestore pricing plan

---

## 📊 Firestore Pricing Estimate

### Expected Usage (per month)
- **Reads**: ~100,000 (templates + submissions)
- **Writes**: ~10,000 (new submissions)
- **Deletes**: ~1,000 (cleanup)
- **Storage**: ~100 MB

### Estimated Cost
- **Reads**: $0.06 (100k reads × $0.06 per 100k)
- **Writes**: $0.06 (10k writes × $0.06 per 100k)
- **Deletes**: $0.01 (1k deletes × $0.06 per 100k)
- **Storage**: $0.18 (100 MB × $0.18 per GB)
- **Total**: ~$0.31/month (very low)

---

## 🎯 Success Criteria

- [ ] All templates are accessible
- [ ] Users can create submissions
- [ ] Security rules prevent unauthorized access
- [ ] No errors in logs
- [ ] Performance is acceptable
- [ ] Quota usage is within limits

---

## 📞 Support

For Firebase issues:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Firebase Support](https://firebase.google.com/support)

---

*Last Updated: November 20, 2025*
