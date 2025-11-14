import React, { useState, memo, useCallback } from 'react';
import { Star, Heart, X, ThumbsUp, ThumbsDown, Zap, MapPin, Calendar } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface FlippableProfileCardProps {
  id: string;
  name: string;
  avatar: string;
  gender: string;
  years: number;
  location: string;
  dateStory: string;
  dateLocation: string;
  dateActivity: string;
  dateRating?: number;
  totalRatings?: number;
  wowCount?: number;
  gtfohCount?: number;
  chekmateCount?: number;
  userRating?: 'wow' | 'gtfoh' | 'chekmate' | null;
  onRate: (profileId: string, rating: 'wow' | 'gtfoh' | 'chekmate') => void;
}

const FlippableProfileCard = memo(function FlippableProfileCard({
  id,
  name,
  avatar,
  gender,
  years,
  location,
  dateStory,
  dateLocation,
  dateActivity,
  dateRating = 0,
  totalRatings = 0,
  wowCount = 0,
  gtfohCount = 0,
  chekmateCount = 0,
  userRating = null,
  onRate
}: FlippableProfileCardProps) {
  const [isFlipped, setIsFlipped] = useState(false);
  const [hasRated, setHasRated] = useState(userRating !== null);
  const [selectedRating, setSelectedRating] = useState<'wow' | 'gtfoh' | 'chekmate' | null>(userRating);

  const handleFlip = useCallback(() => {
    setIsFlipped(!isFlipped);
  }, [isFlipped]);

  const handleRate = useCallback((rating: 'wow' | 'gtfoh' | 'chekmate') => {
    if (hasRated) return; // Prevent multiple ratings
    
    setSelectedRating(rating);
    setHasRated(true);
    onRate(id, rating);
  }, [hasRated, id, onRate]);

  const getRatingPercentage = (count: number) => {
    return totalRatings > 0 ? Math.round((count / totalRatings) * 100) : 0;
  };

  return (
    <div className="relative w-full h-80 perspective-1000">
      <div 
        className={`relative w-full h-full flip-card transform-style-preserve-3d ${
          isFlipped ? 'rotate-y-180' : ''
        }`}
      >
        {/* Front Side - Profile */}
        <div className="absolute inset-0 w-full h-full backface-hidden bg-white rounded-2xl shadow-lg overflow-hidden cursor-pointer" onClick={handleFlip}>
          {/* Profile Image */}
          <div className="relative h-48 overflow-hidden">
            <ImageWithFallback
              src={avatar}
              alt={name}
              className="w-full h-full object-cover"
            />
            
            {/* Flip indicator */}
            <div className="absolute top-3 right-3 bg-black bg-opacity-50 text-white p-2 rounded-full">
              <Star size={16} />
            </div>
            
            {/* Rating badge */}
            {totalRatings > 0 && (
              <div className="absolute top-3 left-3 bg-orange-500 text-white px-2 py-1 rounded-full text-xs font-medium">
                ⭐ {dateRating.toFixed(1)}
              </div>
            )}
          </div>
          
          {/* Profile Info */}
          <div className="p-4">
            <div className="flex items-center justify-between mb-2">
              <h3 className="font-semibold text-gray-900 text-lg">{name}</h3>
              <div className="flex items-center space-x-1 text-xs text-gray-500">
                <Heart size={12} />
                <span>{years}y</span>
              </div>
            </div>
            
            <div className="flex items-center text-gray-600 text-sm mb-3">
              <MapPin size={12} className="mr-1" />
              <span className="truncate">{location}</span>
            </div>
            
            <div className="text-center">
              <p className="text-xs text-orange-600 font-medium mb-2">
                Tap to see date story & rate
              </p>
              <div className="flex justify-center space-x-1 mb-2">
                <div className="w-2 h-2 bg-orange-200 rounded-full"></div>
                <div className="w-2 h-2 bg-orange-400 rounded-full"></div>
                <div className="w-2 h-2 bg-orange-200 rounded-full"></div>
              </div>
              <div className="text-xs text-gray-500">
                ⭐ Tap anywhere to flip
              </div>
            </div>
          </div>
        </div>

        {/* Back Side - Date Story & Rating */}
        <div className="absolute inset-0 w-full h-full backface-hidden rotate-y-180 bg-gradient-to-br from-orange-50 to-pink-50 rounded-2xl shadow-lg overflow-hidden">
          {/* Header */}
          <div className="bg-orange-500 text-white p-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <ImageWithFallback
                  src={avatar}
                  alt={name}
                  className="w-10 h-10 rounded-full object-cover border-2 border-white"
                />
                <div>
                  <h3 className="font-semibold">{name}'s Date</h3>
                  <p className="text-orange-100 text-sm">{dateActivity}</p>
                </div>
              </div>
              <button 
                onClick={(e) => {
                  e.stopPropagation();
                  setIsFlipped(false);
                }} 
                className="p-1 hover:bg-white hover:bg-opacity-20 rounded transition-colors"
              >
                <X size={20} className="opacity-70" />
              </button>
            </div>
          </div>

          {/* Date Story */}
          <div className="p-4 flex-1">
            <div className="mb-4">
              <div className="flex items-center text-gray-600 text-sm mb-2">
                <Calendar size={12} className="mr-1" />
                <span>{dateLocation}</span>
              </div>
              <p className="text-gray-800 text-sm leading-relaxed">
                {dateStory}
              </p>
            </div>

            {/* Rating Stats */}
            {totalRatings > 0 && (
              <div className="mb-4 p-3 bg-white rounded-lg" onClick={(e) => e.stopPropagation()}>
                <h4 className="text-xs font-medium text-gray-700 mb-2">
                  Community Ratings ({totalRatings} votes)
                </h4>
                <div className="space-y-2">
                  <div className="flex items-center justify-between text-xs">
                    <span className="flex items-center">
                      🤩 WOW! ({wowCount})
                    </span>
                    <span className="text-green-600">{getRatingPercentage(wowCount)}%</span>
                  </div>
                  <div className="flex items-center justify-between text-xs">
                    <span className="flex items-center">
                      👑 CheKMate! ({chekmateCount})
                    </span>
                    <span className="text-orange-600">{getRatingPercentage(chekmateCount)}%</span>
                  </div>
                  <div className="flex items-center justify-between text-xs">
                    <span className="flex items-center">
                      🚫 GTFOH! ({gtfohCount})
                    </span>
                    <span className="text-red-600">{getRatingPercentage(gtfohCount)}%</span>
                  </div>
                </div>
              </div>
            )}

            {/* Rating Buttons */}
            <div className="space-y-2" onClick={(e) => e.stopPropagation()}>
              <div className="text-center mb-3">
                <p className="text-sm font-medium text-gray-700 mb-2">
                  {hasRated ? 'Thanks for rating!' : 'How was this date?'}
                </p>
                {hasRated && (
                  <button 
                    onClick={(e) => {
                      e.stopPropagation();
                      setIsFlipped(false);
                    }}
                    className="text-xs text-orange-600 hover:text-orange-700 underline"
                  >
                    ← Back to Profile
                  </button>
                )}
              </div>
              
              <div className="grid grid-cols-1 gap-2">
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    handleRate('wow');
                  }}
                  disabled={hasRated}
                  className={`rating-button p-3 rounded-lg font-medium ${
                    selectedRating === 'wow'
                      ? 'bg-green-500 text-white rating-success'
                      : hasRated
                      ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                      : 'bg-green-100 text-green-700 hover:bg-green-200'
                  }`}
                >
                  <div className="flex items-center justify-center space-x-2">
                    <span className="text-lg">🤩</span>
                    <span>WOW!</span>
                  </div>
                </button>

                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    handleRate('chekmate');
                  }}
                  disabled={hasRated}
                  className={`rating-button p-3 rounded-lg font-medium ${
                    selectedRating === 'chekmate'
                      ? 'bg-orange-500 text-white rating-success'
                      : hasRated
                      ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                      : 'bg-orange-100 text-orange-700 hover:bg-orange-200'
                  }`}
                >
                  <div className="flex items-center justify-center space-x-2">
                    <span className="text-lg">👑</span>
                    <span>CheKMate!</span>
                  </div>
                </button>

                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    handleRate('gtfoh');
                  }}
                  disabled={hasRated}
                  className={`rating-button p-3 rounded-lg font-medium ${
                    selectedRating === 'gtfoh'
                      ? 'bg-red-500 text-white rating-success'
                      : hasRated
                      ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                      : 'bg-red-100 text-red-700 hover:bg-red-200'
                  }`}
                >
                  <div className="flex items-center justify-center space-x-2">
                    <span className="text-lg">🚫</span>
                    <span>GTFOH!</span>
                  </div>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Rating confirmation animation */}
      {hasRated && selectedRating && (
        <div className="absolute inset-0 pointer-events-none flex items-center justify-center z-10">
          <div className="bg-black bg-opacity-75 text-white px-4 py-2 rounded-full text-sm font-medium animate-bounce">
            Rating submitted! 🎉
          </div>
        </div>
      )}
    </div>
  );
});

export { FlippableProfileCard };