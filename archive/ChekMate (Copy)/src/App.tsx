import React, { useState, Suspense, lazy } from 'react';
import { Header } from './components/Header';
import { NavigationTabs } from './components/NavigationTabs';
import { Stories } from './components/Stories';
import { Post } from './components/Post';
import { Following } from './components/Following';
import { Explore } from './components/Explore';
import { Live } from './components/Live';
import { Subscribe } from './components/Subscribe';
import { PostCreationModal } from './components/PostCreationModal';
import { BottomNavigation } from './components/BottomNavigation';
// Lazy load heavy components
const RateYourDate = lazy(() => import('./components/RateYourDate').then(module => ({ default: module.RateYourDate })));
const Notifications = lazy(() => import('./components/Notifications').then(module => ({ default: module.Notifications })));
const UserProfile = lazy(() => import('./components/UserProfile').then(module => ({ default: module.UserProfile })));
const MyProfile = lazy(() => import('./components/MyProfile').then(module => ({ default: module.MyProfile })));
const MessagesPage = lazy(() => import('./components/MessagesPage').then(module => ({ default: module.MessagesPage })));
const LocationSelector = lazy(() => import('./components/LocationSelector').then(module => ({ default: module.LocationSelector })));
import { NavigationWidget } from './components/NavigationWidget';

const mockPosts = [
  {
    id: '1',
    username: 'Tbabee100',
    avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: 'How I found out my fiancé was getting married',
    image: 'https://images.unsplash.com/photo-1758874089739-da0739746ea4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb3VwbGUlMjByb21hbnRpYyUyMGRpbm5lcnxlbnwxfHx8fDE3NTk3NTQyODZ8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    caption: 'How I found out my fiancé was getting MARRIED',
    likes: 265000,
    comments: 8000,
    shares: 2562,
    timestamp: '2h ago'
  },
  {
    id: '2', 
    username: 'JessicaM',
    avatar: 'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2Zlc3Npb25hbCUyMGhlYWRzaG90fGVufDF8fHx8MTc1OTczMDU0M3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: 'Finally found someone who appreciates my weird sense of humor 😂 Date night was amazing!',
    likes: 1240,
    comments: 89,
    shares: 23,
    timestamp: '4h ago'
  },
  {
    id: '3',
    username: 'MikeD_Official',
    avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NTk3MTMyNTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: 'Pro tip: Cook together on the first date. You learn so much about someone by how they handle kitchen chaos 👨‍🍳',
    likes: 892,
    comments: 156,
    shares: 67,
    timestamp: '6h ago'
  },
  {
    id: '4',
    username: 'SarahJ_Stories',
    avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: 'When they remember your coffee order after one date ☕️ That\'s when you know they\'re paying attention to the little things',
    likes: 2100,
    comments: 234,
    shares: 89,
    timestamp: '8h ago'
  }
];

export default function App() {
  const [activeTab, setActiveTab] = useState('For you');
  const [bottomNavTab, setBottomNavTab] = useState('home');
  const [showNavigationWidget, setShowNavigationWidget] = useState(false);
  const [userAvatar, setUserAvatar] = useState('https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral');
  const [isShareModalOpen, setIsShareModalOpen] = useState(false);
  const [posts, setPosts] = useState(mockPosts);
  const [isInConversation, setIsInConversation] = useState(false);
  const [showPostCreationModal, setShowPostCreationModal] = useState(false);
  const [isViewingStories, setIsViewingStories] = useState(false);
  const [userProfile, setUserProfile] = useState({
    username: 'ChekMate_User',
    bio: 'Living my best life and looking for someone to share adventures with! 🌟 Love hiking, cooking, and spontaneous road trips.'
  });

  // Listen for home button reset event
  React.useEffect(() => {
    const handleResetToHomeFeed = () => {
      setActiveTab('For you');
    };

    window.addEventListener('resetToHomeFeed', handleResetToHomeFeed);
    return () => window.removeEventListener('resetToHomeFeed', handleResetToHomeFeed);
  }, []);

  const handleWidgetNavigation = (tab: string) => {
    setBottomNavTab(tab);
    if (tab === 'home') {
      setActiveTab('For you'); // Reset to default feed tab when going home
    }
  };

  const handleCreatePost = (content: string) => {
    const newPost = {
      id: Date.now().toString(),
      username: userProfile.username,
      avatar: userAvatar,
      content: content,
      likes: 0,
      comments: 0,
      shares: 0,
      timestamp: 'Just now'
    };
    setPosts([newPost, ...posts]);
  };

  const handleProfileUpdate = (username: string, bio: string) => {
    setUserProfile({ username, bio });
  };

  const renderContent = () => {
    // Handle bottom navigation
    if (bottomNavTab === 'notifications') {
      return (
        <Suspense fallback={<div className="min-h-screen bg-gray-50 flex items-center justify-center">Loading...</div>}>
          <Notifications bottomNavTab={bottomNavTab} onBottomNavChange={setBottomNavTab} />
        </Suspense>
      );
    }
    
    if (bottomNavTab === 'profile') {
      return (
        <Suspense fallback={<div className="min-h-screen bg-gray-50 flex items-center justify-center">Loading...</div>}>
          <MyProfile 
            bottomNavTab={bottomNavTab} 
            onBottomNavChange={setBottomNavTab}
            userAvatar={userAvatar}
            onAvatarChange={setUserAvatar}
            username={userProfile.username}
            bio={userProfile.bio}
            onProfileUpdate={handleProfileUpdate}
          />
        </Suspense>
      );
    }

    if (bottomNavTab === 'messages') {
      return (
        <Suspense fallback={<div className="min-h-screen bg-gray-50 flex items-center justify-center">Loading...</div>}>
          <MessagesPage 
            bottomNavTab={bottomNavTab} 
            onBottomNavChange={setBottomNavTab}
            onConversationOpen={() => setIsInConversation(true)}
            onConversationClose={() => setIsInConversation(false)}
            isInConversation={isInConversation}
          />
        </Suspense>
      );
    }
    
    // Handle top navigation tabs
    if (activeTab === 'Rate Date') {
      return (
        <>
          <NavigationWidget
            isOpen={showNavigationWidget}
            onClose={() => setShowNavigationWidget(false)}
            currentTab={bottomNavTab}
            onNavigate={handleWidgetNavigation}
          />
          <Suspense fallback={<div className="min-h-screen bg-gray-50 flex items-center justify-center">Loading...</div>}>
            <RateYourDate onShowWidget={() => setShowNavigationWidget(true)} />
          </Suspense>
        </>
      );
    }

    if (activeTab === 'Following') {
      return (
        <>
          <NavigationWidget
            isOpen={showNavigationWidget}
            onClose={() => setShowNavigationWidget(false)}
            currentTab={bottomNavTab}
            onNavigate={handleWidgetNavigation}
          />
          <PostCreationModal
            isOpen={showPostCreationModal}
            onClose={() => setShowPostCreationModal(false)}
            userAvatar={userAvatar}
            onCreatePost={handleCreatePost}
          />
          <div className="min-h-screen bg-gray-50">
            <Header />
            <NavigationTabs activeTab={activeTab} onTabChange={setActiveTab} />
            <Stories 
              onStoryOpen={() => setIsViewingStories(true)}
              onStoryClose={() => setIsViewingStories(false)}
            />
            
            <Following 
              onShareModalOpen={() => setIsShareModalOpen(true)}
              onShareModalClose={() => setIsShareModalOpen(false)}
            />
            
            <BottomNavigation 
              activeTab={bottomNavTab} 
              onTabChange={setBottomNavTab}
              hideNavigation={isInConversation || isViewingStories}
              onCreateClick={() => setShowPostCreationModal(true)}
            />
          </div>
        </>
      );
    }

    if (activeTab === 'Explore') {
      return (
        <>
          <NavigationWidget
            isOpen={showNavigationWidget}
            onClose={() => setShowNavigationWidget(false)}
            currentTab={bottomNavTab}
            onNavigate={handleWidgetNavigation}
          />
          <PostCreationModal
            isOpen={showPostCreationModal}
            onClose={() => setShowPostCreationModal(false)}
            userAvatar={userAvatar}
            onCreatePost={handleCreatePost}
          />
          <div className="min-h-screen bg-gray-50">
            <Header />
            <NavigationTabs activeTab={activeTab} onTabChange={setActiveTab} />
            
            <Explore 
              onShareModalOpen={() => setIsShareModalOpen(true)}
              onShareModalClose={() => setIsShareModalOpen(false)}
            />
            
            <BottomNavigation 
              activeTab={bottomNavTab} 
              onTabChange={setBottomNavTab}
              hideNavigation={isInConversation || isViewingStories}
              onCreateClick={() => setShowPostCreationModal(true)}
            />
          </div>
        </>
      );
    }

    if (activeTab === 'Live') {
      return (
        <>
          <NavigationWidget
            isOpen={showNavigationWidget}
            onClose={() => setShowNavigationWidget(false)}
            currentTab={bottomNavTab}
            onNavigate={handleWidgetNavigation}
          />
          <PostCreationModal
            isOpen={showPostCreationModal}
            onClose={() => setShowPostCreationModal(false)}
            userAvatar={userAvatar}
            onCreatePost={handleCreatePost}
          />
          <div className="min-h-screen bg-gray-50">
            <Header />
            <NavigationTabs activeTab={activeTab} onTabChange={setActiveTab} />
            
            <Live 
              userAvatar={userAvatar}
              onGoLive={() => console.log('Go live functionality')}
            />
            
            <BottomNavigation 
              activeTab={bottomNavTab} 
              onTabChange={setBottomNavTab}
              hideNavigation={isInConversation || isViewingStories}
              onCreateClick={() => setShowPostCreationModal(true)}
            />
          </div>
        </>
      );
    }

    if (activeTab === 'Subscribe') {
      return (
        <>
          <NavigationWidget
            isOpen={showNavigationWidget}
            onClose={() => setShowNavigationWidget(false)}
            currentTab={bottomNavTab}
            onNavigate={handleWidgetNavigation}
          />
          <PostCreationModal
            isOpen={showPostCreationModal}
            onClose={() => setShowPostCreationModal(false)}
            userAvatar={userAvatar}
            onCreatePost={handleCreatePost}
          />
          <div className="min-h-screen bg-gray-50">
            <Header />
            <NavigationTabs activeTab={activeTab} onTabChange={setActiveTab} />
            
            <Subscribe currentPlan="free" />
            
            <BottomNavigation 
              activeTab={bottomNavTab} 
              onTabChange={setBottomNavTab}
              hideNavigation={isInConversation || isViewingStories}
              onCreateClick={() => setShowPostCreationModal(true)}
            />
          </div>
        </>
      );
    }
    
    // Default feed view
    return (
      <>
        <NavigationWidget
          isOpen={showNavigationWidget}
          onClose={() => setShowNavigationWidget(false)}
          currentTab={bottomNavTab}
          onNavigate={handleWidgetNavigation}
        />
        <PostCreationModal
          isOpen={showPostCreationModal}
          onClose={() => setShowPostCreationModal(false)}
          userAvatar={userAvatar}
          onCreatePost={handleCreatePost}
        />
        <div className="min-h-screen bg-gray-50">
          <Header />
          <NavigationTabs activeTab={activeTab} onTabChange={setActiveTab} />
          <Stories 
            onStoryOpen={() => setIsViewingStories(true)}
            onStoryClose={() => setIsViewingStories(false)}
          />
          
          <div className="pb-16">
            {posts.map((post) => (
              <Post 
                key={post.id} 
                {...post} 
                onShareModalOpen={() => setIsShareModalOpen(true)}
                onShareModalClose={() => setIsShareModalOpen(false)}
              />
            ))}
          </div>
          
          <BottomNavigation 
            activeTab={bottomNavTab} 
            onTabChange={setBottomNavTab}
            hideNavigation={isInConversation || isViewingStories}
            onCreateClick={() => setShowPostCreationModal(true)}
          />
        </div>
      </>
    );
  };

  return renderContent();
}