import React, { useState } from 'react';
import { X, Search, MessageSquare, Mail, Plus, Heart, Flag, Download, ChevronDown } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface ShareModalProps {
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
  hideStories?: boolean;
}

const storyUsers = [
  {
    id: '1',
    avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  },
  {
    id: '2',
    avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NTk3MTMyNTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  },
  {
    id: '3',
    avatar: 'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2Zlc3Npb25hbCUyMGhlYWRzaG90fGVufDF8fHx8MTc1OTczMDU0M3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  },
  {
    id: '4',
    avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  },
  {
    id: '5',
    avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NTk3MTMyNTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  }
];

const shareToUsers = [
  {
    id: '1',
    avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  },
  {
    id: '2',
    avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NTk3MTMyNTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  },
  {
    id: '3',
    avatar: 'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2Zlc3Npb25hbCUyMGhlYWRzaG90fGVufDF8fHx8MTc1OTczMDU0M3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  },
  {
    id: '4',
    avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  },
  {
    id: '5',
    avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NTk3MTMyNTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  }
];

export function ShareModal({ isOpen, onClose, post, hideStories = true }: ShareModalProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-white z-50 overflow-y-auto">
      {/* Header */}
      <div className="sticky top-0 bg-white border-b border-gray-100 px-4 py-3">
        <div className="flex items-center justify-between">
          <div className="w-8 h-8 bg-orange-400 rounded-lg flex items-center justify-center">
            <span className="text-white font-bold text-lg">C</span>
          </div>
          <div className="flex-1 max-w-md mx-4">
            <div className="relative">
              <Search size={18} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search here ..."
                className="w-full pl-10 pr-4 py-2 bg-gray-50 rounded-full border-none outline-none focus:ring-2 focus:ring-orange-200"
              />
            </div>
          </div>
          <button onClick={onClose}>
            <X size={24} className="text-gray-700" />
          </button>
        </div>
      </div>

      {/* Stories Section */}
      <div className={`bg-white px-4 py-4 ${hideStories ? 'hidden' : ''}`}>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">Stories</h2>
          <div className="flex items-center space-x-1">
            <span className="text-sm text-gray-600">Sort by Time</span>
            <ChevronDown size={16} className="text-gray-600" />
          </div>
        </div>
        
        <div className="flex space-x-3 overflow-x-auto">
          {storyUsers.map((user) => (
            <div key={user.id} className="flex-shrink-0">
              <div className="w-16 h-16 rounded-full p-1 bg-gradient-to-r from-orange-400 to-yellow-400">
                <ImageWithFallback
                  src={user.avatar}
                  alt="Story"
                  className="w-full h-full rounded-full object-cover bg-white p-1"
                />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Post Content */}
      <div className="bg-white border-b border-gray-100 px-4 py-4">
        <div className="flex items-center mb-4">
          <ImageWithFallback
            src={post.avatar}
            alt={post.username}
            className="w-12 h-12 rounded-full object-cover mr-3"
          />
          <h3 className="text-lg font-semibold text-gray-900">{post.username}</h3>
        </div>

        <div className="mb-4">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">{post.content}</h2>
          
          {post.image && (
            <div className="relative">
              <ImageWithFallback
                src={post.image}
                alt="Post content"
                className="w-full aspect-video object-cover rounded-lg"
              />
              {post.caption && (
                <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-4 rounded-b-lg">
                  <p className="text-white text-lg font-semibold">{post.caption}</p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Search Recipients */}
      <div className="bg-white px-4 py-4">
        <div className="relative mb-6">
          <Search size={18} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search here ..."
            className="w-full pl-10 pr-4 py-3 bg-gray-50 rounded-full border-none outline-none focus:ring-2 focus:ring-orange-200"
          />
        </div>

        {/* Send to Section */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Send to</h3>
          <div className="flex space-x-4 overflow-x-auto pb-2">
            {shareToUsers.map((user) => (
              <button key={user.id} className="flex-shrink-0">
                <div className="w-16 h-16 rounded-full">
                  <ImageWithFallback
                    src={user.avatar}
                    alt="User"
                    className="w-full h-full rounded-full object-cover"
                  />
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Social Media Sharing */}
        <div className="grid grid-cols-6 gap-4 mb-6">
          <button className="flex flex-col items-center">
            <div className="w-12 h-12 bg-gray-800 rounded-full flex items-center justify-center mb-2">
              <MessageSquare size={20} className="text-white" />
            </div>
            <span className="text-xs text-gray-700">SMS</span>
          </button>
          
          <button className="flex flex-col items-center">
            <div className="w-12 h-12 bg-blue-500 rounded-full flex items-center justify-center mb-2">
              <Mail size={20} className="text-white" />
            </div>
            <span className="text-xs text-gray-700">Email</span>
          </button>
          
          <button className="flex flex-col items-center">
            <div className="w-12 h-12 bg-green-500 rounded-full flex items-center justify-center mb-2">
              <MessageSquare size={20} className="text-white" />
            </div>
            <span className="text-xs text-gray-700">Whatsapp</span>
          </button>
          
          <button className="flex flex-col items-center">
            <div className="w-12 h-12 bg-gradient-to-br from-purple-500 via-pink-500 to-orange-400 rounded-full flex items-center justify-center mb-2">
              <div className="w-6 h-6 bg-white rounded-sm flex items-center justify-center">
                <div className="w-4 h-4 border-2 border-gray-800 rounded-sm relative">
                  <div className="w-1 h-1 bg-gray-800 rounded-full absolute top-1 right-1"></div>
                </div>
              </div>
            </div>
            <span className="text-xs text-gray-700">Instagram</span>
          </button>
          
          <button className="flex flex-col items-center">
            <div className="w-12 h-12 bg-black rounded-full flex items-center justify-center mb-2">
              <X size={20} className="text-white" />
            </div>
            <span className="text-xs text-gray-700">X</span>
          </button>
          
          <button className="flex flex-col items-center">
            <div className="w-12 h-12 bg-blue-600 rounded-full flex items-center justify-center mb-2">
              <span className="text-white font-bold text-xl">f</span>
            </div>
            <span className="text-xs text-gray-700">Facebook</span>
          </button>
        </div>

        {/* Action Buttons */}
        <div className="grid grid-cols-5 gap-3 mb-8">
          <button className="flex flex-col items-center">
            <div className="w-12 h-12 bg-orange-400 rounded-full flex items-center justify-center mb-2">
              <Plus size={20} className="text-white" />
            </div>
            <span className="text-xs text-gray-700 text-center">Add to story</span>
          </button>
          
          <button className="flex flex-col items-center">
            <div className="w-12 h-12 bg-gray-800 rounded-full flex items-center justify-center mb-2">
              <Heart size={20} className="text-white" />
            </div>
            <span className="text-xs text-gray-700 text-center">Not interested</span>
          </button>
          
          <button className="flex flex-col items-center">
            <div className="w-12 h-12 bg-gray-800 rounded-full flex items-center justify-center mb-2">
              <div className="w-5 h-5 border-2 border-white rounded relative">
                <div className="absolute inset-1 bg-white rounded-sm"></div>
              </div>
            </div>
            <span className="text-xs text-gray-700 text-center">Stitch Video</span>
          </button>
          
          <button className="flex flex-col items-center">
            <div className="w-12 h-12 bg-gray-800 rounded-full flex items-center justify-center mb-2">
              <Flag size={20} className="text-white" />
            </div>
            <span className="text-xs text-gray-700 text-center">Report</span>
          </button>
          
          <button className="flex flex-col items-center">
            <div className="w-12 h-12 bg-gray-800 rounded-full flex items-center justify-center mb-2">
              <Download size={20} className="text-white" />
            </div>
            <span className="text-xs text-gray-700 text-center">Save</span>
          </button>
        </div>
      </div>
      
      {/* Bottom spacing for safe area */}
      <div className="h-8"></div>
    </div>
  );
}