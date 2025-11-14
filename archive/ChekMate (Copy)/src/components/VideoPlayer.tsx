import React, { useState, useRef, useEffect } from 'react';
import { X, Play, Pause, Volume2, VolumeX, RotateCcw, Share2, Heart, MessageCircle } from 'lucide-react';

interface VideoPlayerProps {
  isOpen: boolean;
  onClose: () => void;
  video: {
    id: string;
    thumbnail: string;
    title: string;
    views: string;
    isChecked?: boolean;
  };
  userName: string;
  userAvatar: string;
}

export function VideoPlayer({ isOpen, onClose, video, userName, userAvatar }: VideoPlayerProps) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [isLiked, setIsLiked] = useState(false);
  const [showControls, setShowControls] = useState(true);
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    if (isOpen && videoRef.current) {
      // Auto-play when modal opens
      videoRef.current.play();
      setIsPlaying(true);
    }
  }, [isOpen]);

  useEffect(() => {
    let timeout: NodeJS.Timeout;
    if (showControls && isPlaying) {
      timeout = setTimeout(() => setShowControls(false), 3000);
    }
    return () => clearTimeout(timeout);
  }, [showControls, isPlaying]);

  const togglePlay = () => {
    if (videoRef.current) {
      if (isPlaying) {
        videoRef.current.pause();
      } else {
        videoRef.current.play();
      }
      setIsPlaying(!isPlaying);
    }
  };

  const toggleMute = () => {
    if (videoRef.current) {
      videoRef.current.muted = !isMuted;
      setIsMuted(!isMuted);
    }
  };

  const handleTimeUpdate = () => {
    if (videoRef.current) {
      setCurrentTime(videoRef.current.currentTime);
    }
  };

  const handleLoadedMetadata = () => {
    if (videoRef.current) {
      setDuration(videoRef.current.duration);
    }
  };

  const formatTime = (time: number) => {
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  const handleVideoClick = () => {
    setShowControls(true);
    togglePlay();
  };

  const handleRestart = () => {
    if (videoRef.current) {
      videoRef.current.currentTime = 0;
      videoRef.current.play();
      setIsPlaying(true);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black z-50 flex flex-col">
      {/* Video container */}
      <div className="flex-1 relative">
        <video
          ref={videoRef}
          className="w-full h-full object-cover"
          onTimeUpdate={handleTimeUpdate}
          onLoadedMetadata={handleLoadedMetadata}
          onClick={handleVideoClick}
          poster={video.thumbnail}
          loop
        >
          {/* Using a sample video URL - in a real app this would come from your video data */}
          <source src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" type="video/mp4" />
        </video>

        {/* Controls overlay */}
        {showControls && (
          <div className="absolute inset-0 bg-black bg-opacity-20">
            {/* Top controls */}
            <div className="absolute top-4 left-4 right-4 flex justify-between items-center">
              <button onClick={onClose} className="p-2">
                <X size={24} className="text-white" />
              </button>
              
              <div className="flex space-x-3">
                <button onClick={handleRestart} className="p-2">
                  <RotateCcw size={20} className="text-white" />
                </button>
                <button onClick={toggleMute} className="p-2">
                  {isMuted ? <VolumeX size={20} className="text-white" /> : <Volume2 size={20} className="text-white" />}
                </button>
              </div>
            </div>

            {/* Center play button */}
            {!isPlaying && (
              <div className="absolute inset-0 flex items-center justify-center">
                <button onClick={togglePlay} className="p-4 bg-black bg-opacity-50 rounded-full">
                  <Play size={32} className="text-white fill-current" />
                </button>
              </div>
            )}

            {/* Bottom controls */}
            <div className="absolute bottom-4 left-4 right-4">
              {/* Progress bar */}
              <div className="mb-4">
                <div className="w-full bg-white bg-opacity-30 rounded-full h-1">
                  <div 
                    className="bg-white h-1 rounded-full transition-all duration-200"
                    style={{ width: `${duration ? (currentTime / duration) * 100 : 0}%` }}
                  />
                </div>
                <div className="flex justify-between mt-1">
                  <span className="text-white text-xs">{formatTime(currentTime)}</span>
                  <span className="text-white text-xs">{formatTime(duration)}</span>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Video info section */}
      <div className="bg-white p-4">
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-center space-x-3 flex-1">
            <img
              src={userAvatar}
              alt={userName}
              className="w-12 h-12 rounded-full object-cover"
            />
            <div className="flex-1">
              <h3 className="font-semibold text-gray-900">{userName}</h3>
              <p className="text-sm text-gray-600 mt-1 leading-tight">{video.title}</p>
            </div>
          </div>
          
          <div className="flex items-center space-x-4 ml-4">
            <button onClick={() => setIsLiked(!isLiked)} className="flex flex-col items-center">
              <Heart size={24} className={`${isLiked ? 'text-red-500 fill-current' : 'text-gray-600'}`} />
              <span className="text-xs text-gray-600 mt-1">Like</span>
            </button>
            
            <button className="flex flex-col items-center">
              <MessageCircle size={24} className="text-gray-600" />
              <span className="text-xs text-gray-600 mt-1">Comment</span>
            </button>
            
            <button className="flex flex-col items-center">
              <Share2 size={24} className="text-gray-600" />
              <span className="text-xs text-gray-600 mt-1">Share</span>
            </button>
          </div>
        </div>
        
        <div className="flex items-center justify-between text-sm text-gray-600">
          <span>{video.views} views</span>
          {video.isChecked && (
            <span className="bg-orange-400 text-white px-2 py-1 rounded-full text-xs font-medium">
              Cheked
            </span>
          )}
        </div>
      </div>
    </div>
  );
}