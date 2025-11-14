import React from 'react';
import { Play } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface VideoCardProps {
  id: string;
  thumbnail: string;
  title: string;
  views: string;
  isChecked?: boolean;
  onClick?: () => void;
}

export function VideoCard({ thumbnail, title, views, isChecked = false, onClick }: VideoCardProps) {
  return (
    <div 
      className="relative bg-black rounded-lg overflow-hidden aspect-[9/16] cursor-pointer transform transition-transform hover:scale-105"
      onClick={onClick}
    >
      {/* Video thumbnail */}
      <ImageWithFallback
        src={thumbnail}
        alt={title}
        className="w-full h-full object-cover"
      />
      
      {/* Dark overlay */}
      <div className="absolute inset-0 bg-black bg-opacity-20" />
      
      {/* Cheked badge */}
      {isChecked && (
        <div className="absolute top-3 left-3 bg-orange-400 text-white px-2 py-1 rounded-full text-xs font-medium">
          Cheked
        </div>
      )}
      
      {/* Content overlay */}
      <div className="absolute bottom-0 left-0 right-0 p-3">
        <h3 className="text-white font-medium text-sm mb-2 leading-tight">{title}</h3>
        
        {/* Views count with play icon */}
        <div className="flex items-center space-x-1">
          <Play size={12} className="text-white fill-current" />
          <span className="text-white text-xs font-medium">{views}</span>
        </div>
      </div>
    </div>
  );
}