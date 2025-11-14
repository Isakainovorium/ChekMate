import React from 'react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface NotificationItemProps {
  id: string;
  userAvatar: string;
  userName: string;
  action: string;
  timestamp: string;
  postImage?: string;
}

export function NotificationItem({ 
  userAvatar, 
  userName, 
  action, 
  timestamp, 
  postImage 
}: NotificationItemProps) {
  return (
    <div className="flex items-center justify-between px-4 py-4 bg-white">
      {/* Left side with avatar and text */}
      <div className="flex items-start space-x-3 flex-1">
        {/* Bullet point */}
        <div className="w-2 h-2 bg-black rounded-full mt-2 flex-shrink-0"></div>
        
        {/* User avatar */}
        <ImageWithFallback
          src={userAvatar}
          alt={userName}
          className="w-12 h-12 rounded-full object-cover flex-shrink-0"
        />
        
        {/* Notification text */}
        <div className="flex-1 min-w-0">
          <div className="text-gray-900">
            <span className="font-semibold">{userName}</span>
          </div>
          <p className="text-gray-600 text-sm mt-1">{action}</p>
          <p className="text-gray-500 text-xs mt-1">{timestamp}</p>
        </div>
      </div>
      
      {/* Right side with post image */}
      {postImage && (
        <div className="ml-4 flex-shrink-0">
          <ImageWithFallback
            src={postImage}
            alt="Post preview"
            className="w-16 h-16 rounded-lg object-cover"
          />
        </div>
      )}
    </div>
  );
}