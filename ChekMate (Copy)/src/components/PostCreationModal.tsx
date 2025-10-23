import React, { useState } from 'react';
import { X, Camera, Image, Smile, MapPin } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface PostCreationModalProps {
  isOpen: boolean;
  onClose: () => void;
  userAvatar: string;
  onCreatePost: (content: string) => void;
}

export function PostCreationModal({ isOpen, onClose, userAvatar, onCreatePost }: PostCreationModalProps) {
  const [content, setContent] = useState('');

  const handleSubmit = () => {
    if (content.trim()) {
      onCreatePost(content.trim());
      setContent('');
      onClose();
    }
  };

  const handleClose = () => {
    setContent('');
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-[9999] flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl w-full max-w-lg max-h-[80vh] overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b border-gray-100">
          <h2 className="text-lg font-semibold text-gray-900">Create Post</h2>
          <button onClick={handleClose} className="p-1 rounded-full hover:bg-gray-100">
            <X size={20} className="text-gray-600" />
          </button>
        </div>

        {/* Content */}
        <div className="p-4">
          <div className="flex items-start space-x-3">
            {/* User Avatar */}
            <ImageWithFallback
              src={userAvatar}
              alt="Your profile"
              className="w-12 h-12 rounded-full object-cover flex-shrink-0"
            />

            {/* Input Area */}
            <div className="flex-1">
              {/* Text Input */}
              <textarea
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder="Share your dating story..."
                rows={4}
                className="w-full p-3 bg-gray-50 rounded-2xl border-none outline-none resize-none focus:ring-2 focus:ring-orange-200 focus:bg-white transition-all duration-200"
                autoFocus
              />

              {/* Character Count */}
              <div className="flex justify-end mt-2">
                <span className={`text-xs ${
                  content.length > 280 ? 'text-red-500' : 'text-gray-500'
                }`}>
                  {content.length}/280
                </span>
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="mt-4 pt-4 border-t border-gray-100">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center space-x-4">
                <button className="flex items-center space-x-2 text-gray-600 hover:text-orange-400 transition-colors p-2 rounded-lg hover:bg-gray-50">
                  <Camera size={20} />
                  <span className="text-sm">Photo</span>
                </button>
                
                <button className="flex items-center space-x-2 text-gray-600 hover:text-orange-400 transition-colors p-2 rounded-lg hover:bg-gray-50">
                  <Image size={20} />
                  <span className="text-sm">Gallery</span>
                </button>
                
                <button className="flex items-center space-x-2 text-gray-600 hover:text-orange-400 transition-colors p-2 rounded-lg hover:bg-gray-50">
                  <Smile size={20} />
                  <span className="text-sm">Feeling</span>
                </button>
                
                <button className="flex items-center space-x-2 text-gray-600 hover:text-orange-400 transition-colors p-2 rounded-lg hover:bg-gray-50">
                  <MapPin size={20} />
                  <span className="text-sm">Location</span>
                </button>
              </div>
            </div>

            {/* Post Button */}
            <div className="flex justify-end space-x-3">
              <button
                onClick={handleClose}
                className="px-6 py-2 text-gray-600 hover:text-gray-800 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleSubmit}
                disabled={!content.trim() || content.length > 280}
                className={`px-6 py-2 rounded-full font-medium transition-all duration-200 ${
                  content.trim() && content.length <= 280
                    ? 'bg-orange-400 text-white hover:bg-orange-500'
                    : 'bg-gray-200 text-gray-400 cursor-not-allowed'
                }`}
              >
                Post
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}