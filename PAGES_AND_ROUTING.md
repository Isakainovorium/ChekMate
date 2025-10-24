# ChekMate App - Pages & Routing Documentation
## Complete Navigation Structure and Feature Mapping

**Last Updated:** October 23, 2025  
**Router:** GoRouter (Declarative Routing)  
**Navigation Pattern:** Bottom Navigation + Modal Sheets

---

## 📱 Navigation Architecture

ChekMate uses **GoRouter** for declarative, type-safe routing with custom page transitions. The app features a **persistent bottom navigation bar** with 5 main sections, plus additional full-screen routes.

### **Bottom Navigation Structure**

```
┌─────────────────────────────────────┐
│  Home  │  Messages  │  +  │  🔔  │  Profile  │
│   (0)  │     (1)    │ (2) │ (3)  │    (4)    │
└─────────────────────────────────────┘
```

- **Index 0:** Home/Feed (with tabs)
- **Index 1:** Messages
- **Index 2:** Create Post (Modal)
- **Index 3:** Notifications
- **Index 4:** Profile

---

## 🗺️ Complete Route Map

### **1. Authentication Routes** 🔐

#### `/login` - Login Page
**Route Name:** `login`  
**Navigation:** Shows bottom nav: ❌  
**Transition:** Fade  

**Features:**
- Email/password login
- Google Sign-In button
- Apple Sign-In button
- "Forgot Password" link
- "Sign Up" navigation
- Form validation
- Error handling with snackbars

**Key Components:**
- Email input field
- Password input field (with show/hide toggle)
- Social login buttons
- Remember me checkbox

---

#### `/signup` - Sign Up Page
**Route Name:** `signup`  
**Navigation:** Shows bottom nav: ❌  
**Transition:** Fade  

**Features:**
- Email/password registration
- Google Sign-In integration
- Apple Sign-In integration
- Terms & conditions acceptance
- Password strength indicator
- Email validation
- Automatic login after signup

**Key Components:**
- Name input field
- Email input field
- Password input field
- Confirm password field
- Terms acceptance checkbox
- Social signup buttons

---

### **2. Onboarding Routes** 🎯

#### `/onboarding/welcome` - Welcome Screen
**Route Name:** `onboardingWelcome`  
**Transition:** Shared Axis  

**Features:**
- App introduction
- Brand messaging
- Animated logo
- "Get Started" CTA button
- Skip option

**Key Components:**
- Lottie animation
- Welcome message
- Feature highlights
- Navigation buttons

---

#### `/onboarding/interests` - Interests Selection
**Route Name:** `onboardingInterests`  
**Transition:** Shared Axis  

**Features:**
- 20+ interest categories
- Multi-select chips
- Search/filter interests
- Minimum selection requirement (3+)
- Progress indicator (Step 1/5)
- Back/Next navigation

**Interest Categories:**
- Sports, Music, Art, Travel, Food, Technology, Fashion, Gaming, Fitness, Reading, Movies, Photography, Dancing, Cooking, Nature, Pets, Business, Science, Politics, Health, etc.

**Key Components:**
- Interest chip grid
- Search bar
- Selected count indicator
- Progress bar

---

#### `/onboarding/location` - Location Setup
**Route Name:** `onboardingLocation`  
**Transition:** Shared Axis  

**Features:**
- Location permission request
- GPS coordinates capture
- Address display
- Privacy explanation
- Manual location entry option
- Progress indicator (Step 2/5)
- Skip option (with warning)

**Key Components:**
- Map preview
- Permission request dialog
- Location accuracy indicator
- Privacy notice

---

#### `/onboarding/profile-photo` - Profile Photo
**Route Name:** `onboardingProfilePhoto`  
**Transition:** Shared Axis  

**Features:**
- Camera integration
- Photo gallery access
- Photo cropping
- Preview before upload
- Skip option
- Progress indicator (Step 3/5)

**Key Components:**
- Camera preview
- Gallery picker
- Crop tool
- Upload progress indicator

---

#### `/onboarding/completion` - Completion Screen
**Route Name:** `onboardingCompletion`  
**Transition:** Shared Axis  

**Features:**
- Success animation
- Welcome message
- Profile summary
- "Start Exploring" CTA
- Confetti animation
- Auto-redirect to home (optional)

**Key Components:**
- Success Lottie animation
- Profile preview card
- Celebration effects
- Navigation button

---

### **3. Home/Feed Routes** 🏠

#### `/` - Home Page (Feed)
**Route Name:** `home`  
**Bottom Nav Index:** 0  
**Shows Bottom Nav:** ✅  
**Transition:** Default  

**Features:**
- **Header:**
  - ChekMate logo
  - Search icon
  - Notifications badge
  
- **Navigation Tabs:**
  - For You (Hybrid Feed)
  - Following (Following-only feed)
  - Explore (Discovery)
  - Live (Live streams)
  - Rate Date (Full-screen feature)
  
- **Stories Row:**
  - Horizontal scrolling stories
  - "Add Story" button
  - Story rings (viewed/unviewed)
  - Tap to view stories
  
- **Feed:**
  - Infinite scroll posts
  - Pull-to-refresh
  - Post types: text, photo, video, gallery
  - Like, comment, share buttons
  - User avatars (tap to view profile)
  - Location tags
  - Hashtags
  - Timestamp
  
- **Algorithm:**
  - Hybrid feed (60% location, 40% interests)
  - A/B testing variants
  - Engagement-based ranking
  - Recency boost

**Tab Details:**

##### **For You Tab**
- Personalized hybrid feed
- Location + interest-based
- Engagement-optimized
- Real-time updates

##### **Following Tab**
- Posts from followed users only
- Chronological order
- Real-time updates
- Empty state if no follows

##### **Explore Tab**
- Trending content
- Hashtag discovery
- Suggested users
- Category browsing
- Location-based discovery

##### **Live Tab**
- Active live streams
- "Go Live" button
- Viewer counts
- Stream thumbnails
- Search live content

##### **Rate Date Tab**
- Navigates to `/rate-date`
- Full-screen experience
- Hides bottom navigation

**Key Components:**
- `HeaderWidget` - App header with search
- `NavTabsWidget` - Horizontal tab navigation
- `StoriesWidget` - Stories carousel
- `PostWidget` - Individual post card
- Pull-to-refresh indicator
- Infinite scroll loader

---

#### `/explore` - Explore Page
**Route Name:** `explore`  
**Bottom Nav Index:** 0 (within Home)  
**Shows Bottom Nav:** ✅  
**Transition:** Fade Through  

**Features:**
- Trending content grid
- Hashtag discovery
- Suggested users carousel
- Category filters
- Search integration
- Location-based content
- Popular posts

**Key Components:**
- `ExploreGridWidget` - Masonry grid layout
- `TrendingContentWidget` - Trending section
- `SuggestedUsersWidget` - User recommendations
- `HashtagsWidget` - Trending hashtags
- Category filter chips

---

#### `/live` - Live Streams Page
**Route Name:** `live`  
**Bottom Nav Index:** 0 (within Home)  
**Shows Bottom Nav:** ✅  
**Transition:** Slide Up  

**Features:**
- Active live streams grid
- "Go Live" prominent button
- Viewer count display
- Stream thumbnails
- Search live streams
- Filter by category
- Real-time updates

**Key Components:**
- "Go Live" button
- Live stream cards
- Viewer count badges
- Category filters
- Search bar

---

### **4. Messages Routes** 💬

#### `/messages` - Messages List
**Route Name:** `messages`  
**Bottom Nav Index:** 1  
**Shows Bottom Nav:** ✅  
**Transition:** Slide Right  

**Features:**
- Conversation list
- Search conversations
- Unread message badges
- Last message preview
- Timestamp display
- User avatars
- Online status indicators
- Swipe actions (archive, delete)
- New message FAB

**Key Components:**
- Search bar
- Conversation list items
- Unread badges
- Online status dots
- Floating action button (new message)

---

#### `/chat/:conversationId` - Chat Page
**Route Name:** `chat`  
**Bottom Nav Index:** 1  
**Shows Bottom Nav:** ❌ (Hidden in conversation)  
**Transition:** Slide Up  
**Parameters:** 
- `conversationId` (path parameter)
- `userId` (query parameter)
- `userName` (query parameter)
- `userAvatar` (query parameter)

**Features:**
- **Message Types:**
  - Text messages
  - Photo messages
  - Video messages
  - Voice messages
  - Emoji reactions
  - GIFs
  
- **Real-time Features:**
  - Live message delivery
  - Read receipts
  - Typing indicators
  - Online status
  
- **Message Input:**
  - Text input field
  - Emoji picker button
  - Camera button
  - Gallery button
  - Voice record button
  - Send button
  
- **Voice Messages:**
  - Tap and hold to record
  - Waveform visualization
  - Recording timer
  - Cancel by sliding
  - Playback controls
  - Playback speed (1x, 1.5x, 2x)
  
- **Message Actions:**
  - Long press for options
  - Copy text
  - Delete message
  - React with emoji
  - Reply to message
  
- **Header:**
  - User avatar
  - User name
  - Online status
  - Back button
  - More options menu

**Key Components:**
- `MessageBubble` - Individual message
- `VoiceMessagePlayer` - Voice playback
- `VoiceRecordingButton` - Record voice
- `EmojiPicker` - Emoji selection
- `TypingIndicator` - Typing animation
- Message input bar

---

### **5. Notifications Routes** 🔔

#### `/notifications` - Notifications Page
**Route Name:** `notifications`  
**Bottom Nav Index:** 3  
**Shows Bottom Nav:** ✅  
**Transition:** Slide Right  

**Features:**
- Notification feed
- Notification types:
  - New followers
  - Post likes
  - Post comments
  - Message notifications
  - Story views
  - Live stream alerts
  - System announcements
  
- Notification actions:
  - Mark as read/unread
  - Clear all
  - Notification grouping
  - Tap to navigate to content
  
- Filter tabs:
  - All
  - Mentions
  - Likes
  - Follows
  
- Empty state:
  - "No notifications" illustration
  - Encouraging message

**Key Components:**
- `NotificationItemWidget` - Individual notification
- `NotificationsHeaderWidget` - Header with actions
- Filter tabs
- Empty state widget

---

### **6. Profile Routes** 👤

#### `/profile` - My Profile Page
**Route Name:** `profile`  
**Bottom Nav Index:** 4  
**Shows Bottom Nav:** ✅  
**Transition:** Shared Axis  

**Features:**
- **Profile Header:**
  - Cover photo
  - Profile photo
  - Edit profile button
  - Settings icon
  - Share profile button
  
- **Profile Info:**
  - Display name
  - Username (@handle)
  - Bio/description
  - Location
  - Join date
  - Website link
  
- **Stats:**
  - Posts count
  - Followers count
  - Following count
  - Likes received
  
- **Interest Badges:**
  - Selected interests display
  - Edit interests button
  
- **Voice Prompts:**
  - Voice introduction
  - Multiple voice prompts
  - Record new prompts
  - Playback controls
  
- **Content Tabs:**
  - Posts (grid view)
  - Videos (grid view)
  - Tagged (posts user is tagged in)
  - Likes (private)
  
- **Actions:**
  - Edit profile
  - Settings
  - Share profile
  - QR code

**Key Components:**
- `ProfileHeaderWidget` - Header section
- `VoicePromptPlayer` - Voice playback
- `VoicePromptRecorder` - Record voice
- Content grid
- Stats row
- Interest badges

---

#### `/profile/:userId` - User Profile Page
**Route Name:** `userProfile`  
**Shows Bottom Nav:** ✅  
**Transition:** Shared Axis  
**Parameters:** `userId` (path parameter)

**Features:**
- Similar to My Profile but for other users
- **Additional Actions:**
  - Follow/Unfollow button
  - Message button
  - Block user
  - Report user
  - Share profile
  
- **Relationship Indicators:**
  - "Follows you" badge
  - "Following" badge
  - Mutual friends count
  
- **Content Visibility:**
  - Respects privacy settings
  - Shows public posts only (if not following)

**Key Components:**
- Same as My Profile
- Follow button
- Message button
- Report/block options

---

#### `/profile/location-settings` - Location Settings
**Route Name:** `locationSettings`  
**Shows Bottom Nav:** ❌  
**Transition:** Slide Right  

**Features:**
- Enable/disable location
- Update current location
- Location accuracy settings
- Privacy controls
- Location history
- Clear location data

**Key Components:**
- Location toggle
- Map preview
- Privacy settings
- Location accuracy slider

---

#### `/profile/interests-management` - Interests Management
**Route Name:** `interestsManagement`  
**Shows Bottom Nav:** ❌  
**Transition:** Slide Right  

**Features:**
- View current interests
- Add new interests
- Remove interests
- Search interests
- Interest categories
- Save changes

**Key Components:**
- Interest chip grid
- Search bar
- Category filters
- Save button

---

### **7. Create Content Routes** ➕

#### `/create-post` - Create Post Page
**Route Name:** `create-post`  
**Shows Bottom Nav:** ❌ (Full screen)  
**Transition:** Slide Up  

**Features:**
- **Post Types:**
  - Text post
  - Photo post
  - Video post
  - Gallery post (multiple images)
  
- **Media Capture:**
  - Camera integration
  - Gallery picker
  - Video recording
  - Photo filters
  - Video editing
  
- **Post Options:**
  - Caption/text input
  - Hashtag suggestions
  - Location tagging
  - Interest/category tags
  - Privacy settings (public/friends/private)
  - Save as draft
  
- **Media Editing:**
  - Crop photos
  - Apply filters
  - Trim videos
  - Add text overlays
  - Add stickers
  
- **Preview:**
  - Post preview before publishing
  - Edit before posting

**Key Components:**
- `MediaTypeSelector` - Choose post type
- `CameraPage` - Camera interface
- `VideoEditorPage` - Video editing
- Text input field
- Hashtag suggestions
- Location picker
- Privacy selector
- Post button

---

#### Create Post Modal (Bottom Nav Index 2)
**Triggered by:** Tapping center "+" button in bottom nav  
**Type:** Modal Bottom Sheet  
**Shows Bottom Nav:** ❌ (Modal overlay)  

**Features:**
- Quick post creation
- Text input
- Media type selector (text/photo/video)
- Camera/gallery buttons
- Location button
- Post button
- Slide-up animation
- Drag handle to dismiss

**Key Components:**
- `PostCreationForm` - Form widget
- Media type buttons
- Quick action buttons
- Post button

---

### **8. Stories Routes** 📸

#### Story Viewer (Modal)
**Triggered by:** Tapping story in stories row  
**Type:** Full-screen Modal  
**Shows Bottom Nav:** ❌  

**Features:**
- Full-screen story display
- Tap left/right to navigate
- Tap and hold to pause
- Story progress bars
- User info header
- Story reactions
- Reply via DM
- Share story
- Report story
- Auto-advance to next story
- Swipe up for more options

**Key Components:**
- `StoryViewer` - Story display
- `VideoStoryPlayer` - Video playback
- Progress bars
- User header
- Reaction buttons

---

#### Create Story (Modal)
**Triggered by:** Tapping "Add Story" in stories row  
**Type:** Full-screen Modal  
**Shows Bottom Nav:** ❌  

**Features:**
- Camera integration
- Gallery picker
- Photo/video capture
- Text overlays
- Stickers
- Filters
- Drawing tools
- Privacy settings
- Post to story button

**Key Components:**
- Camera interface
- Editing tools
- Text overlay tool
- Sticker picker
- Filter selector
- Post button

---

### **9. Special Feature Routes** ⭐

#### `/rate-date` - Rate Your Date
**Route Name:** `rate-date`  
**Shows Bottom Nav:** ❌ (Full screen)  
**Transition:** Slide Up  

**Features:**
- Swipeable card interface
- User profiles to rate
- Star rating system (1-5 stars)
- Category ratings:
  - Appearance
  - Personality
  - Communication
  - Chemistry
  - Overall
  
- Swipe actions:
  - Swipe right: Good date
  - Swipe left: Bad date
  - Swipe up: Super like
  
- Anonymous ratings
- Rating history
- Match notifications
- Undo last swipe

**Key Components:**
- Swipeable cards
- Rating stars
- Category sliders
- Swipe animations
- Match notification

---

#### `/subscribe` - Subscription Page
**Route Name:** `subscribe`  
**Bottom Nav Index:** 0 (within Home)  
**Shows Bottom Nav:** ✅  
**Transition:** Shared Axis  

**Features:**
- Subscription tiers:
  - Free (current)
  - Premium
  - Premium Plus
  
- Premium features:
  - Unlimited likes
  - See who liked you
  - Advanced filters
  - No ads
  - Priority support
  - Verified badge
  - Boost profile
  
- Pricing display
- Feature comparison table
- Payment integration
- Subscription management
- Cancel subscription
- Restore purchases

**Key Components:**
- Pricing cards
- Feature comparison
- Subscribe buttons
- Payment sheet
- Subscription status

---

### **10. Search Routes** 🔍

#### `/search` - Search Page
**Route Name:** `search`  
**Shows Bottom Nav:** ✅  
**Transition:** Slide Right  
**Query Parameters:** `q` (search query)

**Features:**
- **Search Types:**
  - Users
  - Hashtags
  - Locations
  - Posts
  
- **Search Tabs:**
  - All
  - Users
  - Posts
  - Hashtags
  - Places
  
- **Recent Searches:**
  - Search history
  - Clear history
  - Tap to search again
  
- **Trending Searches:**
  - Popular searches
  - Trending hashtags
  - Trending topics
  
- **Search Results:**
  - User cards
  - Post previews
  - Hashtag cards
  - Location cards
  
- **Filters:**
  - Date range
  - Location radius
  - Content type

**Key Components:**
- `SearchPage` - Main search interface
- `SearchResultsWidget` - Results display
- `RecentSearchesWidget` - Search history
- `TrendingSearchesWidget` - Trending section
- Search bar
- Filter chips

---

### **11. Post Detail Routes** 📄

#### `/post/:postId` - Post Detail Page
**Route Name:** `post`  
**Shows Bottom Nav:** ❌ (Full screen)  
**Transition:** Slide Up  
**Parameters:** `postId` (path parameter)

**Features:**
- Full post display
- All media (photos/videos)
- Full caption
- All hashtags
- Location tag
- Timestamp
- Like/comment/share buttons
- Like count
- Comment count
- Share count

**Comments Section:**
- All comments
- Nested replies
- Like comments
- Reply to comments
- Delete own comments
- Report comments
- Sort comments (top/recent)
- Comment input field
- Emoji picker
- Mention users (@username)

**Key Components:**
- `PostDetailModal` - Full post view
- Comment list
- Comment input
- Like button
- Share button

---

### **12. Development/Testing Routes** 🛠️

#### `/theme-test` - Theme Test Page
**Route Name:** `theme-test`  
**Shows Bottom Nav:** ❌  
**Environment:** Development only  

**Features:**
- Component showcase
- Color palette display
- Typography samples
- Button variants
- Form elements
- Animation demos
- Theme switching
- Accessibility testing

**Key Components:**
- All UI components
- Theme previews
- Component examples

---

#### `/component-showcase` - Component Showcase
**Shows Bottom Nav:** ❌  
**Environment:** Development only  

**Features:**
- All custom components
- Interactive examples
- Code snippets
- Props documentation
- Widgetbook integration

---

## 🎨 Page Transition Types

ChekMate uses custom page transitions for a polished experience:

### **Fade Transition**
- **Used for:** Auth pages (login, signup)
- **Duration:** 300ms
- **Effect:** Smooth fade in/out

### **Slide Right Transition**
- **Used for:** Messages, Notifications, Settings
- **Duration:** 300ms
- **Effect:** Slides in from right edge

### **Slide Up Transition**
- **Used for:** Chat, Live, Rate Date, Create Post, Post Detail
- **Duration:** 350ms
- **Effect:** Slides up from bottom

### **Shared Axis Transition**
- **Used for:** Profile, Subscribe, Onboarding
- **Duration:** 400ms
- **Effect:** Fade + scale with axis movement

### **Fade Through Transition**
- **Used for:** Explore
- **Duration:** 300ms
- **Effect:** Fade out, then fade in

### **Default Transition**
- **Used for:** Home/Feed
- **Duration:** 250ms
- **Effect:** Platform default (Material/Cupertino)

---

## 🔄 Navigation Patterns

### **Bottom Navigation (Persistent)**
```dart
MainNavigation(
  currentIndex: 0-4,
  child: PageWidget(),
  hideNavigation: false, // Optional
)
```

**Indices:**
- 0: Home/Feed
- 1: Messages
- 2: Create (Modal)
- 3: Notifications
- 4: Profile

### **Modal Navigation**
- **Bottom Sheets:** Create post, Story options
- **Full-Screen Modals:** Story viewer, Post detail
- **Dialogs:** Confirmations, Alerts

### **Deep Linking**
Supports deep links for:
- User profiles: `chekmate://profile/:userId`
- Posts: `chekmate://post/:postId`
- Chat: `chekmate://chat/:conversationId`
- Hashtags: `chekmate://hashtag/:tag`

### **Navigation State Management**
```dart
// Hide bottom nav during specific interactions
navStateProvider.setInConversation(true);
navStateProvider.setViewingStories(true);
```

---

## 📊 Route Statistics

### **Total Routes:** 25+
- **Auth Routes:** 2
- **Onboarding Routes:** 5
- **Main App Routes:** 10+
- **Feature Routes:** 5+
- **Settings Routes:** 3+
- **Development Routes:** 2

### **Bottom Nav Pages:** 5
- Home (with 5 tabs)
- Messages
- Create (modal)
- Notifications
- Profile

### **Full-Screen Pages:** 8+
- Chat
- Story Viewer
- Post Detail
- Rate Date
- Create Post
- Camera
- Video Editor
- Live Stream

### **Modal Sheets:** 5+
- Create Post (quick)
- Story Options
- Share Sheet
- Comment Sheet
- User Options

---

## 🎯 Feature-to-Route Mapping

### **Authentication**
- Login → `/login`
- Signup → `/signup`
- Forgot Password → `/forgot-password` (future)

### **Onboarding**
- Welcome → `/onboarding/welcome`
- Interests → `/onboarding/interests`
- Location → `/onboarding/location`
- Photo → `/onboarding/profile-photo`
- Completion → `/onboarding/completion`

### **Feed & Discovery**
- Main Feed → `/` (Home)
- Explore → `/explore`
- Live Streams → `/live`
- Search → `/search`

### **Social Interactions**
- Messages List → `/messages`
- Chat → `/chat/:conversationId`
- Notifications → `/notifications`
- User Profile → `/profile/:userId`

### **Content Creation**
- Create Post → `/create-post`
- Create Story → Modal
- Go Live → `/live` (with "Go Live" button)

### **Profile Management**
- My Profile → `/profile`
- Edit Profile → `/profile/edit` (future)
- Location Settings → `/profile/location-settings`
- Interests → `/profile/interests-management`

### **Special Features**
- Rate Date → `/rate-date`
- Subscription → `/subscribe`

---

## 🚀 Navigation Best Practices

### **1. Use Named Routes**
```dart
context.goNamed('chat', 
  pathParameters: {'conversationId': id},
  queryParameters: {'userId': userId}
);
```

### **2. Handle Back Navigation**
```dart
// Pop modal
Navigator.of(context).pop();

// Go back in route stack
context.pop();

// Go to specific route
context.go('/home');
```

### **3. Pass Data Between Routes**
```dart
// Path parameters
context.go('/chat/$conversationId');

// Query parameters
context.go('/search?q=${Uri.encodeComponent(query)}');

// State parameters (via extra)
context.push('/profile', extra: userData);
```

### **4. Manage Bottom Nav State**
```dart
// Hide bottom nav
ref.read(navStateProvider.notifier).setInConversation(true);

// Show bottom nav
ref.read(navStateProvider.notifier).setInConversation(false);
```

### **5. Handle Deep Links**
```dart
// GoRouter automatically handles deep links
// Configure in app_router.dart
```

---

## 📝 Summary

ChekMate features a **sophisticated routing system** with:

✅ **25+ routes** covering all app features  
✅ **5 main navigation sections** via bottom nav  
✅ **Custom page transitions** for polished UX  
✅ **Modal navigation** for quick actions  
✅ **Deep linking support** for sharing  
✅ **Type-safe navigation** with GoRouter  
✅ **State-aware navigation** (hide/show bottom nav)  
✅ **Persistent navigation state** across routes  

The routing architecture is **scalable, maintainable, and user-friendly**, providing smooth navigation throughout the entire app experience.

---

*For technical implementation details, see `lib/core/router/app_router.dart` and `lib/core/router/app_router_enhanced.dart`*
