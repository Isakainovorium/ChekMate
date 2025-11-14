import React from 'react';
import { X, ChevronDown, Bookmark, Share2, Filter, Upload, UserPlus, Users, Info } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import exampleImage from 'figma:asset/3a438d82a14f46836aebbaf58b012e153fecc85d.png';

interface PostDetailModalProps {
  isOpen: boolean;
  onClose: () => void;
  post: {
    id: string;
    username: string;
    avatar: string;
    content: string;
    image?: string;
    caption?: string;
  };
}

export function PostDetailModal({ isOpen, onClose, post }: PostDetailModalProps) {
  if (!isOpen) return null;

  const stories = [
    { id: 1, avatar: post.avatar },
    { id: 2, avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NTk3MTMyNTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral' },
    { id: 3, avatar: 'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2Zlc3Npb25hbCUyMGhlYWRzaG90fGVufDF8fHx8MTc1OTczMDU0M3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral' },
    { id: 4, avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral' },
    { id: 5, avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NTk3MTMyNTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral' },
    { id: 6, avatar: 'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2Zlc3Npb25hbCUyMGhlYWRzaG90fGVufDF8fHx8MTc1OTczMDU0M3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral' }
  ];

  return (
    <div className="fixed inset-0 bg-white z-50 overflow-y-auto">
      {/* Header */}
      <div className="sticky top-0 bg-white border-b border-gray-100 px-4 py-3">
        <div className="flex items-center justify-between">
          <img src={exampleImage} alt="ChekMate" className="h-8" />
          <div className="flex-1 max-w-md mx-4">
            <div className="relative">
              <input
                type="text"
                placeholder="Search here ..."
                className="w-full pl-4 pr-4 py-2 bg-gray-50 rounded-full border-none outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>
          </div>
          <button onClick={onClose}>
            <X size={24} className="text-gray-700" />
          </button>
        </div>
      </div>

      {/* Stories Section */}
      <div className="bg-white px-4 py-4">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">Stories</h2>
          <button className="flex items-center space-x-1 text-gray-600">
            <span className="text-sm">Sort by Time</span>
            <ChevronDown size={16} />
          </button>
        </div>
        
        <div className="flex space-x-3 overflow-x-auto">
          {stories.map((story) => (
            <div key={story.id} className="flex-shrink-0">
              <div className="w-16 h-16 rounded-full p-1 bg-gradient-to-r from-orange-400 to-yellow-400">
                <ImageWithFallback
                  src={story.avatar}
                  alt="Story"
                  className="w-full h-full rounded-full object-cover bg-white p-1"
                />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Post Content */}
      <div className="bg-white">
        {/* Post Header */}
        <div className="flex items-center px-4 py-3">
          <ImageWithFallback
            src={post.avatar}
            alt={post.username}
            className="w-12 h-12 rounded-full object-cover mr-3"
          />
          <h3 className="text-lg font-semibold text-gray-900">{post.username}</h3>
        </div>

        {/* Post Title */}
        <div className="px-4 pb-4">
          <h2 className="text-xl font-semibold text-gray-900">{post.content}</h2>
        </div>

        {/* Post Image */}
        {post.image && (
          <div className="mb-6">
            <ImageWithFallback
              src={post.image}
              alt="Post content"
              className="w-full aspect-video object-cover"
            />
          </div>
        )}

        {/* Action Buttons */}
        <div className="px-4 space-y-3 pb-6">
          {/* Row 1 */}
          <div className="grid grid-cols-2 gap-3">
            <button className="flex items-center justify-center space-x-2 bg-gray-100 rounded-lg py-4 px-4">
              <Bookmark size={20} className="text-gray-700" />
              <span className="text-gray-900 font-medium">Chek</span>
            </button>
            <button className="flex items-center justify-center space-x-2 bg-gray-100 rounded-lg py-4 px-4">
              <Share2 size={20} className="text-gray-700" />
              <span className="text-gray-900 font-medium">Share with friends</span>
            </button>
          </div>

          {/* Individual Action Items */}
          <button className="flex items-center space-x-3 bg-gray-100 rounded-lg py-4 px-4 w-full">
            <Filter size={20} className="text-gray-700" />
            <span className="text-gray-900 font-medium">Share to story</span>
          </button>

          <button className="flex items-center space-x-3 bg-gray-100 rounded-lg py-4 px-4 w-full">
            <Upload size={20} className="text-gray-700" />
            <span className="text-gray-900 font-medium">Share Via...</span>
          </button>

          <button className="flex items-center space-x-3 bg-gray-100 rounded-lg py-4 px-4 w-full">
            <UserPlus size={20} className="text-gray-700" />
            <span className="text-gray-900 font-medium">Follow {post.username}</span>
          </button>

          <button className="flex items-center space-x-3 bg-gray-100 rounded-lg py-4 px-4 w-full">
            <Users size={20} className="text-gray-700" />
            <span className="text-gray-900 font-medium">Find Friends</span>
          </button>

          <button className="flex items-center space-x-3 bg-gray-100 rounded-lg py-4 px-4 w-full">
            <Info size={20} className="text-gray-700" />
            <span className="text-gray-900 font-medium">Privacy Policy</span>
          </button>

          <button className="flex items-center space-x-3 bg-gray-100 rounded-lg py-4 px-4 w-full">
            <Info size={20} className="text-gray-700" />
            <span className="text-gray-900 font-medium">Terms and conditions</span>
          </button>
        </div>
      </div>
    </div>
  );
}