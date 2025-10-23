import React, { useState } from 'react';
import { Camera, Image, Smile, MapPin } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface PostInputBarProps {
  userAvatar: string;
  onCreatePost: (content: string) => void;
  placeholder?: string;
}

export function PostInputBar({ 
  userAvatar, 
  onCreatePost, 
  placeholder = "What's on your mind?" 
}: PostInputBarProps) {
  const [content, setContent] = useState('');
  const [showExpanded, setShowExpanded] = useState(false);

  const handleSubmit = () => {
    if (content.trim()) {
      onCreatePost(content.trim());
      setContent('');
      setShowExpanded(false);
    }
  };

  const handleFocus = () => {
    setShowExpanded(true);
  };

  return (
    <div className="bg-white border-b border-gray-100 p-4">
      <div className="flex items-start space-x-3 hidden">
        {/* User Avatar */}
        <ImageWithFallback
          src={userAvatar}
          alt="Your profile"
          className="w-10 h-10 rounded-full object-cover flex-shrink-0"
        />

        {/* Input Area */}
        <div className="flex-1">
          {/* Text Input */}
          <div className="relative">
            <textarea
              value={content}
              onChange={(e) => setContent(e.target.value)}
              onFocus={handleFocus}
              placeholder={placeholder}
              rows={showExpanded ? 3 : 1}
              className="w-full p-3 bg-gray-50 rounded-2xl border-none outline-none resize-none focus:ring-2 focus:ring-orange-200 focus:bg-white transition-all duration-200"
            />
          </div>

          {/* Expanded Options */}
          {showExpanded && (
            <div className="mt-3 space-y-3">
              {/* Action Buttons */}
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-4">
                  <button className="flex items-center space-x-2 text-gray-600 hover:text-orange-400 transition-colors">
                    <Camera size={20} />
                    <span className="text-sm">Photo</span>
                  </button>
                  
                  <button className="flex items-center space-x-2 text-gray-600 hover:text-orange-400 transition-colors">
                    <Image size={20} />
                    <span className="text-sm">Gallery</span>
                  </button>
                  
                  <button className="flex items-center space-x-2 text-gray-600 hover:text-orange-400 transition-colors">
                    <Smile size={20} />
                    <span className="text-sm">Feeling</span>
                  </button>
                  
                  <button className="flex items-center space-x-2 text-gray-600 hover:text-orange-400 transition-colors">
                    <MapPin size={20} />
                    <span className="text-sm">Location</span>
                  </button>
                </div>

                {/* Character Count */}
                {content.length > 0 && (
                  <div className="text-xs text-gray-500">
                    {content.length}/280
                  </div>
                )}
              </div>

              {/* Post Button */}
              <div className="flex justify-end space-x-3">
                <button
                  onClick={() => {
                    setShowExpanded(false);
                    setContent('');
                  }}
                  className="px-4 py-2 text-gray-600 hover:text-gray-800 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSubmit}
                  disabled={!content.trim()}
                  className={`px-6 py-2 rounded-full font-medium transition-all duration-200 ${
                    content.trim()
                      ? 'bg-orange-400 text-white hover:bg-orange-500'
                      : 'bg-gray-200 text-gray-400 cursor-not-allowed'
                  }`}
                >
                  Post
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}