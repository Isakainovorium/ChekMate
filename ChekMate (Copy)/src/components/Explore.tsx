import React, { useState } from 'react';
import { Search, TrendingUp, Hash, Users, Heart, MessageCircle, Share } from 'lucide-react';
import { Post } from './Post';
import { ImageWithFallback } from './figma/ImageWithFallback';

const exploreCategories = [
  { id: 'trending', label: 'Trending', icon: TrendingUp },
  { id: 'popular', label: 'Popular', icon: Heart },
  { id: 'hashtags', label: 'Hashtags', icon: Hash },
  { id: 'people', label: 'People', icon: Users }
];

const trendingHashtags = [
  { tag: '#DateNight', posts: '15.2K posts' },
  { tag: '#RelationshipGoals', posts: '8.7K posts' },
  { tag: '#DatingTips', posts: '12.1K posts' },
  { tag: '#LoveStory', posts: '6.8K posts' },
  { tag: '#FirstDate', posts: '9.3K posts' },
  { tag: '#RedFlags', posts: '11.5K posts' }
];

const suggestedUsers = [
  {
    id: '1',
    name: 'Dating Coach Sarah',
    username: '@datingcoach_sarah',
    avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2Zlc3Npb25hbCUyMGhlYWRzaG90fGVufDF8fHx8MTc1OTc1Nzk2N3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    followers: '45.2K',
    bio: 'Helping singles find meaningful connections 💕'
  },
  {
    id: '2',
    name: 'Love Life Guru',
    username: '@lovelife_guru',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwcm9mZXNzaW9uYWwlMjBzbWlsZXxlbnwxfHx8fDE3NTk3NTc5NTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    followers: '78.9K',
    bio: 'Relationship wisdom for modern dating'
  },
  {
    id: '3',
    name: 'Couples Therapy Plus',
    username: '@couplestherapy',
    avatar: 'https://images.unsplash.com/photo-1551836022-deb4988cc6c0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2Zlc3Npb25hbCUyMGJ1c2luZXNzfGVufDF8fHx8MTc1OTc1Nzk3MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    followers: '32.1K',
    bio: 'Building stronger relationships together'
  }
];

const trendingPosts = [
  {
    id: 'e1',
    username: 'RelationshipExpert',
    avatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2Zlc3Npb25hbCUyMGhlYWRzaG90fGVufDF8fHx8MTc1OTc1Nzk3NXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: '🔥 VIRAL: The 5 Dating Red Flags Everyone Ignores (Thread)',
    image: 'https://images.unsplash.com/photo-1516975280-8c86b485204e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb3VwbGUlMjBhcmd1aW5nJTIwcmVsYXRpb25zaGlwfGVufDF8fHx8MTc1OTc1Nzk3OXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    likes: 45600,
    comments: 2800,
    shares: 1200,
    timestamp: '2h ago'
  },
  {
    id: 'e2',
    username: 'ModernDating',
    avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHNtaWxpbmclMjBwb3J0cmFpdHxlbnwxfHx8fDE3NTk3NTc5ODN8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: 'POV: You finally found someone who texts back with the same energy ✨',
    likes: 38900,
    comments: 1560,
    shares: 890,
    timestamp: '4h ago'
  },
  {
    id: 'e3',
    username: 'DatingStories',
    avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwcm9mZXNzaW9uYWwlMjBoZWFkc2hvdHxlbnwxfHx8fDE3NTk3NTc5ODd8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: 'Update: The girl who ghosted me last month just asked to hang out. What should I do? 👻',
    likes: 12400,
    comments: 3200,
    shares: 450,
    timestamp: '6h ago'
  }
];

interface ExploreProps {
  onShareModalOpen?: () => void;
  onShareModalClose?: () => void;
}

export function Explore({ onShareModalOpen, onShareModalClose }: ExploreProps) {
  const [activeCategory, setActiveCategory] = useState('trending');
  const [searchQuery, setSearchQuery] = useState('');

  const renderTrendingSection = () => (
    <div className="space-y-4">
      {/* Trending Posts */}
      <div className="bg-white">
        <div className="px-4 py-3 border-b border-gray-100">
          <h3 className="font-semibold text-gray-900 flex items-center">
            <TrendingUp size={18} className="text-orange-400 mr-2" />
            Trending Now
          </h3>
        </div>
        {trendingPosts.map((post) => (
          <Post 
            key={post.id} 
            {...post} 
            onShareModalOpen={onShareModalOpen}
            onShareModalClose={onShareModalClose}
          />
        ))}
      </div>
    </div>
  );

  const renderHashtagsSection = () => (
    <div className="bg-white rounded-lg">
      <div className="px-4 py-3 border-b border-gray-100">
        <h3 className="font-semibold text-gray-900 flex items-center">
          <Hash size={18} className="text-orange-400 mr-2" />
          Trending Hashtags
        </h3>
      </div>
      <div className="p-4">
        <div className="grid grid-cols-2 gap-4">
          {trendingHashtags.map((hashtag, index) => (
            <button
              key={index}
              className="p-4 bg-gray-50 rounded-lg text-left hover:bg-gray-100 transition-colors"
            >
              <p className="font-semibold text-orange-500">{hashtag.tag}</p>
              <p className="text-sm text-gray-600 mt-1">{hashtag.posts}</p>
            </button>
          ))}
        </div>
      </div>
    </div>
  );

  const renderPeopleSection = () => (
    <div className="bg-white rounded-lg">
      <div className="px-4 py-3 border-b border-gray-100">
        <h3 className="font-semibold text-gray-900 flex items-center">
          <Users size={18} className="text-orange-400 mr-2" />
          Suggested People
        </h3>
      </div>
      <div className="p-4 space-y-4">
        {suggestedUsers.map((user) => (
          <div key={user.id} className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <ImageWithFallback
                src={user.avatar}
                alt={user.name}
                className="w-12 h-12 rounded-full object-cover"
              />
              <div>
                <h4 className="font-semibold text-gray-900">{user.name}</h4>
                <p className="text-sm text-gray-600">{user.username}</p>
                <p className="text-xs text-gray-500">{user.followers} followers</p>
              </div>
            </div>
            <button className="px-4 py-2 bg-orange-400 text-white rounded-full text-sm font-medium hover:bg-orange-500 transition-colors">
              Follow
            </button>
          </div>
        ))}
      </div>
    </div>
  );

  const renderContent = () => {
    switch (activeCategory) {
      case 'trending':
        return renderTrendingSection();
      case 'hashtags':
        return renderHashtagsSection();
      case 'people':
        return renderPeopleSection();
      case 'popular':
        return renderTrendingSection(); // Reuse trending for now
      default:
        return renderTrendingSection();
    }
  };

  return (
    <div className="pb-16">
      {/* Search Bar */}
      <div className="bg-white border-b border-gray-100 px-4 py-4">
        <div className="relative">
          <Search size={18} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search trending topics, people, hashtags..."
            className="w-full pl-10 pr-4 py-3 bg-gray-50 rounded-full border-none outline-none focus:ring-2 focus:ring-orange-200"
          />
        </div>
      </div>

      {/* Category Tabs */}
      <div className="bg-white border-b border-gray-100">
        <div className="flex items-center px-4 overflow-x-auto scrollbar-hide">
          {exploreCategories.map((category) => {
            const Icon = category.icon;
            return (
              <button
                key={category.id}
                onClick={() => setActiveCategory(category.id)}
                className={`flex items-center space-x-2 px-4 py-3 whitespace-nowrap transition-colors ${
                  activeCategory === category.id
                    ? 'text-orange-500 border-b-2 border-orange-500'
                    : 'text-gray-600 hover:text-gray-900'
                }`}
              >
                <Icon size={16} />
                <span>{category.label}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Explore Stats */}
      <div className="bg-white border-b border-gray-100 px-4 py-3">
        <div className="flex items-center justify-between text-sm text-gray-600">
          <span>🔥 {activeCategory === 'trending' ? '10.2K' : '8.7K'} trending posts today</span>
          <span>📈 {activeCategory === 'people' ? '150+' : '200+'} new {activeCategory}</span>
        </div>
      </div>

      {/* Content */}
      <div className="p-4">
        {renderContent()}
      </div>

      {/* Load More */}
      <div className="text-center py-6">
        <button className="px-6 py-3 bg-orange-400 text-white rounded-full font-medium hover:bg-orange-500 transition-colors">
          Load More Content
        </button>
      </div>
    </div>
  );
}