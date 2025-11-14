import React from 'react';
import { Home, User, MessageCircle, X } from 'lucide-react';

interface NavigationWidgetProps {
  isOpen: boolean;
  onClose: () => void;
  currentTab: string;
  onNavigate: (tab: string) => void;
}

export function NavigationWidget({ isOpen, onClose, currentTab, onNavigate }: NavigationWidgetProps) {
  if (!isOpen) return null;

  const navigationItems = [
    {
      id: 'home',
      label: 'Home',
      icon: Home,
      description: 'Main feed'
    },
    {
      id: 'profile',
      label: 'Profile',
      icon: User,
      description: 'Your profile'
    },
    {
      id: 'messages',
      label: 'Messages',
      icon: MessageCircle,
      description: 'Conversations'
    }
  ];

  const handleNavigate = (tabId: string) => {
    onNavigate(tabId);
    onClose();
  };

  return (
    <div 
      className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center"
      onClick={onClose}
    >
      <div 
        className="bg-white rounded-2xl p-6 m-4 w-full max-w-sm"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-semibold text-gray-900">Quick Navigation</h3>
          <button 
            onClick={onClose}
            className="p-1 rounded-full hover:bg-gray-100 transition-colors"
          >
            <X size={20} className="text-gray-600" />
          </button>
        </div>

        {/* Navigation Options */}
        <div className="space-y-3">
          {navigationItems.map((item) => {
            const Icon = item.icon;
            const isActive = currentTab === item.id;
            
            return (
              <button
                key={item.id}
                onClick={() => handleNavigate(item.id)}
                className={`w-full flex items-center space-x-4 p-4 rounded-xl transition-all ${
                  isActive 
                    ? 'bg-orange-50 border-2 border-orange-200' 
                    : 'bg-gray-50 hover:bg-gray-100 border-2 border-transparent'
                }`}
              >
                <div className={`p-2 rounded-lg ${
                  isActive ? 'bg-orange-400 text-white' : 'bg-gray-200 text-gray-600'
                }`}>
                  <Icon size={20} />
                </div>
                
                <div className="flex-1 text-left">
                  <p className={`font-medium ${isActive ? 'text-orange-600' : 'text-gray-900'}`}>
                    {item.label}
                  </p>
                  <p className="text-sm text-gray-600">{item.description}</p>
                </div>
                
                {isActive && (
                  <div className="w-2 h-2 bg-orange-400 rounded-full"></div>
                )}
              </button>
            );
          })}
        </div>

        {/* Footer */}
        <div className="mt-6 pt-4 border-t border-gray-100">
          <p className="text-xs text-gray-500 text-center">
            Tap anywhere outside to close
          </p>
        </div>
      </div>
    </div>
  );
}