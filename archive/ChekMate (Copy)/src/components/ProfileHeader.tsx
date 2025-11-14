import React from 'react';
import { Bell, Share } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface ProfileHeaderProps {
  name: string;
  username: string;
  bio: string;
  avatar: string;
  isFollowing?: boolean;
  onFollowClick?: () => void;
  onMessageClick?: () => void;
}

export function ProfileHeader({ name, username, bio, avatar, isFollowing = false, onFollowClick, onMessageClick }: ProfileHeaderProps) {
  return (
    <div className="bg-white px-4 py-6">
      {/* Top icons */}
      <div className="flex justify-end space-x-4 mb-6">
        <button>
          <Bell size={24} className="text-gray-700" />
        </button>
        <button>
          <Share size={24} className="text-gray-700" />
        </button>
      </div>

      {/* Profile info and avatar */}
      <div className="flex items-start justify-between mb-6">
        <div className="flex-1">
          <h1 className="text-2xl font-bold text-gray-900 mb-1">{name}</h1>
          <p className="text-gray-600 text-base mb-4">{username}</p>
          <p className="text-gray-800 text-sm leading-relaxed">{bio}</p>
        </div>
        
        {/* Profile picture with gradient border */}
        <div className="ml-6">
          <div className="w-24 h-24 rounded-full p-1 bg-gradient-to-r from-yellow-400 to-orange-400">
            <ImageWithFallback
              src={avatar}
              alt={name}
              className="w-full h-full rounded-full object-cover bg-white p-1"
            />
          </div>
        </div>
      </div>

      {/* Action buttons */}
      <div className="flex space-x-3">
        <button 
          onClick={onFollowClick}
          className={`flex-1 py-2 px-4 rounded-lg font-medium transition-colors ${
            isFollowing 
              ? 'bg-gray-200 text-gray-800 hover:bg-gray-300' 
              : 'bg-orange-400 text-white hover:bg-orange-500'
          }`}
        >
          {isFollowing ? 'Following' : 'Follow'}
        </button>
        <button 
          onClick={onMessageClick}
          className="flex-1 py-2 px-4 rounded-lg font-medium bg-orange-400 text-white hover:bg-orange-500 transition-colors"
        >
          Message
        </button>
      </div>
    </div>
  );
}