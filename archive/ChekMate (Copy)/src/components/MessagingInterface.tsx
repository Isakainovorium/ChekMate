import React, { useState, useRef, useEffect } from 'react';
import { X, Camera, Mic } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { ConversationInputBar } from './ConversationInputBar';

interface Message {
  id: string;
  text: string;
  timestamp: string;
  isOwn: boolean;
}

interface MessagingInterfaceProps {
  isOpen: boolean;
  onClose: () => void;
  recipient: {
    name: string;
    username: string;
    avatar: string;
  };
}

export function MessagingInterface({ isOpen, onClose, recipient }: MessagingInterfaceProps) {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      text: 'Hey! I saw your latest video, it was amazing! 😍',
      timestamp: '2h ago',
      isOwn: false
    },
    {
      id: '2', 
      text: 'Thank you so much! I really appreciate that 💕',
      timestamp: '2h ago',
      isOwn: true
    },
    {
      id: '3',
      text: 'The way you told that story was so engaging. I was on the edge of my seat the whole time!',
      timestamp: '1h ago',
      isOwn: false
    },
    {
      id: '4',
      text: 'That means the world to me! I put a lot of effort into making it compelling',
      timestamp: '1h ago',
      isOwn: true
    }
  ]);
  
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = (messageText: string) => {
    const message: Message = {
      id: Date.now().toString(),
      text: messageText,
      timestamp: 'Just now',
      isOwn: true
    };
    setMessages([...messages, message]);
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-white z-50 flex flex-col">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 px-4 py-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <button onClick={onClose}>
              <X size={24} className="text-gray-700" />
            </button>
            <ImageWithFallback
              src={recipient.avatar}
              alt={recipient.name}
              className="w-10 h-10 rounded-full object-cover"
            />
            <div>
              <h3 className="font-semibold text-gray-900">{recipient.name}</h3>
              <p className="text-sm text-gray-600">{recipient.username}</p>
            </div>
          </div>
          
          <div className="flex items-center space-x-3">
            <button className="p-2">
              <Camera size={20} className="text-gray-600" />
            </button>
            <button className="p-2">
              <Mic size={20} className="text-gray-600" />
            </button>
          </div>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((message) => (
          <div key={message.id} className={`flex ${message.isOwn ? 'justify-end' : 'justify-start'}`}>
            <div className={`max-w-xs lg:max-w-md px-4 py-2 rounded-2xl ${
              message.isOwn 
                ? 'bg-orange-400 text-white' 
                : 'bg-gray-100 text-gray-900'
            }`}>
              <p className="text-sm">{message.text}</p>
              <p className={`text-xs mt-1 ${
                message.isOwn ? 'text-orange-100' : 'text-gray-500'
              }`}>
                {message.timestamp}
              </p>
            </div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      {/* Simple Message Input */}
      <div className="bg-white border-t border-gray-200 p-4">
        <div className="flex items-center space-x-3">
          <div className="flex-1">
            <input
              type="text"
              placeholder={`Message ${recipient.name}...`}
              className="w-full px-4 py-3 bg-gray-100 rounded-full border-none outline-none focus:ring-2 focus:ring-orange-200"
              onKeyPress={(e) => {
                if (e.key === 'Enter' && e.currentTarget.value.trim()) {
                  handleSendMessage(e.currentTarget.value);
                  e.currentTarget.value = '';
                }
              }}
            />
          </div>
          <button 
            onClick={() => {
              const input = document.querySelector('input[placeholder*="Message"]') as HTMLInputElement;
              if (input && input.value.trim()) {
                handleSendMessage(input.value);
                input.value = '';
              }
            }}
            className="p-3 bg-orange-400 text-white rounded-full hover:bg-orange-500 transition-colors"
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
              <path d="M2 21l21-9L2 3v7l15 2-15 2v7z" fill="currentColor"/>
            </svg>
          </button>
        </div>
      </div>
    </div>
  );
}