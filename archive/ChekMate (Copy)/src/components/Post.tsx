import React, { useState } from 'react';
import { Heart, MessageCircle, Share, MoreHorizontal, Bookmark } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { PostDetailModal } from './PostDetailModal';
import { ShareModal } from './ShareModal';

interface PostProps {
  id: string;
  username: string;
  avatar: string;
  content: string;
  image?: string;
  likes: number;
  comments: number;
  shares: number;
  timestamp: string;
  caption?: string;
  onShareModalOpen?: () => void;
  onShareModalClose?: () => void;
}

export function Post({ 
  id,
  username, 
  avatar, 
  content, 
  image, 
  likes, 
  comments, 
  shares, 
  timestamp,
  caption,
  onShareModalOpen,
  onShareModalClose
}: PostProps) {
  const [isLiked, setIsLiked] = useState(false);
  const [likeCount, setLikeCount] = useState(likes);
  const [showModal, setShowModal] = useState(false);
  const [showShareModal, setShowShareModal] = useState(false);

  const handleLike = () => {
    setIsLiked(!isLiked);
    setLikeCount(isLiked ? likeCount - 1 : likeCount + 1);
  };

  const formatNumber = (num: number) => {
    if (num >= 1000) {
      return `${(num / 1000).toFixed(1)}k`;
    }
    return num.toString();
  };

  return (
    <>
      <PostDetailModal 
        isOpen={showModal} 
        onClose={() => setShowModal(false)} 
        post={{ id, username, avatar, content, image, caption }}
      />
      <ShareModal
        isOpen={showShareModal}
        onClose={() => {
          setShowShareModal(false);
          onShareModalClose?.();
        }}
        post={{ id, username, avatar, content, image, caption }}
      />
      <div className="bg-white border-b border-gray-100">
      {/* Post Header */}
      <div className="flex items-center justify-between px-4 py-3">
        <div className="flex items-center space-x-3">
          <ImageWithFallback
            src={avatar}
            alt={username}
            className="w-10 h-10 rounded-full object-cover"
          />
          <div>
            <h3 className="text-sm font-semibold">{username}</h3>
            <p className="text-xs text-gray-500">{timestamp}</p>
          </div>
        </div>
        <button className="p-1" onClick={() => setShowModal(true)}>
          <MoreHorizontal size={20} className="text-gray-500" />
        </button>
      </div>

      {/* Post Content */}
      <div className="px-4 pb-3">
        <p className="text-sm mb-3">{content}</p>
      </div>

      {/* Post Image */}
      {image && (
        <div className="relative">
          <ImageWithFallback
            src={image}
            alt="Post content"
            className="w-full aspect-square object-cover"
          />
          {caption && (
            <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-4">
              <p className="text-white text-lg font-semibold">{caption}</p>
            </div>
          )}
        </div>
      )}

      {/* Post Actions */}
      <div className="px-4 py-3">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center space-x-4">
            <button onClick={handleLike} className="flex items-center space-x-1">
              <Heart 
                size={20} 
                className={`${isLiked ? 'text-red-500 fill-current' : 'text-gray-600'}`} 
              />
              <span className="text-sm">{formatNumber(likeCount)}</span>
            </button>
            <button className="flex items-center space-x-1">
              <MessageCircle size={20} className="text-gray-600" />
              <span className="text-sm">{formatNumber(comments)}</span>
            </button>
            <button onClick={() => {
              setShowShareModal(true);
              onShareModalOpen?.();
            }} className="flex items-center space-x-1">
              <Share size={20} className="text-gray-600" />
              <span className="text-sm">{formatNumber(shares)}</span>
            </button>
          </div>
          <button>
            <Bookmark size={20} className="text-gray-600" />
          </button>
        </div>
        
        {/* Liked by text */}
        <p className="text-sm text-gray-600">
          <span className="font-semibold">Simone Gabrielle</span> and{' '}
          <span className="font-semibold">{formatNumber(likeCount - 1)} others</span> liked this post
        </p>
        
        {/* Caption preview */}
        {caption && (
          <p className="text-sm text-gray-600 mt-1">
            <span className="font-semibold">{username}</span> {caption.toLowerCase()}
          </p>
        )}
      </div>
    </div>
    </>
  );
}