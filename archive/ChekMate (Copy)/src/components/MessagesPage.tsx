import React, { useState } from 'react';
import { Search, Plus, MoreHorizontal } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { BottomNavigation } from './BottomNavigation';
import { MessagingInterface } from './MessagingInterface';

interface Conversation {
  id: string;
  name: string;
  username: string;
  avatar: string;
  lastMessage: string;
  timestamp: string;
  unread: boolean;
  online?: boolean;
}

interface MessagesPageProps {
  bottomNavTab: string;
  onBottomNavChange: (tab: string) => void;
  onConversationOpen?: () => void;
  onConversationClose?: () => void;
  isInConversation?: boolean;
}

const mockConversations: Conversation[] = [
  {
    id: '1',
    name: 'Simone Gabrielle',
    username: '@thatgurlmone',
    avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    lastMessage: 'That means the world to me! I put a lot of effort into making it compelling',
    timestamp: '1h ago',
    unread: false,
    online: true
  },
  {
    id: '2',
    name: 'Jessica M',
    username: '@jessicam',
    avatar: 'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2Zlc3Npb25hbCUyMGhlYWRzaG90fGVufDF8fHx8MTc1OTczMDU0M3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    lastMessage: 'Hey! Did you see the latest drama? 👀',
    timestamp: '2h ago',
    unread: true,
    online: false
  },
  {
    id: '3',
    name: 'Mike D',
    username: '@miked_official',
    avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NTk3MTMyNTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    lastMessage: 'Thanks for the advice on cooking dates!',
    timestamp: '5h ago',
    unread: false,
    online: true
  },
  {
    id: '4',
    name: 'Sarah J',
    username: '@sarahj_stories',
    avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    lastMessage: 'Coffee tomorrow?',
    timestamp: 'Yesterday',
    unread: true,
    online: false
  }
];

export function MessagesPage({ bottomNavTab, onBottomNavChange, onConversationOpen, onConversationClose, isInConversation = false }: MessagesPageProps) {
  const [selectedConversation, setSelectedConversation] = useState<Conversation | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  const filteredConversations = mockConversations.filter(conversation =>
    conversation.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    conversation.username.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <>
      {selectedConversation && (
        <MessagingInterface
          isOpen={!!selectedConversation}
          onClose={() => {
            setSelectedConversation(null);
            onConversationClose?.();
          }}
          recipient={selectedConversation}
        />
      )}
      
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white border-b border-gray-200 px-4 py-4">
          <div className="flex items-center justify-between mb-4">
            <h1 className="text-2xl font-bold text-gray-900">Messages</h1>
            <div className="flex items-center space-x-3">
              <button className="p-2 rounded-full hover:bg-gray-100">
                <Plus size={20} className="text-gray-600" />
              </button>
              <button className="p-2 rounded-full hover:bg-gray-100">
                <MoreHorizontal size={20} className="text-gray-600" />
              </button>
            </div>
          </div>

          {/* Search */}
          <div className="relative">
            <Search size={20} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search conversations..."
              className="w-full pl-10 pr-4 py-3 bg-gray-100 rounded-full border-none outline-none focus:ring-2 focus:ring-orange-200"
            />
          </div>
        </div>

        {/* Conversations List */}
        <div className="pb-20">
          {filteredConversations.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16">
              <div className="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                <MessageCircle size={32} className="text-gray-400" />
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-2">No conversations found</h3>
              <p className="text-gray-600 text-center">
                {searchQuery ? 'Try a different search term' : 'Start a new conversation'}
              </p>
            </div>
          ) : (
            <div className="divide-y divide-gray-100">
              {filteredConversations.map((conversation) => (
                <button
                  key={conversation.id}
                  onClick={() => {
                    setSelectedConversation(conversation);
                    onConversationOpen?.();
                  }}
                  className="w-full flex items-center px-4 py-4 hover:bg-gray-50 transition-colors"
                >
                  {/* Avatar with online indicator */}
                  <div className="relative mr-3">
                    <ImageWithFallback
                      src={conversation.avatar}
                      alt={conversation.name}
                      className="w-14 h-14 rounded-full object-cover"
                    />
                    {conversation.online && (
                      <div className="absolute bottom-0 right-0 w-4 h-4 bg-green-400 rounded-full border-2 border-white"></div>
                    )}
                  </div>

                  {/* Content */}
                  <div className="flex-1 min-w-0 text-left">
                    <div className="flex items-center justify-between mb-1">
                      <h3 className="font-semibold text-gray-900 truncate">{conversation.name}</h3>
                      <span className="text-xs text-gray-500 ml-2">{conversation.timestamp}</span>
                    </div>
                    
                    <p className="text-sm text-gray-600 truncate mb-1">{conversation.username}</p>
                    
                    <p className={`text-sm truncate ${
                      conversation.unread ? 'font-medium text-gray-900' : 'text-gray-600'
                    }`}>
                      {conversation.lastMessage}
                    </p>
                  </div>

                  {/* Unread indicator */}
                  {conversation.unread && (
                    <div className="w-3 h-3 bg-orange-400 rounded-full ml-3"></div>
                  )}
                </button>
              ))}
            </div>
          )}
        </div>

        <BottomNavigation activeTab={bottomNavTab} onTabChange={onBottomNavChange} hideNavigation={isInConversation} onCreateClick={() => {}} />
      </div>
    </>
  );
}