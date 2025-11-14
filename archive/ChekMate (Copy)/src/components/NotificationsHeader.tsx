import React from 'react';
import { ChevronDown } from 'lucide-react';
import exampleImage from 'figma:asset/ba52b933cb7c6a57f4931dec59fb62ba400afc37.png';

export function NotificationsHeader() {
  return (
    <div className="bg-white relative overflow-hidden">
      {/* Orange circle decoration */}
      <div className="absolute -top-16 -left-16 w-32 h-32 bg-orange-400 rounded-full"></div>
      
      <div className="relative z-10 px-4 py-6">
        {/* ChekMate logo */}
        <div className="text-center mb-2">

        </div>
        
        {/* Title */}
        <h1 className="text-center text-gray-900 mb-6">Activity and Notifications</h1>
        
        {/* Filter controls */}
        <div className="flex items-center justify-between">
          <span className="text-gray-900 font-medium">Newest</span>
          
          <button className="flex items-center space-x-1 text-gray-700">
            <span>Sort by time</span>
            <ChevronDown size={16} />
          </button>
        </div>
      </div>
    </div>
  );
}