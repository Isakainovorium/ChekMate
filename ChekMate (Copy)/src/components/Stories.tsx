import React, { useState, Suspense, lazy } from 'react';
import { ImageWithFallback } from './figma/ImageWithFallback';

// Lazy load the StoryViewer to improve initial load performance
const StoryViewer = lazy(() => import('./StoryViewer').then(module => ({ default: module.StoryViewer })));

// Mock data - Current user follows these users
const currentUserFollowing = ['2', '3', '4', '5', '6']; // Following user IDs

const storyUsers = [
  {
    id: '1',
    username: 'Your story',
    avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    isFollowing: true,
    stories: [
      {
        id: 's1-1',
        type: 'image',
        url: 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb3VwbGUlMjBoYXBweSUyMHBvcnRyYWl0fGVufDF8fHx8MTc1OTc1Nzk5N3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        duration: 5,
        text: 'Perfect date night! 💕',
        textColor: 'white',
        textPosition: 'bottom',
        timestamp: '2h ago'
      }
    ]
  },
  {
    id: '2',
    username: 'jessica_m',
    avatar: 'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2Zlc3Npb25hbCUyMGhlYWRzaG90fGVufDF8fHx8MTc1OTczMDU0M3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    isFollowing: true,
    stories: [
      {
        id: 's2-1',
        type: 'video',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        duration: 6,
        text: 'Coffee date vibes ☕',
        textColor: 'white',
        textPosition: 'top',
        timestamp: '4h ago'
      },
      {
        id: 's2-2',
        type: 'image',
        url: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb3VwbGUlMjBjb29raW5nJTIwdG9nZXRoZXJ8ZW58MXx8fHwxNzU5NzU4MDAxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        duration: 5,
        text: 'Cooking together = best date ever! 👨‍🍳👩‍🍳',
        textColor: 'white',
        textPosition: 'center',
        timestamp: '3h ago'
      }
    ]
  },
  {
    id: '3',
    username: 'miked_official',
    avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NTk3MTMyNTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    isFollowing: true,
    stories: [
      {
        id: 's3-1',
        type: 'image',
        url: 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHxyZXN0YXVyYW50JTIwZGF0ZSUyMGRpbm5lcnxlbnwxfHx8fDE3NTk3NTgwMDl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        duration: 4,
        text: 'First date nerves are real! 😅',
        textColor: 'white',
        textPosition: 'bottom',
        timestamp: '6h ago'
      }
    ]
  },
  {
    id: '4',
    username: 'sarah_stories',
    avatar: 'https://images.unsplash.com/photo-1639149888905-fb39731f2e6c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMGhhcHB5JTIwcG9ydHJhaXR8ZW58MXx8fHwxNzU5NzU0MzE0fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    isFollowing: true,
    stories: [
      {
        id: 's4-1',
        type: 'video',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        duration: 8,
        text: 'Beach sunset date 🌅',
        textColor: 'white',
        textPosition: 'top',
        timestamp: '8h ago'
      },
      {
        id: 's4-2',
        type: 'image',
        url: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHRhbGtpbmclMjBwcmVzZW50YXRpb258ZW58MXx8fHwxNzU5NzU3OTkzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        duration: 5,
        text: 'He remembered my favorite flowers 🌸',
        textColor: 'white',
        textPosition: 'center',
        timestamp: '7h ago'
      }
    ]
  },
  {
    id: '5',
    username: 'alex_adventures',
    avatar: 'https://images.unsplash.com/photo-1758639842438-718755aa57e4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMG1hbiUyMHBvcnRyYWl0JTIwcHJvZmVzc2lvbmFsJTIwaGVhZHNob3R8ZW58MXx8fHwxNzU5NzU1NDE5fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    isFollowing: true,
    stories: [
      {
        id: 's5-1',
        type: 'image',
        url: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaG9uZSUyMHRleHRpbmclMjBtZXNzYWdpbmd8ZW58MXx8fHwxNzU5NzU4MDA1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        duration: 6,
        text: 'When they text back immediately 😍',
        textColor: 'black',
        textPosition: 'bottom',
        timestamp: '5h ago'
      }
    ]
  },
  {
    id: '6',
    username: 'emma_dating',
    avatar: 'https://images.unsplash.com/photo-1639149888905-fb39731f2e6c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMGhhcHB5JTIwcG9ydHJhaXR8ZW58MXx8fHwxNzU5NzU0MzE0fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    isFollowing: false, // Not following - will be filtered out
    stories: [
      {
        id: 's6-1',
        type: 'image',
        url: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkYXRlJTIwbmlnaHR8ZW58MXx8fHwxNzU5NzU4MDA5fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        duration: 5,
        text: 'Date night outfit! ✨',
        textColor: 'white',
        textPosition: 'bottom',
        timestamp: '1h ago'
      }
    ]
  }
];

// Display stories for UI - shows preview info
const stories = storyUsers.map(user => ({
  id: user.id,
  username: user.username,
  avatar: user.avatar,
  hasStory: user.stories.length > 0,
  isOwn: user.id === '1',
  isViewed: false // You could track this in state
}));

interface StoriesProps {
  onStoryOpen?: () => void;
  onStoryClose?: () => void;
}

export function Stories({ onStoryOpen, onStoryClose }: StoriesProps) {
  const [showStoryViewer, setShowStoryViewer] = useState(false);
  const [selectedStoryUserId, setSelectedStoryUserId] = useState<string>('');

  const handleStoryClick = (storyId: string) => {
    // Find the index of the selected user in the storyUsers array
    const userIndex = storyUsers.findIndex(user => user.id === storyId);
    if (userIndex !== -1) {
      setSelectedStoryUserId(storyId);
      onStoryOpen?.(); // Notify parent first
      // Delay story viewer opening to improve performance
      setTimeout(() => {
        setShowStoryViewer(true);
      }, 50);
    }
  };

  const handleCloseViewer = () => {
    setShowStoryViewer(false);
    setSelectedStoryUserId('');
    onStoryClose?.(); // Notify parent that story viewer is closing
  };

  return (
    <>
      {showStoryViewer && (
        <Suspense fallback={
          <div className="fixed inset-0 bg-black z-50 flex items-center justify-center">
            <div className="text-white">Loading...</div>
          </div>
        }>
          <StoryViewer
            isOpen={showStoryViewer}
            onClose={handleCloseViewer}
            stories={storyUsers}
            currentUserId={selectedStoryUserId}
            currentUserFollowing={currentUserFollowing}
          />
        </Suspense>
      )}
      
      <div className="bg-white py-4">
        <div className="flex space-x-4 px-4 overflow-x-auto scrollbar-hide">
          {stories.map((story) => (
            <div key={story.id} className="flex-shrink-0 flex flex-col items-center">
              <div className={`w-16 h-16 rounded-full p-1 ${
                story.hasStory && !story.isViewed
                  ? 'bg-gradient-to-r from-orange-400 to-yellow-400'
                  : story.hasStory && story.isViewed
                  ? 'bg-gradient-to-r from-gray-300 to-gray-400'
                  : 'bg-gray-200'
              }`}>
                <ImageWithFallback
                  src={story.avatar}
                  alt={story.username}
                  className="w-full h-full rounded-full object-cover bg-white p-1 cursor-pointer"
                  onClick={() => handleStoryClick(story.id)}
                />
              </div>
              <span className="text-xs text-gray-600 mt-1 max-w-[64px] truncate">
                {story.isOwn ? 'Your story' : story.username}
              </span>
            </div>
          ))}
        </div>
      </div>
    </>
  );
}