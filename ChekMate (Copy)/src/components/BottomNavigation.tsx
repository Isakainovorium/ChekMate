import React from 'react';
import { Home, MessageCircle, Plus, Bell, User } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

const profileAvatar = 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral';

interface BottomNavigationProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

export function BottomNavigation({ activeTab, onTabChange }: BottomNavigationProps) {

  const navItems = [
    { id: 'home', icon: Home, label: 'Home' },
    { id: 'messages', icon: MessageCircle, label: 'Messages' },
    { id: 'create', icon: Plus, label: 'Create', isSpecial: true },
    { id: 'notifications', icon: Bell, label: 'Notifications' },
    { id: 'profile', icon: null, label: 'Profile', isProfile: true }
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-50">
      <div className="flex items-center justify-around py-2">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;
          
          return (
            <button
              key={item.id}
              onClick={() => onTabChange(item.id)}
              className={`flex flex-col items-center p-2 ${
                item.isSpecial 
                  ? 'bg-orange-500 rounded-full p-3' 
                  : ''
              }`}
            >
              {item.isProfile ? (
                <ImageWithFallback
                  src={profileAvatar}
                  alt="Profile"
                  className={`w-6 h-6 rounded-full object-cover ${
                    isActive ? 'ring-2 ring-orange-500' : ''
                  }`}
                />
              ) : Icon ? (
                <Icon 
                  size={24} 
                  className={`${
                    item.isSpecial 
                      ? 'text-white' 
                      : isActive 
                        ? 'text-orange-500' 
                        : 'text-gray-600'
                  }`} 
                />
              ) : null}
            </button>
          );
        })}
      </div>
    </div>
  );
}