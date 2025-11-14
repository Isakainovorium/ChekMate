import React, { useState } from 'react';
import { Video, Users, Heart, MessageCircle, Gift, Share2, Play, Eye, Mic, MicOff, VideoOff } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

const liveCategories = [
  { id: 'all', label: 'All Live', icon: Video },
  { id: 'dating', label: 'Dating Q&A', icon: Heart },
  { id: 'advice', label: 'Relationship Advice', icon: MessageCircle },
  { id: 'dates', label: 'Live Dates', icon: Users }
];

const activeLiveStreams = [
  {
    id: '1',
    streamer: 'Dating Coach Sarah',
    username: '@sarahcoach',
    avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2Zlc3Npb25hbCUyMGhlYWRzaG90fGVufDF8fHx8MTc1OTc1Nzk2N3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    title: 'Red Flags in Modern Dating - Ask Me Anything!',
    viewers: '2.4K',
    duration: '1h 23m',
    category: 'Dating Q&A',
    thumbnail: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHRhbGtpbmclMjBwcmVzZW50YXRpb258ZW58MXx8fHwxNzU5NzU3OTkzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  },
  {
    id: '2',
    streamer: 'Mike & Jessica',
    username: '@mikejess_couple',
    avatar: 'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb3VwbGUlMjBoYXBweSUyMHBvcnRyYWl0fGVufDF8fHx8MTc1OTc1Nzk5N3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    title: 'Live Date Night: Cooking Together at Home',
    viewers: '1.8K',
    duration: '45m',
    category: 'Live Dates',
    thumbnail: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb3VwbGUlMjBjb29raW5nJTIwdG9nZXRoZXJ8ZW58MXx8fHwxNzU5NzU4MDAxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  },
  {
    id: '3',
    streamer: 'Love Life Guru',
    username: '@lovelifeguru',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwcm9mZXNzaW9uYWwlMjBzbWlsZXxlbnwxfHx8fDE3NTk3NTc5NTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    title: 'Texting Etiquette: When to Text, When to Call',
    viewers: '956',
    duration: '28m',
    category: 'Relationship Advice',
    thumbnail: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwaG9uZSUyMHRleHRpbmclMjBtZXNzYWdpbmd8ZW58MXx8fHwxNzU5NzU4MDA1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  },
  {
    id: '4',
    streamer: 'First Date Stories',
    username: '@firstdatestories',
    avatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHNtaWxpbmclMjBwb3J0cmFpdHxlbnwxfHx8fDE3NTk3NTc5ODN8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    title: 'Share Your Worst First Date Stories!',
    viewers: '3.1K',
    duration: '2h 5m',
    category: 'Dating Q&A',
    thumbnail: 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxyZXN0YXVyYW50JTIwZGF0ZSUyMGRpbm5lcnxlbnwxfHx8fDE3NTk3NTgwMDl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  }
];

interface LiveProps {
  userAvatar: string;
  onGoLive?: () => void;
}

export function Live({ userAvatar, onGoLive }: LiveProps) {
  const [activeCategory, setActiveCategory] = useState('all');
  const [showGoLiveModal, setShowGoLiveModal] = useState(false);
  const [selectedStream, setSelectedStream] = useState<typeof activeLiveStreams[0] | null>(null);

  const filteredStreams = activeCategory === 'all' 
    ? activeLiveStreams 
    : activeLiveStreams.filter(stream => 
        stream.category.toLowerCase().includes(activeCategory.replace('dating', 'q&a'))
      );

  const LiveStreamCard = ({ stream }: { stream: typeof activeLiveStreams[0] }) => (
    <div 
      className="relative bg-black rounded-lg overflow-hidden cursor-pointer transform transition-transform hover:scale-105"
      onClick={() => setSelectedStream(stream)}
    >
      {/* Thumbnail */}
      <div className="aspect-video relative">
        <ImageWithFallback
          src={stream.thumbnail}
          alt={stream.title}
          className="w-full h-full object-cover"
        />
        
        {/* Live indicator */}
        <div className="absolute top-3 left-3 bg-red-500 text-white px-2 py-1 rounded text-xs font-medium flex items-center">
          <div className="w-2 h-2 bg-white rounded-full mr-1 animate-pulse"></div>
          LIVE
        </div>
        
        {/* Viewer count */}
        <div className="absolute top-3 right-3 bg-black bg-opacity-60 text-white px-2 py-1 rounded text-xs flex items-center">
          <Eye size={12} className="mr-1" />
          {stream.viewers}
        </div>
        
        {/* Duration */}
        <div className="absolute bottom-3 right-3 bg-black bg-opacity-60 text-white px-2 py-1 rounded text-xs">
          {stream.duration}
        </div>
        
        {/* Play overlay */}
        <div className="absolute inset-0 bg-black bg-opacity-20 flex items-center justify-center opacity-0 hover:opacity-100 transition-opacity">
          <Play size={32} className="text-white fill-current" />
        </div>
      </div>
      
      {/* Stream info */}
      <div className="p-3 bg-white">
        <div className="flex items-start space-x-3">
          <ImageWithFallback
            src={stream.avatar}
            alt={stream.streamer}
            className="w-10 h-10 rounded-full object-cover flex-shrink-0"
          />
          <div className="flex-1 min-w-0">
            <h3 className="font-semibold text-gray-900 text-sm leading-tight mb-1">{stream.title}</h3>
            <p className="text-xs text-gray-600">{stream.streamer}</p>
            <p className="text-xs text-orange-500 mt-1">{stream.category}</p>
          </div>
        </div>
      </div>
    </div>
  );

  const GoLiveModal = () => {
    const [title, setTitle] = useState('');
    const [category, setCategory] = useState('dating');
    const [isLive, setIsLive] = useState(false);

    if (!showGoLiveModal) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl w-full max-w-md">
          {/* Header */}
          <div className="flex items-center justify-between p-4 border-b">
            <h2 className="text-lg font-semibold">Go Live</h2>
            <button onClick={() => setShowGoLiveModal(false)} className="text-gray-500">✕</button>
          </div>
          
          {/* Content */}
          <div className="p-4 space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Stream Title</label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="What's your stream about?"
                className="w-full p-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-orange-200 focus:border-orange-400"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Category</label>
              <select 
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="w-full p-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-orange-200 focus:border-orange-400"
              >
                <option value="dating">Dating Q&A</option>
                <option value="advice">Relationship Advice</option>
                <option value="dates">Live Dates</option>
                <option value="other">Other</option>
              </select>
            </div>
            
            {/* Camera preview */}
            <div className="aspect-video bg-gray-100 rounded-lg flex items-center justify-center">
              <div className="text-center">
                <Video size={32} className="text-gray-400 mx-auto mb-2" />
                <p className="text-sm text-gray-600">Camera Preview</p>
              </div>
            </div>
            
            {/* Controls */}
            <div className="flex justify-center space-x-4">
              <button className="p-3 bg-gray-100 rounded-full">
                <Mic size={20} className="text-gray-600" />
              </button>
              <button className="p-3 bg-gray-100 rounded-full">
                <Video size={20} className="text-gray-600" />
              </button>
            </div>
            
            {/* Go Live Button */}
            <button 
              onClick={() => {
                setIsLive(true);
                setTimeout(() => {
                  setShowGoLiveModal(false);
                  setIsLive(false);
                }, 2000);
              }}
              disabled={!title.trim()}
              className={`w-full py-3 rounded-lg font-medium transition-colors ${
                title.trim() 
                  ? 'bg-red-500 text-white hover:bg-red-600' 
                  : 'bg-gray-200 text-gray-400 cursor-not-allowed'
              }`}
            >
              {isLive ? 'Going Live...' : 'Start Live Stream'}
            </button>
          </div>
        </div>
      </div>
    );
  };

  const LiveViewer = () => {
    if (!selectedStream) return null;

    return (
      <div className="fixed inset-0 bg-black z-50">
        {/* Video area */}
        <div className="relative h-full">
          <ImageWithFallback
            src={selectedStream.thumbnail}
            alt={selectedStream.title}
            className="w-full h-full object-cover"
          />
          
          {/* Live controls overlay */}
          <div className="absolute top-4 left-4 right-4 flex justify-between items-start">
            <div className="flex items-center space-x-3">
              <div className="bg-red-500 text-white px-3 py-1 rounded-full text-sm font-medium flex items-center">
                <div className="w-2 h-2 bg-white rounded-full mr-2 animate-pulse"></div>
                LIVE
              </div>
              <div className="bg-black bg-opacity-60 text-white px-3 py-1 rounded-full text-sm flex items-center">
                <Eye size={14} className="mr-1" />
                {selectedStream.viewers}
              </div>
            </div>
            
            <button 
              onClick={() => setSelectedStream(null)}
              className="bg-black bg-opacity-60 text-white p-2 rounded-full"
            >
              ✕
            </button>
          </div>
          
          {/* Bottom info */}
          <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-4">
            <div className="flex items-center space-x-3 mb-4">
              <ImageWithFallback
                src={selectedStream.avatar}
                alt={selectedStream.streamer}
                className="w-10 h-10 rounded-full object-cover"
              />
              <div>
                <h3 className="text-white font-semibold">{selectedStream.streamer}</h3>
                <p className="text-gray-300 text-sm">{selectedStream.title}</p>
              </div>
            </div>
            
            {/* Action buttons */}
            <div className="flex items-center space-x-4">
              <button className="flex items-center space-x-2 bg-white bg-opacity-20 text-white px-4 py-2 rounded-full">
                <Heart size={16} />
                <span className="text-sm">Like</span>
              </button>
              <button className="flex items-center space-x-2 bg-white bg-opacity-20 text-white px-4 py-2 rounded-full">
                <MessageCircle size={16} />
                <span className="text-sm">Chat</span>
              </button>
              <button className="flex items-center space-x-2 bg-white bg-opacity-20 text-white px-4 py-2 rounded-full">
                <Gift size={16} />
                <span className="text-sm">Gift</span>
              </button>
              <button className="flex items-center space-x-2 bg-white bg-opacity-20 text-white px-4 py-2 rounded-full">
                <Share2 size={16} />
                <span className="text-sm">Share</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  };

  return (
    <>
      <GoLiveModal />
      <LiveViewer />
      
      <div className="pb-16">
        {/* Go Live Section */}
        <div className="bg-gradient-to-r from-red-500 to-pink-500 p-6 text-white">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <ImageWithFallback
                src={userAvatar}
                alt="Your avatar"
                className="w-12 h-12 rounded-full object-cover border-2 border-white"
              />
              <div>
                <h2 className="font-semibold">Ready to go live?</h2>
                <p className="text-red-100 text-sm">Share your dating story with the world</p>
              </div>
            </div>
            <button 
              onClick={() => setShowGoLiveModal(true)}
              className="bg-white text-red-500 px-6 py-3 rounded-full font-medium flex items-center space-x-2 hover:bg-red-50 transition-colors"
            >
              <Video size={18} />
              <span>Go Live</span>
            </button>
          </div>
        </div>

        {/* Category Tabs */}
        <div className="bg-white border-b border-gray-100">
          <div className="flex items-center px-4 overflow-x-auto scrollbar-hide">
            {liveCategories.map((category) => {
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

        {/* Live Stats */}
        <div className="bg-white border-b border-gray-100 px-4 py-3">
          <div className="flex items-center justify-between text-sm text-gray-600">
            <span>🔴 {filteredStreams.length} live streams</span>
            <span>👀 {filteredStreams.reduce((total, stream) => total + parseFloat(stream.viewers.replace('K', '')) * 1000, 0).toLocaleString()} total viewers</span>
          </div>
        </div>

        {/* Live Streams Grid */}
        <div className="p-4">
          {filteredStreams.length === 0 ? (
            <div className="text-center py-16">
              <Video size={48} className="text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-semibold text-gray-900 mb-2">No Live Streams</h3>
              <p className="text-gray-600 mb-6">No one is streaming in this category right now.</p>
              <button 
                onClick={() => setShowGoLiveModal(true)}
                className="bg-red-500 text-white px-6 py-3 rounded-full font-medium hover:bg-red-600 transition-colors"
              >
                Be the First to Go Live
              </button>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {filteredStreams.map((stream) => (
                <LiveStreamCard key={stream.id} stream={stream} />
              ))}
            </div>
          )}
        </div>

        {/* Trending Live Topics */}
        <div className="bg-white m-4 rounded-lg p-4">
          <h3 className="font-semibold text-gray-900 mb-4">Trending Live Topics</h3>
          <div className="flex flex-wrap gap-2">
            {['#FirstDateTips', '#RedFlags', '#LongDistance', '#OnlineDating', '#RelationshipGoals'].map((topic) => (
              <span key={topic} className="bg-orange-100 text-orange-600 px-3 py-1 rounded-full text-sm">
                {topic}
              </span>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}