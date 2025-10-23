import React from 'react';

const tabs = [
  'For you',
  'Following', 
  'Explore',
  'Live',
  'Rate Date',
  'Subscribe'
];

interface NavigationTabsProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

export function NavigationTabs({ activeTab, onTabChange }: NavigationTabsProps) {

  return (
    <div className="bg-white border-b border-gray-100">
      <div className="flex items-center px-4 overflow-x-auto scrollbar-hide">
        {tabs.map((tab) => (
          <button
            key={tab}
            onClick={() => onTabChange(tab)}
            className={`px-4 py-3 whitespace-nowrap transition-colors ${
              activeTab === tab
                ? 'text-orange-500 border-b-2 border-orange-500'
                : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            {tab}
          </button>
        ))}
      </div>
    </div>
  );
}