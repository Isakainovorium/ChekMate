import React, { useState } from 'react';
import { Heart, MapPin } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface ProfileCardProps {
  id: string;
  name: string;
  avatar: string;
  gender: string;
  years: number;
  location: string;
}

export function ProfileCard({ name, avatar, gender, years, location }: ProfileCardProps) {
  const [isLiked, setIsLiked] = useState(false);

  return (
    <div className="bg-white rounded-lg overflow-hidden shadow-sm border border-gray-100">
      {/* Profile Image */}
      <div className="relative aspect-[3/4]">
        <ImageWithFallback
          src={avatar}
          alt={name}
          className="w-full h-full object-cover"
        />
        
        {/* Heart Button */}
        <button
          onClick={() => setIsLiked(!isLiked)}
          className={`absolute bottom-3 right-3 w-10 h-10 rounded-full flex items-center justify-center ${
            isLiked ? 'bg-red-500' : 'bg-purple-500'
          } shadow-lg`}
        >
          <Heart 
            size={20} 
            className={`text-white ${isLiked ? 'fill-current' : ''}`} 
          />
        </button>
      </div>
      
      {/* Profile Info */}
      <div className="p-3">
        <h3 className="font-semibold text-gray-900 mb-1">{name}</h3>
        <p className="text-sm text-gray-600 mb-2">{gender}, {years} years</p>
        
        <div className="flex items-center text-xs text-gray-500">
          <MapPin size={12} className="mr-1" />
          <span>{location}</span>
        </div>
      </div>
    </div>
  );
}