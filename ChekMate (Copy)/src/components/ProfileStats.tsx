import React from 'react';

interface ProfileStatsProps {
  posts: number;
  followers: string;
  subscribers: string;
  likes: string;
}

export function ProfileStats({ posts, followers, subscribers, likes }: ProfileStatsProps) {
  return (
    <div className="bg-white px-4 py-4 border-b border-gray-200">
      <div className="flex justify-between items-center">
        <div className="text-center">
          <div className="text-2xl font-bold text-gray-900">{posts}</div>
          <div className="text-sm text-gray-600">Posts</div>
        </div>
        
        <div className="text-center">
          <div className="text-2xl font-bold text-gray-900">{followers}</div>
          <div className="text-sm text-gray-600">Followers</div>
        </div>
        
        <div className="text-center">
          <div className="text-2xl font-bold text-gray-900">{subscribers}</div>
          <div className="text-sm text-gray-600">Subscribers</div>
        </div>
        
        <div className="text-center">
          <div className="text-2xl font-bold text-gray-900">{likes}</div>
          <div className="text-sm text-gray-600">Likes</div>
        </div>
      </div>
    </div>
  );
}