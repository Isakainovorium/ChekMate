/**
 * ChekMate Demo Account Creation Script
 * 
 * This script creates a pre-authenticated demo account with sample data
 * for client testing purposes.
 * 
 * Requirements:
 * - Node.js installed
 * - Firebase Admin SDK
 * - Service account key JSON file
 * 
 * Usage:
 *   node create_demo_account.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'chekmate-a0423.firebasestorage.app'
});

const auth = admin.auth();
const firestore = admin.firestore();
const storage = admin.storage();

// Demo account credentials
const DEMO_EMAIL = 'demouser123@chekmate.app';
const DEMO_PASSWORD = 'DemoPass123!';
const DEMO_USERNAME = 'demouser123';
const DEMO_DISPLAY_NAME = 'Demo User';

/**
 * Create demo user in Firebase Authentication
 */
async function createDemoAuthUser() {
  try {
    console.log('Creating demo user in Firebase Auth...');
    
    // Check if user already exists
    try {
      const existingUser = await auth.getUserByEmail(DEMO_EMAIL);
      console.log(`Demo user already exists with UID: ${existingUser.uid}`);
      return existingUser.uid;
    } catch (error) {
      // User doesn't exist, create new one
      const userRecord = await auth.createUser({
        email: DEMO_EMAIL,
        password: DEMO_PASSWORD,
        displayName: DEMO_DISPLAY_NAME,
        emailVerified: true, // Pre-verify email
      });
      
      console.log(`✅ Demo user created with UID: ${userRecord.uid}`);
      return userRecord.uid;
    }
  } catch (error) {
    console.error('❌ Error creating demo auth user:', error);
    throw error;
  }
}

/**
 * Create demo user document in Firestore
 */
async function createDemoUserDocument(uid) {
  try {
    console.log('Creating demo user document in Firestore...');
    
    const userDoc = {
      uid: uid,
      email: DEMO_EMAIL,
      username: DEMO_USERNAME,
      displayName: DEMO_DISPLAY_NAME,
      bio: '👋 Hi! I\'m a demo account for testing ChekMate. Feel free to explore all features!',
      avatar: 'https://ui-avatars.com/api/?name=Demo+User&size=512&background=F5A623&color=fff',
      coverPhoto: 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=1200',
      followers: 42,
      following: 38,
      posts: 12,
      isVerified: true, // Verified badge
      isPremium: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      onboardingCompleted: true,
      location: 'San Francisco, CA',
      age: 28,
      gender: 'Other',
      interests: ['Technology', 'Travel', 'Photography', 'Music', 'Food'],
      locationEnabled: true,
      searchRadiusKm: 50.0,
      coordinates: new admin.firestore.GeoPoint(37.7749, -122.4194), // San Francisco
      geohash: '9q8yy', // San Francisco geohash
      videoIntroUrl: null, // Will be added if you upload a sample video
      voicePrompts: [
        {
          id: 'prompt1',
          question: 'What\'s your favorite hobby?',
          audioUrl: null, // Will be added if you upload sample audio
          duration: 0,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        }
      ],
    };
    
    await firestore.collection('users').doc(uid).set(userDoc);
    console.log('✅ Demo user document created');
    
    return userDoc;
  } catch (error) {
    console.error('❌ Error creating demo user document:', error);
    throw error;
  }
}

/**
 * Create sample posts for demo user
 */
async function createSamplePosts(uid) {
  try {
    console.log('Creating sample posts...');
    
    const posts = [
      {
        userId: uid,
        username: DEMO_USERNAME,
        displayName: DEMO_DISPLAY_NAME,
        userAvatar: 'https://ui-avatars.com/api/?name=Demo+User&size=512&background=F5A623&color=fff',
        caption: '🌅 Beautiful sunset at the Golden Gate Bridge! #SanFrancisco #Sunset',
        mediaUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=800',
        mediaType: 'image',
        likes: 156,
        comments: 23,
        shares: 8,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        isPublic: true,
      },
      {
        userId: uid,
        username: DEMO_USERNAME,
        displayName: DEMO_DISPLAY_NAME,
        userAvatar: 'https://ui-avatars.com/api/?name=Demo+User&size=512&background=F5A623&color=fff',
        caption: '☕ Morning coffee vibes ☕ #CoffeeLovers #MorningRoutine',
        mediaUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
        mediaType: 'image',
        likes: 89,
        comments: 12,
        shares: 3,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        isPublic: true,
      },
      {
        userId: uid,
        username: DEMO_USERNAME,
        displayName: DEMO_DISPLAY_NAME,
        userAvatar: 'https://ui-avatars.com/api/?name=Demo+User&size=512&background=F5A623&color=fff',
        caption: '🎵 Loving this new track! What are you listening to? #Music #NowPlaying',
        mediaUrl: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=800',
        mediaType: 'image',
        likes: 234,
        comments: 45,
        shares: 15,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        isPublic: true,
      },
    ];
    
    const batch = firestore.batch();
    posts.forEach((post, index) => {
      const postRef = firestore.collection('posts').doc();
      batch.set(postRef, post);
    });
    
    await batch.commit();
    console.log(`✅ Created ${posts.length} sample posts`);
  } catch (error) {
    console.error('❌ Error creating sample posts:', error);
    throw error;
  }
}

/**
 * Create sample stories for demo user
 */
async function createSampleStories(uid) {
  try {
    console.log('Creating sample stories...');
    
    const now = new Date();
    const expiresAt = new Date(now.getTime() + 24 * 60 * 60 * 1000); // 24 hours from now
    
    const stories = [
      {
        userId: uid,
        username: DEMO_USERNAME,
        displayName: DEMO_DISPLAY_NAME,
        userAvatar: 'https://ui-avatars.com/api/?name=Demo+User&size=512&background=F5A623&color=fff',
        mediaUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        mediaType: 'image',
        views: 67,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
      },
      {
        userId: uid,
        username: DEMO_USERNAME,
        displayName: DEMO_DISPLAY_NAME,
        userAvatar: 'https://ui-avatars.com/api/?name=Demo+User&size=512&background=F5A623&color=fff',
        mediaUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800',
        mediaType: 'image',
        views: 89,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
      },
    ];
    
    const batch = firestore.batch();
    stories.forEach((story) => {
      const storyRef = firestore.collection('stories').doc();
      batch.set(storyRef, story);
    });
    
    await batch.commit();
    console.log(`✅ Created ${stories.length} sample stories`);
  } catch (error) {
    console.error('❌ Error creating sample stories:', error);
    throw error;
  }
}

/**
 * Create sample followers/following relationships
 */
async function createSampleRelationships(uid) {
  try {
    console.log('Creating sample follower/following relationships...');
    
    // Note: In a real scenario, you'd create actual user documents for these
    // For demo purposes, we're just creating the relationship documents
    
    const followers = [
      { uid: 'user1', username: 'alice_wonder', displayName: 'Alice Wonder' },
      { uid: 'user2', username: 'bob_builder', displayName: 'Bob Builder' },
      { uid: 'user3', username: 'charlie_brown', displayName: 'Charlie Brown' },
    ];
    
    const batch = firestore.batch();
    
    // Create follower relationships
    followers.forEach((follower) => {
      const followerRef = firestore
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(follower.uid);
      
      batch.set(followerRef, {
        uid: follower.uid,
        username: follower.username,
        displayName: follower.displayName,
        followedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
    
    await batch.commit();
    console.log(`✅ Created ${followers.length} sample follower relationships`);
  } catch (error) {
    console.error('❌ Error creating sample relationships:', error);
    throw error;
  }
}

/**
 * Main execution function
 */
async function main() {
  try {
    console.log('🚀 Starting demo account creation...\n');
    
    // Step 1: Create auth user
    const uid = await createDemoAuthUser();
    
    // Step 2: Create user document
    await createDemoUserDocument(uid);
    
    // Step 3: Create sample posts
    await createSamplePosts(uid);
    
    // Step 4: Create sample stories
    await createSampleStories(uid);
    
    // Step 5: Create sample relationships
    await createSampleRelationships(uid);
    
    console.log('\n✅ Demo account creation complete!');
    console.log('\n📋 Demo Account Credentials:');
    console.log(`   Email: ${DEMO_EMAIL}`);
    console.log(`   Password: ${DEMO_PASSWORD}`);
    console.log(`   UID: ${uid}`);
    console.log('\n🎉 Client can now log in and test all features!');
    
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Demo account creation failed:', error);
    process.exit(1);
  }
}

// Run the script
main();

