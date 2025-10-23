import React, { useState, useEffect, useRef, useCallback, memo } from 'react';
import { X, ChevronLeft, ChevronRight, Heart, Send, MoreHorizontal, Volume2, VolumeX, Pause, Play } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface StoryContent {
  id: string;
  type: 'image' | 'video';
  url: string;
  duration: number;
  text?: string;
  textColor?: string;
  textPosition?: 'top' | 'center' | 'bottom';
  timestamp: string;
}

interface StoryUser {
  id: string;
  username: string;
  avatar: string;
  isFollowing: boolean;
  stories: StoryContent[];
}

interface StoryViewerProps {
  isOpen: boolean;
  onClose: () => void;
  stories: StoryUser[];
  currentUserId: string;
  currentUserFollowing: string[]; // List of user IDs the current user follows
}

const StoryViewer = memo(function StoryViewer({ 
  isOpen, 
  onClose, 
  stories, 
  currentUserId, 
  currentUserFollowing 
}: StoryViewerProps) {
  const [currentUserIndex, setCurrentUserIndex] = useState(0);
  const [currentStoryIndex, setCurrentStoryIndex] = useState(0);
  const [progress, setProgress] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [replyText, setReplyText] = useState('');
  const [showReplyBox, setShowReplyBox] = useState(false);
  const [viewedStories, setViewedStories] = useState<Set<string>>(new Set());
  
  const videoRef = useRef<HTMLVideoElement>(null);
  const progressInterval = useRef<NodeJS.Timeout>();
  const touchStartX = useRef(0);
  const touchStartY = useRef(0);

  // Filter stories to only show from users the current user follows
  const followingStories = stories.filter(storyUser => 
    currentUserFollowing.includes(storyUser.id) || storyUser.id === currentUserId
  );

  const currentUser = followingStories[currentUserIndex];
  const currentStory = currentUser?.stories[currentStoryIndex];

  const handleNextStory = useCallback(() => {
    if (!currentUser) return;
    
    if (currentStoryIndex < currentUser.stories.length - 1) {
      setCurrentStoryIndex(prev => prev + 1);
      setProgress(0);
    } else if (currentUserIndex < followingStories.length - 1) {
      setCurrentUserIndex(prev => prev + 1);
      setCurrentStoryIndex(0);
      setProgress(0);
    } else {
      onClose();
    }
  }, [currentStoryIndex, currentUserIndex, followingStories.length, currentUser, onClose]);

  const handlePrevStory = useCallback(() => {
    if (currentStoryIndex > 0) {
      setCurrentStoryIndex(prev => prev - 1);
      setProgress(0);
    } else if (currentUserIndex > 0) {
      setCurrentUserIndex(prev => prev - 1);
      const prevUser = followingStories[currentUserIndex - 1];
      setCurrentStoryIndex(prevUser.stories.length - 1);
      setProgress(0);
    }
  }, [currentStoryIndex, currentUserIndex, followingStories]);

  useEffect(() => {
    if (!isOpen || !currentStory || isPaused) {
      if (progressInterval.current) {
        clearInterval(progressInterval.current);
      }
      return;
    }

    const duration = currentStory.duration * 1000;
    const updateInterval = 100; // Reduced frequency to improve performance
    let startTime = Date.now();

    progressInterval.current = setInterval(() => {
      const elapsed = Date.now() - startTime;
      const newProgress = (elapsed / duration) * 100;
      
      if (newProgress >= 100) {
        clearInterval(progressInterval.current!);
        handleNextStory();
        return;
      }
      
      setProgress(newProgress);
    }, updateInterval);

    return () => {
      if (progressInterval.current) {
        clearInterval(progressInterval.current);
      }
    };
  }, [currentStory, isPaused, isOpen, handleNextStory]);

  useEffect(() => {
    if (currentStory) {
      setViewedStories(prev => new Set([...prev, currentStory.id]));
    }
  }, [currentStory]);

  useEffect(() => {
    // Handle keyboard navigation
    const handleKeyDown = (e: KeyboardEvent) => {
      if (!isOpen) return;
      
      switch (e.key) {
        case 'ArrowLeft':
          handlePrevStory();
          break;
        case 'ArrowRight':
          handleNextStory();
          break;
        case ' ':
          e.preventDefault();
          setIsPaused(!isPaused);
          break;
        case 'Escape':
          onClose();
          break;
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, isPaused, handleNextStory, handlePrevStory]);

  const handleTouchStart = (e: React.TouchEvent) => {
    touchStartX.current = e.touches[0].clientX;
    touchStartY.current = e.touches[0].clientY;
  };

  const handleTouchEnd = (e: React.TouchEvent) => {
    const touchEndX = e.changedTouches[0].clientX;
    const touchEndY = e.changedTouches[0].clientY;
    const deltaX = touchEndX - touchStartX.current;
    const deltaY = touchEndY - touchStartY.current;

    // Horizontal swipe detection
    if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 50) {
      if (deltaX > 0) {
        handlePrevStory();
      } else {
        handleNextStory();
      }
    }
    // Vertical swipe down to close
    else if (deltaY > 100) {
      onClose();
    }
  };

  const handleScreenTap = (e: React.MouseEvent) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const tapX = e.clientX - rect.left;
    const screenWidth = rect.width;

    if (tapX < screenWidth / 3) {
      handlePrevStory();
    } else if (tapX > (screenWidth * 2) / 3) {
      handleNextStory();
    } else {
      setIsPaused(!isPaused);
    }
  };

  const handleSendReply = () => {
    if (!replyText.trim()) return;
    
    // Here you would send the reply to the backend
    console.log(`Reply to ${currentUser.username}: ${replyText}`);
    setReplyText('');
    setShowReplyBox(false);
  };

  if (!isOpen || !currentUser || !currentStory) return null;

  return (
    <div className="fixed inset-0 bg-black z-50 flex items-center justify-center">
      {/* Story Content */}
      <div 
        className="relative w-full h-full max-w-sm mx-auto"
        onTouchStart={handleTouchStart}
        onTouchEnd={handleTouchEnd}
        onClick={handleScreenTap}
      >
        {/* Progress Bars */}
        <div className="absolute top-4 left-4 right-4 z-20 flex space-x-1">
          {currentUser.stories.map((_, index) => (
            <div
              key={index}
              className="flex-1 h-1 bg-white bg-opacity-30 rounded-full overflow-hidden"
            >
              <div
                className="h-full bg-white transition-all duration-100 ease-linear rounded-full"
                style={{
                  width: `${
                    index < currentStoryIndex
                      ? 100
                      : index === currentStoryIndex
                      ? progress
                      : 0
                  }%`
                }}
              />
            </div>
          ))}
        </div>

        {/* Header */}
        <div className="absolute top-8 left-4 right-4 z-20 flex items-center justify-between mt-6">
          <div className="flex items-center space-x-3">
            <ImageWithFallback
              src={currentUser.avatar}
              alt={currentUser.username}
              className="w-8 h-8 rounded-full object-cover border border-white"
            />
            <div>
              <p className="text-white text-sm font-medium">{currentUser.username}</p>
              <p className="text-white text-xs opacity-75">{currentStory.timestamp}</p>
            </div>
          </div>
          
          <div className="flex items-center space-x-3">
            {currentStory.type === 'video' && (
              <>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setIsPaused(!isPaused);
                  }}
                  className="text-white p-2 rounded-full bg-black bg-opacity-30"
                >
                  {isPaused ? <Play size={16} /> : <Pause size={16} />}
                </button>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setIsMuted(!isMuted);
                    if (videoRef.current) {
                      videoRef.current.muted = !isMuted;
                    }
                  }}
                  className="text-white p-2 rounded-full bg-black bg-opacity-30"
                >
                  {isMuted ? <VolumeX size={16} /> : <Volume2 size={16} />}
                </button>
              </>
            )}
            
            <button
              onClick={(e) => {
                e.stopPropagation();
                // Handle more options
              }}
              className="text-white p-2 rounded-full bg-black bg-opacity-30"
            >
              <MoreHorizontal size={16} />
            </button>
            
            <button
              onClick={(e) => {
                e.stopPropagation();
                onClose();
              }}
              className="text-white p-2 rounded-full bg-black bg-opacity-30"
            >
              <X size={16} />
            </button>
          </div>
        </div>

        {/* Story Content */}
        <div className="w-full h-full">
          {currentStory.type === 'image' ? (
            <ImageWithFallback
              src={currentStory.url}
              alt="Story content"
              className="w-full h-full object-cover"
            />
          ) : (
            <video
              ref={videoRef}
              src={currentStory.url}
              className="w-full h-full object-cover"
              autoPlay
              muted={isMuted}
              playsInline
              onEnded={handleNextStory}
              onPause={() => setIsPaused(true)}
              onPlay={() => setIsPaused(false)}
            />
          )}
          
          {/* Text Overlay */}
          {currentStory.text && (
            <div
              className={`absolute inset-x-4 z-10 ${
                currentStory.textPosition === 'top'
                  ? 'top-24'
                  : currentStory.textPosition === 'bottom'
                  ? 'bottom-24'
                  : 'top-1/2 transform -translate-y-1/2'
              }`}
            >
              <p
                className={`text-center text-lg font-semibold px-4 py-2 rounded-lg ${
                  currentStory.textColor === 'white' ? 'text-white' : 'text-black'
                }`}
                style={{
                  textShadow: currentStory.textColor === 'white' ? '2px 2px 4px rgba(0,0,0,0.5)' : '2px 2px 4px rgba(255,255,255,0.5)'
                }}
              >
                {currentStory.text}
              </p>
            </div>
          )}
        </div>

        {/* Navigation Hints */}
        <div className="absolute inset-y-0 left-0 w-1/3 z-10" />
        <div className="absolute inset-y-0 right-0 w-1/3 z-10" />

        {/* Bottom Actions */}
        <div className="absolute bottom-6 left-4 right-4 z-20">
          <div className="flex items-center space-x-3">
            <div className="flex-1 relative">
              <input
                type="text"
                placeholder={`Reply to ${currentUser.username}...`}
                value={replyText}
                onChange={(e) => setReplyText(e.target.value)}
                onFocus={() => setShowReplyBox(true)}
                onClick={(e) => e.stopPropagation()}
                className="w-full px-4 py-2 bg-black bg-opacity-30 border border-white border-opacity-30 rounded-full text-white placeholder-white placeholder-opacity-75 text-sm focus:outline-none focus:ring-2 focus:ring-white"
              />
            </div>
            
            <button
              onClick={(e) => {
                e.stopPropagation();
                // Handle like
              }}
              className="text-white p-2 rounded-full bg-black bg-opacity-30"
            >
              <Heart size={20} />
            </button>
            
            {replyText.trim() && (
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  handleSendReply();
                }}
                className="text-white p-2 rounded-full bg-orange-500"
              >
                <Send size={16} />
              </button>
            )}
          </div>
        </div>

        {/* Previous/Next User Navigation */}
        {currentUserIndex > 0 && (
          <button
            onClick={(e) => {
              e.stopPropagation();
              setCurrentUserIndex(prev => prev - 1);
              setCurrentStoryIndex(0);
              setProgress(0);
            }}
            className="absolute left-4 top-1/2 transform -translate-y-1/2 text-white p-3 rounded-full bg-black bg-opacity-50 z-20"
          >
            <ChevronLeft size={20} />
          </button>
        )}
        
        {currentUserIndex < followingStories.length - 1 && (
          <button
            onClick={(e) => {
              e.stopPropagation();
              setCurrentUserIndex(prev => prev + 1);
              setCurrentStoryIndex(0);
              setProgress(0);
            }}
            className="absolute right-4 top-1/2 transform -translate-y-1/2 text-white p-3 rounded-full bg-black bg-opacity-50 z-20"
          >
            <ChevronRight size={20} />
          </button>
        )}
      </div>

      {/* Story Reply Modal */}
      {showReplyBox && (
        <div className="absolute bottom-0 left-0 right-0 bg-white p-4 rounded-t-2xl">
          <div className="flex items-center space-x-3">
            <ImageWithFallback
              src={currentUser.avatar}
              alt={currentUser.username}
              className="w-8 h-8 rounded-full object-cover"
            />
            <div className="flex-1">
              <input
                type="text"
                placeholder={`Reply to ${currentUser.username}'s story...`}
                value={replyText}
                onChange={(e) => setReplyText(e.target.value)}
                className="w-full px-4 py-2 border border-gray-200 rounded-full text-gray-900 focus:outline-none focus:ring-2 focus:ring-orange-500"
                autoFocus
              />
            </div>
            <button
              onClick={handleSendReply}
              disabled={!replyText.trim()}
              className="px-6 py-2 bg-orange-500 text-white rounded-full font-medium disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Send
            </button>
          </div>
        </div>
      )}
    </div>
  );
});

export { StoryViewer };