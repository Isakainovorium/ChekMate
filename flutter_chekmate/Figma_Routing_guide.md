# ChekMate App Routing Architecture Guide

**Version:** 1.0  
**Last Updated:** October 11, 2025  
**Purpose:** Comprehensive guide for AI systems to understand and modify the ChekMate dating app's navigation and routing system.

---

## Table of Contents

1. [Overview](#overview)
2. [Navigation Architecture](#navigation-architecture)
3. [State Management](#state-management)
4. [Routing Priority & Logic](#routing-priority--logic)
5. [Route Definitions](#route-definitions)
6. [UI Component Visibility Rules](#ui-component-visibility-rules)
7. [Navigation Methods](#navigation-methods)
8. [Special Navigation States](#special-navigation-states)
9. [Code Examples](#code-examples)
10. [Adding New Routes](#adding-new-routes)

---

## Overview

ChekMate uses a **state-based routing system** without a traditional router library (no React Router). Navigation is controlled through React state variables in the root `App.tsx` component. This architecture provides:

- **Two-layer navigation system**: Top tabs + Bottom navigation
- **Modal-based overlays**: Modals and full-screen overlays for certain features
- **Conditional UI rendering**: Components shown/hidden based on navigation state
- **Priority-based routing**: Bottom navigation overrides top navigation

**Key Principle:** The app renders different components based on state values rather than URL paths. There is NO URL routing.

---

## Navigation Architecture

### Two-Layer System

```
┌─────────────────────────────────────────┐
│          Header Component               │ ← Shown on most routes
├─────────────────────────────────────────┤
│   Top Navigation Tabs (NavigationTabs) │ ← For you, Following, Explore, Live, Subscribe
├─────────────────────────────────────────┤
│                                         │
│         Main Content Area               │ ← Changes based on navigation state
│                                         │
│                                         │
├─────────────────────────────────────────┤
│   Bottom Navigation (BottomNavigation)  │ ← Home, Messages, Notifications, Profile
└─────────────────────────────────────────┘
```

### Navigation Layers in Priority Order

1. **HIGHEST PRIORITY: Bottom Navigation** (`bottomNavTab` state)
   - Home → Shows feed with top navigation tabs
   - Messages → Full-screen MessagesPage component
   - Notifications → Full-screen Notifications component
   - Profile → Full-screen MyProfile component

2. **MEDIUM PRIORITY: Top Navigation Tabs** (`activeTab` state)
   - Only applies when `bottomNavTab === 'home'`
   - For you (default feed)
   - Following
   - Explore
   - Live
   - Subscribe
   - Rate Date (special case - no Header/NavigationTabs shown)

3. **OVERLAY PRIORITY: Modals & Special States**
   - PostCreationModal
   - StoryViewer (full-screen)
   - ShareModal
   - NavigationWidget
   - SettingsPage
   - ProfilePictureChanger
   - EditProfile

---

## State Management

### Core Navigation State Variables

Located in `App.tsx`:

```typescript
// BOTTOM NAVIGATION STATE (Primary routing control)
const [bottomNavTab, setBottomNavTab] = useState('home');
// Values: 'home' | 'messages' | 'notifications' | 'profile'

// TOP NAVIGATION STATE (Secondary routing control)
const [activeTab, setActiveTab] = useState('For you');
// Values: 'For you' | 'Following' | 'Explore' | 'Live' | 'Subscribe' | 'Rate Date'

// CONDITIONAL VISIBILITY STATE
const [isInConversation, setIsInConversation] = useState(false);
// Hides bottom navigation when in messaging conversation

const [isViewingStories, setIsViewingStories] = useState(false);
// Hides bottom navigation when viewing stories

// MODAL STATE
const [showPostCreationModal, setShowPostCreationModal] = useState(false);
const [showNavigationWidget, setShowNavigationWidget] = useState(false);
const [isShareModalOpen, setIsShareModalOpen] = useState(false);

// USER DATA STATE (affects profile pages)
const [userAvatar, setUserAvatar] = useState('...');
const [userProfile, setUserProfile] = useState({ username: '...', bio: '...' });
const [posts, setPosts] = useState(mockPosts);
```

### State Persistence

**IMPORTANT:** This app does NOT persist state across page refreshes. All state is in-memory only. When the app reloads, it returns to default state:
- `bottomNavTab = 'home'`
- `activeTab = 'For you'`
- All modals closed

---

## Routing Priority & Logic

### Decision Tree

The `renderContent()` function in App.tsx follows this exact decision tree:

```
START
  ↓
  Is bottomNavTab === 'notifications'?
    YES → Render <Notifications /> (STOP)
    NO ↓
  
  Is bottomNavTab === 'profile'?
    YES → Render <MyProfile /> (STOP)
    NO ↓
  
  Is bottomNavTab === 'messages'?
    YES → Render <MessagesPage /> (STOP)
    NO ↓
  
  Is activeTab === 'Rate Date'?
    YES → Render <RateYourDate /> (STOP)
    NO ↓
  
  Is activeTab === 'Following'?
    YES → Render Following feed with Header/NavigationTabs (STOP)
    NO ↓
  
  Is activeTab === 'Explore'?
    YES → Render Explore feed with Header/NavigationTabs (STOP)
    NO ↓
  
  Is activeTab === 'Live'?
    YES → Render Live feed with Header/NavigationTabs (STOP)
    NO ↓
  
  Is activeTab === 'Subscribe'?
    YES → Render Subscribe page with Header/NavigationTabs (STOP)
    NO ↓
  
  DEFAULT: Render "For you" feed with Header/NavigationTabs/Stories (STOP)
```

### Code Implementation

```typescript
const renderContent = () => {
  // LAYER 1: Bottom Navigation (Highest Priority)
  if (bottomNavTab === 'notifications') {
    return <Suspense><Notifications /></Suspense>;
  }
  if (bottomNavTab === 'profile') {
    return <Suspense><MyProfile /></Suspense>;
  }
  if (bottomNavTab === 'messages') {
    return <Suspense><MessagesPage /></Suspense>;
  }
  
  // LAYER 2: Top Navigation (Only when bottomNavTab === 'home')
  if (activeTab === 'Rate Date') {
    return <Suspense><RateYourDate /></Suspense>;
  }
  if (activeTab === 'Following') {
    return <div><Header /><NavigationTabs /><Following /></div>;
  }
  if (activeTab === 'Explore') {
    return <div><Header /><NavigationTabs /><Explore /></div>;
  }
  if (activeTab === 'Live') {
    return <div><Header /><NavigationTabs /><Live /></div>;
  }
  if (activeTab === 'Subscribe') {
    return <div><Header /><NavigationTabs /><Subscribe /></div>;
  }
  
  // DEFAULT: For you feed
  return <div><Header /><NavigationTabs /><Stories /><Posts /></div>;
};
```

---

## Route Definitions

### Bottom Navigation Routes

#### 1. Home (`bottomNavTab === 'home'`)

**State:** `setBottomNavTab('home')`

**Triggers:** 
- Clicking Home icon in BottomNavigation
- App initialization (default state)
- Home button reset event

**Renders:**
- Depends on `activeTab` state (see Top Navigation Routes)
- Shows Header component
- Shows NavigationTabs component
- Shows BottomNavigation component
- Shows Stories component (on For you and Following tabs)

**Components Shown:**
- ✅ Header
- ✅ NavigationTabs
- ✅ BottomNavigation
- ✅ Stories (conditional)
- ✅ NavigationWidget (when triggered)
- ✅ PostCreationModal (when triggered)

---

#### 2. Messages (`bottomNavTab === 'messages'`)

**State:** `setBottomNavTab('messages')`

**Triggers:**
- Clicking Messages icon in BottomNavigation
- NavigationWidget message button

**Renders:**
- `<MessagesPage />` (lazy-loaded)
- Custom header built into MessagesPage
- BottomNavigation (hidden when `isInConversation === true`)

**Props Passed:**
```typescript
<MessagesPage 
  bottomNavTab={bottomNavTab}
  onBottomNavChange={setBottomNavTab}
  onConversationOpen={() => setIsInConversation(true)}
  onConversationClose={() => setIsInConversation(false)}
  isInConversation={isInConversation}
/>
```

**Components Shown:**
- ❌ Header (has its own)
- ❌ NavigationTabs
- ✅ BottomNavigation (conditional - hidden in conversations)
- ❌ Stories

**Special Behavior:**
- When user enters a conversation, `isInConversation` becomes `true`
- This hides the BottomNavigation
- MessagesPage shows ConversationInputBar instead

---

#### 3. Notifications (`bottomNavTab === 'notifications'`)

**State:** `setBottomNavTab('notifications')`

**Triggers:**
- Clicking Notifications icon in BottomNavigation
- NavigationWidget notifications button

**Renders:**
- `<Notifications />` (lazy-loaded)
- Custom header built into Notifications (NotificationsHeader)
- BottomNavigation

**Props Passed:**
```typescript
<Notifications 
  bottomNavTab={bottomNavTab}
  onBottomNavChange={setBottomNavTab}
/>
```

**Components Shown:**
- ❌ Header (has its own NotificationsHeader)
- ❌ NavigationTabs
- ✅ BottomNavigation
- ❌ Stories

---

#### 4. Profile (`bottomNavTab === 'profile'`)

**State:** `setBottomNavTab('profile')`

**Triggers:**
- Clicking Profile icon in BottomNavigation
- NavigationWidget profile button

**Renders:**
- `<MyProfile />` (lazy-loaded)
- Custom header built into MyProfile (ProfileHeader)
- BottomNavigation

**Props Passed:**
```typescript
<MyProfile 
  bottomNavTab={bottomNavTab}
  onBottomNavChange={setBottomNavTab}
  userAvatar={userAvatar}
  onAvatarChange={setUserAvatar}
  username={userProfile.username}
  bio={userProfile.bio}
  onProfileUpdate={handleProfileUpdate}
/>
```

**Components Shown:**
- ❌ Header (has its own ProfileHeader)
- ❌ NavigationTabs
- ✅ BottomNavigation
- ❌ Stories

**Sub-Navigation within MyProfile:**
- Settings page (overlay)
- Profile picture changer (modal)
- Edit profile (modal)
- Share profile (modal)
- Video player (overlay)

---

### Top Navigation Routes

**IMPORTANT:** These routes only apply when `bottomNavTab === 'home'`

#### 1. For you (Default Feed) (`activeTab === 'For you'`)

**State:** `setActiveTab('For you')`

**Triggers:**
- App initialization (default)
- Clicking "For you" tab
- Home button reset event
- Clicking Home in BottomNavigation resets to this

**Renders:**
```tsx
<Header />
<NavigationTabs activeTab="For you" />
<Stories />
<div className="pb-16">
  {posts.map(post => <Post key={post.id} {...post} />)}
</div>
<BottomNavigation />
```

**Components Shown:**
- ✅ Header
- ✅ NavigationTabs
- ✅ Stories
- ✅ Post feed (from posts state array)
- ✅ BottomNavigation
- ✅ PostCreationModal (when triggered)
- ✅ NavigationWidget (when triggered)

**Data Source:** `posts` state variable (array of post objects)

---

#### 2. Following (`activeTab === 'Following'`)

**State:** `setActiveTab('Following')`

**Triggers:**
- Clicking "Following" tab in NavigationTabs

**Renders:**
```tsx
<Header />
<NavigationTabs activeTab="Following" />
<Stories />
<Following />
<BottomNavigation />
```

**Components Shown:**
- ✅ Header
- ✅ NavigationTabs
- ✅ Stories
- ✅ Following component (feed of followed users' posts)
- ✅ BottomNavigation

**Features:**
- Shows posts only from users you follow
- Has its own share modal logic

---

#### 3. Explore (`activeTab === 'Explore'`)

**State:** `setActiveTab('Explore')`

**Triggers:**
- Clicking "Explore" tab in NavigationTabs

**Renders:**
```tsx
<Header />
<NavigationTabs activeTab="Explore" />
<Explore />
<BottomNavigation />
```

**Components Shown:**
- ✅ Header
- ✅ NavigationTabs
- ❌ Stories (not shown on Explore)
- ✅ Explore component (discovery feed)
- ✅ BottomNavigation

**Features:**
- Discovery feed with trending/suggested content
- Profile cards and suggested matches
- Has its own share modal logic

---

#### 4. Live (`activeTab === 'Live'`)

**State:** `setActiveTab('Live')`

**Triggers:**
- Clicking "Live" tab in NavigationTabs

**Renders:**
```tsx
<Header />
<NavigationTabs activeTab="Live" />
<Live />
<BottomNavigation />
```

**Props Passed:**
```typescript
<Live 
  userAvatar={userAvatar}
  onGoLive={() => console.log('Go live functionality')}
/>
```

**Components Shown:**
- ✅ Header
- ✅ NavigationTabs
- ❌ Stories (not shown on Live)
- ✅ Live component (live streaming interface)
- ✅ BottomNavigation

**Features:**
- Shows active live streams
- "Go Live" button to start streaming
- Live video player integration

---

#### 5. Subscribe (`activeTab === 'Subscribe'`)

**State:** `setActiveTab('Subscribe')`

**Triggers:**
- Clicking "Subscribe" tab in NavigationTabs

**Renders:**
```tsx
<Header />
<NavigationTabs activeTab="Subscribe" />
<Subscribe currentPlan="free" />
<BottomNavigation />
```

**Components Shown:**
- ✅ Header
- ✅ NavigationTabs
- ❌ Stories
- ✅ Subscribe component (subscription tiers)
- ✅ BottomNavigation

**Features:**
- Premium subscription options
- Tier comparison
- Payment integration UI

---

#### 6. Rate Date (`activeTab === 'Rate Date'`)

**State:** `setActiveTab('Rate Date')`

**Triggers:**
- Clicking on a special navigation element (implementation varies)
- This tab is NOT in the NavigationTabs component but is a separate route

**Renders:**
```tsx
<NavigationWidget />
<RateYourDate onShowWidget={() => setShowNavigationWidget(true)} />
```

**Components Shown:**
- ❌ Header (Rate Date has its own header)
- ❌ NavigationTabs
- ❌ Stories
- ✅ RateYourDate component (flippable rating cards)
- ❌ BottomNavigation (Rate Date provides NavigationWidget instead)
- ✅ NavigationWidget (floating navigation)

**Special Behavior:**
- Full-screen experience
- Uses NavigationWidget for navigation instead of BottomNavigation
- Lazy-loaded for performance
- Features flippable 3D cards with Tea-style ratings

**Access Method:**
This appears to be a special route that's not directly accessible from the main navigation tabs. It needs to be triggered programmatically or from a specific entry point.

---

## UI Component Visibility Rules

### Header Component

**Shown when:**
- `bottomNavTab === 'home'` (any top navigation route except Rate Date)
- `activeTab !== 'Rate Date'`

**Hidden when:**
- `bottomNavTab === 'messages'` (MessagesPage has its own header)
- `bottomNavTab === 'notifications'` (has NotificationsHeader)
- `bottomNavTab === 'profile'` (has ProfileHeader)
- `activeTab === 'Rate Date'` (has RateYourDateHeader)

**Implementation:**
```tsx
{bottomNavTab === 'home' && activeTab !== 'Rate Date' && <Header />}
```

---

### NavigationTabs Component

**Shown when:**
- `bottomNavTab === 'home'`
- `activeTab !== 'Rate Date'`

**Hidden when:**
- `bottomNavTab !== 'home'` (other bottom nav sections)
- `activeTab === 'Rate Date'`

**Implementation:**
```tsx
{bottomNavTab === 'home' && activeTab !== 'Rate Date' && (
  <NavigationTabs activeTab={activeTab} onTabChange={setActiveTab} />
)}
```

**Available Tabs:**
- For you
- Following
- Explore
- Live
- Subscribe

---

### Stories Component

**Shown when:**
- `bottomNavTab === 'home'`
- `activeTab === 'For you'` OR `activeTab === 'Following'`

**Hidden when:**
- `bottomNavTab !== 'home'`
- `activeTab` is Explore, Live, Subscribe, or Rate Date

**Implementation:**
```tsx
{(activeTab === 'For you' || activeTab === 'Following') && (
  <Stories 
    onStoryOpen={() => setIsViewingStories(true)}
    onStoryClose={() => setIsViewingStories(false)}
  />
)}
```

**Features:**
- Instagram-style story viewer
- Video support
- Following relationships
- Sets `isViewingStories` state when opened
- Hides BottomNavigation when viewing

---

### BottomNavigation Component

**Shown when:**
- NOT `isInConversation`
- NOT `isViewingStories`
- NOT `activeTab === 'Rate Date'`

**Hidden when:**
- `isInConversation === true` (user in messaging conversation)
- `isViewingStories === true` (user viewing stories full-screen)
- `activeTab === 'Rate Date'` (uses NavigationWidget instead)

**Implementation:**
```tsx
<BottomNavigation 
  activeTab={bottomNavTab}
  onTabChange={setBottomNavTab}
  hideNavigation={isInConversation || isViewingStories}
  onCreateClick={() => setShowPostCreationModal(true)}
/>
```

**Tabs:**
- Home (icon: Home)
- Messages (icon: MessageCircle)
- Create Post (icon: Plus in orange circle)
- Notifications (icon: Bell)
- Profile (icon: User)

**Special Behavior:**
- Orange plus button in center for post creation
- Active tab highlighted with orange color
- Smooth transitions between tabs

---

### NavigationWidget Component

**Shown when:**
- `showNavigationWidget === true`
- Typically on Rate Date page or when user requests quick navigation

**Implementation:**
```tsx
<NavigationWidget
  isOpen={showNavigationWidget}
  onClose={() => setShowNavigationWidget(false)}
  currentTab={bottomNavTab}
  onNavigate={handleWidgetNavigation}
/>
```

**Features:**
- Floating overlay navigation
- Quick access to all bottom nav sections
- Can be triggered from components that hide BottomNavigation
- Provides visual feedback for current location

---

### PostCreationModal Component

**Shown when:**
- `showPostCreationModal === true`

**Triggers:**
- Clicking orange plus button in BottomNavigation
- Any component can trigger via state update

**Implementation:**
```tsx
<PostCreationModal
  isOpen={showPostCreationModal}
  onClose={() => setShowPostCreationModal(false)}
  userAvatar={userAvatar}
  onCreatePost={handleCreatePost}
/>
```

**Features:**
- Full-screen modal overlay
- Text input for post content
- Image/video upload capability
- Creates new post in feed
- Updates posts state array

---

## Navigation Methods

### Changing Bottom Navigation

```typescript
// From within App.tsx
setBottomNavTab('messages');  // Go to messages
setBottomNavTab('home');      // Return to home feed
setBottomNavTab('notifications'); // Go to notifications
setBottomNavTab('profile');   // Go to profile

// From child components (passed as prop)
// Example in BottomNavigation component:
<button onClick={() => onTabChange('messages')}>Messages</button>
```

### Changing Top Navigation

```typescript
// From within App.tsx
setActiveTab('Following');  // Switch to Following feed
setActiveTab('For you');    // Return to default feed
setActiveTab('Explore');    // Go to Explore
setActiveTab('Live');       // Go to Live
setActiveTab('Subscribe');  // Go to Subscribe

// From NavigationTabs component (passed as prop):
<button onClick={() => onTabChange('Following')}>Following</button>
```

### Home Button Reset Event

**Special Event:** Custom event for resetting to home feed

```typescript
// Triggering the event (from BottomNavigation or any component):
if (activeTab === 'home') {
  window.dispatchEvent(new Event('resetToHomeFeed'));
}

// Listening for the event (in App.tsx):
useEffect(() => {
  const handleResetToHomeFeed = () => {
    setActiveTab('For you');
  };
  
  window.addEventListener('resetToHomeFeed', handleResetToHomeFeed);
  return () => window.removeEventListener('resetToHomeFeed', handleResetToHomeFeed);
}, []);
```

**Purpose:** When user taps Home button while already on home, it resets to "For you" tab and scrolls to top.

### NavigationWidget Navigation Handler

```typescript
const handleWidgetNavigation = (tab: string) => {
  setBottomNavTab(tab);
  if (tab === 'home') {
    setActiveTab('For you'); // Reset to default feed when going home
  }
};
```

**Purpose:** Ensures consistent navigation from widget, always resets to For you feed when selecting home.

---

## Special Navigation States

### Conversation State (`isInConversation`)

**Purpose:** Hides BottomNavigation when user is in a messaging conversation

**Managed by:** MessagesPage component

**State Flow:**
```
User clicks on conversation
  ↓
MessagesPage calls onConversationOpen()
  ↓
App.tsx: setIsInConversation(true)
  ↓
BottomNavigation receives hideNavigation={true}
  ↓
BottomNavigation hidden

User exits conversation
  ↓
MessagesPage calls onConversationClose()
  ↓
App.tsx: setIsInConversation(false)
  ↓
BottomNavigation shown again
```

**Implementation in MessagesPage:**
```typescript
// When entering conversation:
props.onConversationOpen();

// When exiting conversation:
props.onConversationClose();
```

---

### Story Viewing State (`isViewingStories`)

**Purpose:** Hides BottomNavigation when user views stories full-screen

**Managed by:** Stories component

**State Flow:**
```
User clicks story
  ↓
Stories calls onStoryOpen()
  ↓
App.tsx: setIsViewingStories(true)
  ↓
StoryViewer component shown
  ↓
BottomNavigation hidden

User closes story
  ↓
Stories calls onStoryClose()
  ↓
App.tsx: setIsViewingStories(false)
  ↓
BottomNavigation shown again
```

**Implementation in Stories:**
```typescript
<Stories
  onStoryOpen={() => setIsViewingStories(true)}
  onStoryClose={() => setIsViewingStories(false)}
/>
```

---

### Modal States

**Modal Hierarchy:** Modals overlay on top of current route without changing navigation state

**Active Modals:**

1. **PostCreationModal** (`showPostCreationModal`)
   - Triggered by: Orange plus button in BottomNavigation
   - Closes: After posting or cancel
   - Blocks interaction with underlying page

2. **ShareModal** (`isShareModalOpen`)
   - Triggered by: Share button on posts
   - Managed by: Individual Post components
   - Multiple share modals can exist for different posts

3. **ShareProfile** (managed in MyProfile component)
   - Triggered by: Share button in profile header
   - Full-screen modal with sharing options
   - QR code, social media, link copying

4. **EditProfile** (managed in MyProfile component)
   - Triggered by: Edit Profile button
   - Updates username and bio
   - Saves to userProfile state

5. **ProfilePictureChanger** (managed in MyProfile component)
   - Triggered by: Clicking profile picture
   - Uploads or changes avatar
   - Updates userAvatar state

6. **SettingsPage** (managed in MyProfile component)
   - Triggered by: Settings button in profile
   - Full-screen overlay
   - Account preferences and settings

7. **VideoPlayer** (managed in MyProfile component)
   - Triggered by: Clicking video card
   - Full-screen video playback
   - Has its own close button

8. **StoryViewer** (managed in Stories component)
   - Triggered by: Clicking story avatar
   - Full-screen story viewing
   - Swipe navigation between stories
   - Sets `isViewingStories` state

**Modal Rendering Pattern:**
```tsx
{showModal && (
  <Modal isOpen={showModal} onClose={() => setShowModal(false)}>
    {/* Modal content */}
  </Modal>
)}
```

---

## Code Examples

### Example 1: Navigate to Messages from Any Page

```typescript
// In any component that receives onBottomNavChange prop:
<button onClick={() => props.onBottomNavChange('messages')}>
  Go to Messages
</button>

// Or using NavigationWidget:
<NavigationWidget
  isOpen={true}
  onNavigate={(tab) => setBottomNavTab(tab)}
/>
// User clicks Messages icon → navigates to messages
```

### Example 2: Switch Between Feed Tabs

```typescript
// In NavigationTabs component:
<button 
  onClick={() => onTabChange('Following')}
  className={activeTab === 'Following' ? 'border-b-2 border-orange-500' : ''}
>
  Following
</button>
```

### Example 3: Open Post Creation Modal

```typescript
// In BottomNavigation component:
<button onClick={() => props.onCreateClick()}>
  <Plus className="text-white" />
</button>

// In App.tsx:
<BottomNavigation 
  onCreateClick={() => setShowPostCreationModal(true)}
/>

<PostCreationModal
  isOpen={showPostCreationModal}
  onClose={() => setShowPostCreationModal(false)}
/>
```

### Example 4: Conditional Rendering Based on Route

```typescript
// In App.tsx renderContent():
const renderContent = () => {
  // Check bottom nav first (highest priority)
  if (bottomNavTab === 'profile') {
    return <MyProfile />;
  }
  
  // Then check top nav (only when on home)
  if (activeTab === 'Live') {
    return (
      <div>
        <Header />
        <NavigationTabs />
        <Live />
        <BottomNavigation />
      </div>
    );
  }
  
  // Default
  return <DefaultFeed />;
};
```

### Example 5: Hide Bottom Nav in Conversation

```typescript
// In MessagesPage component:
const openConversation = (conversationId) => {
  setActiveConversation(conversationId);
  props.onConversationOpen(); // Tells App.tsx to hide bottom nav
};

const closeConversation = () => {
  setActiveConversation(null);
  props.onConversationClose(); // Tells App.tsx to show bottom nav
};

// In App.tsx:
<MessagesPage
  onConversationOpen={() => setIsInConversation(true)}
  onConversationClose={() => setIsInConversation(false)}
/>

<BottomNavigation
  hideNavigation={isInConversation || isViewingStories}
/>
```

---

## Adding New Routes

### Adding a New Bottom Navigation Tab

1. **Update State Type (if using TypeScript):**
```typescript
type BottomNavTab = 'home' | 'messages' | 'notifications' | 'profile' | 'newTab';
```

2. **Add Route Logic in renderContent():**
```typescript
const renderContent = () => {
  // Add before other checks
  if (bottomNavTab === 'newTab') {
    return (
      <Suspense fallback={<div>Loading...</div>}>
        <NewTabComponent 
          bottomNavTab={bottomNavTab}
          onBottomNavChange={setBottomNavTab}
        />
      </Suspense>
    );
  }
  
  // ... rest of routing logic
};
```

3. **Add Icon to BottomNavigation Component:**
```typescript
// In BottomNavigation.tsx:
<button onClick={() => onTabChange('newTab')}>
  <NewIcon className={activeTab === 'newTab' ? 'text-orange-500' : 'text-gray-600'} />
</button>
```

4. **Create Component File:**
```typescript
// components/NewTabComponent.tsx
export function NewTabComponent({ bottomNavTab, onBottomNavChange }) {
  return (
    <div className="min-h-screen">
      <div className="p-4">New Tab Content</div>
      <BottomNavigation 
        activeTab={bottomNavTab}
        onTabChange={onBottomNavChange}
      />
    </div>
  );
}
```

---

### Adding a New Top Navigation Tab

1. **Update NavigationTabs Component:**
```typescript
// In NavigationTabs.tsx:
const tabs = [
  'For you',
  'Following',
  'Explore',
  'Live',
  'Subscribe',
  'New Tab' // Add here
];

<button onClick={() => onTabChange('New Tab')}>
  New Tab
</button>
```

2. **Add Route Logic in renderContent():**
```typescript
const renderContent = () => {
  // ... bottom nav checks first
  
  // Add new top nav route
  if (activeTab === 'New Tab') {
    return (
      <div className="min-h-screen bg-gray-50">
        <Header />
        <NavigationTabs activeTab={activeTab} onTabChange={setActiveTab} />
        <NewTabContent />
        <BottomNavigation 
          activeTab={bottomNavTab}
          onTabChange={setBottomNavTab}
        />
      </div>
    );
  }
  
  // ... rest of routing
};
```

3. **Create Component:**
```typescript
// components/NewTabContent.tsx
export function NewTabContent() {
  return <div className="p-4">New tab content here</div>;
}
```

---

### Adding a New Modal/Overlay

1. **Add State in App.tsx:**
```typescript
const [showNewModal, setShowNewModal] = useState(false);
```

2. **Create Modal Component:**
```typescript
// components/NewModal.tsx
export function NewModal({ isOpen, onClose }) {
  if (!isOpen) return null;
  
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50">
      <div className="bg-white rounded-lg p-6">
        <button onClick={onClose}>Close</button>
        {/* Modal content */}
      </div>
    </div>
  );
}
```

3. **Add to App.tsx Render:**
```typescript
return (
  <>
    <NewModal 
      isOpen={showNewModal}
      onClose={() => setShowNewModal(false)}
    />
    {renderContent()}
  </>
);
```

4. **Trigger from Components:**
```typescript
// Pass down as prop or use context
<SomeComponent onOpenModal={() => setShowNewModal(true)} />
```

---

## Important Notes for AI Systems

### Critical Rules

1. **NO URL ROUTING**: This app does not use URL-based routing. Do NOT implement React Router or similar libraries.

2. **State is King**: All navigation is controlled by React state. To navigate, change state variables.

3. **Priority Order**: Always check `bottomNavTab` BEFORE `activeTab`. Bottom navigation overrides top navigation.

4. **Lazy Loading**: Use `Suspense` and `lazy()` for heavy components (RateYourDate, Notifications, UserProfile, MyProfile, MessagesPage, LocationSelector).

5. **Prop Drilling**: Navigation callbacks are passed down through props. Components need `onBottomNavChange`, `bottomNavTab`, etc.

6. **Conditional Rendering**: Use `&&` and ternary operators for conditional component rendering, NOT routes.

7. **Component Structure**: Each "page" component should:
   - Receive `bottomNavTab` and `onBottomNavChange` props
   - Render its own header (or use shared Header)
   - Render BottomNavigation at bottom
   - Handle its own modals/overlays

8. **Modal Pattern**: Modals should:
   - Check `isOpen` prop to return null if closed
   - Call `onClose` callback to hide
   - Use fixed positioning with z-index
   - Block interaction with underlying content

9. **Navigation Consistency**: When adding navigation:
   - Always provide a way back
   - Update active states correctly
   - Handle edge cases (e.g., already on the same tab)
   - Reset to defaults when appropriate

10. **Performance**: Wrap heavy components in `Suspense` with fallback UI.

### State Flow Diagram

```
User Action (click, tap)
        ↓
Event Handler (onClick)
        ↓
State Update (setState)
        ↓
Re-render (React)
        ↓
renderContent() evaluates new state
        ↓
Returns appropriate JSX
        ↓
New component/page shown
```

### Common Mistakes to Avoid

❌ **Don't** create URL routes with React Router  
✅ **Do** use state-based conditional rendering

❌ **Don't** check `activeTab` before `bottomNavTab`  
✅ **Do** follow the priority order: bottom → top → default

❌ **Don't** import heavy components eagerly  
✅ **Do** use lazy loading with Suspense

❌ **Don't** create navigation without considering existing patterns  
✅ **Do** follow established patterns for consistency

❌ **Don't** forget to pass navigation props to child components  
✅ **Do** ensure all "page" components receive necessary props

❌ **Don't** hide navigation without providing alternatives  
✅ **Do** provide NavigationWidget or other navigation when hiding BottomNavigation

---

## Summary

The ChekMate app uses a **dual-layer state-based navigation system**:

- **Bottom Navigation** (4 tabs): Home, Messages, Notifications, Profile
- **Top Navigation** (5+ tabs): For you, Following, Explore, Live, Subscribe, Rate Date
- **Modals & Overlays**: PostCreation, ShareProfile, StoryViewer, Settings, etc.

Navigation is controlled entirely through React state (`bottomNavTab`, `activeTab`) without URL routing. The `renderContent()` function in `App.tsx` acts as the router, checking state values in priority order and rendering the appropriate component.

Key principles:
1. Bottom navigation has priority over top navigation
2. Modals overlay without changing navigation state
3. Some states (`isInConversation`, `isViewingStories`) conditionally hide UI elements
4. Components are lazy-loaded for performance
5. All navigation is prop-based, with callbacks passed down the tree

This architecture provides flexibility, performance, and a smooth user experience while keeping the codebase maintainable and understandable.

---

**End of Routing Guide**
