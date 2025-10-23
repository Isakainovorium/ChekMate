import React from 'react';
import { Menu, ChevronDown, Search, MapPin } from 'lucide-react';
import exampleImage from 'figma:asset/49f4bd882be9093f82b59422be3a53490ec0b501.png';

interface Location {
  lat: number;
  lng: number;
  address: string;
  city: string;
  state: string;
}

interface RateYourDateHeaderProps {
  onShowWidget?: () => void;
  onLocationClick?: () => void;
  selectedLocation?: Location | null;
}

export function RateYourDateHeader({ onShowWidget, onLocationClick, selectedLocation }: RateYourDateHeaderProps) {
  return (
    <div className="bg-white">
      {/* Top Header */}
      <div className="flex items-center justify-between px-4 py-3">
        <button onClick={onShowWidget} className="p-1 rounded-lg hover:bg-gray-100 transition-colors">
          <Menu size={24} className="text-gray-700" />
        </button>
        
        <button onClick={onLocationClick} className="flex items-center space-x-2 px-3 py-2 rounded-lg hover:bg-gray-100 transition-colors max-w-48">
          <MapPin size={16} className="text-orange-500 flex-shrink-0" />
          <span className="text-gray-700 truncate">
            {selectedLocation 
              ? `${selectedLocation.city}, ${selectedLocation.state}` 
              : 'Select Location'
            }
          </span>
          <ChevronDown size={20} className="text-gray-700 flex-shrink-0" />
        </button>
        
        <div className="w-10 h-10"></div>
      </div>
      
      {/* Title */}
      <div className="text-center py-4">
        <h1 className="text-2xl font-bold text-gray-900">RATE YOUR DATE</h1>
      </div>
      
      {/* Search Bar */}
      <div className="px-4 pb-4">
        <div className="relative flex items-center">
          <div className="w-10 h-10 bg-orange-400 rounded-full flex items-center justify-center mr-3">
            <div className="w-6 h-6 bg-orange-200 rounded-full"></div>
          </div>
          <div className="flex-1 relative">
            <input
              type="text"
              placeholder="Search your favorite food..."
              className="w-full pl-4 pr-12 py-3 bg-gray-100 rounded-full outline-none focus:ring-2 focus:ring-orange-200"
            />
            <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
              <Search size={20} className="text-gray-600" />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}