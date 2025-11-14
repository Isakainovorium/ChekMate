import React, { useState, useEffect } from 'react';
import { Search } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import logoAsset from 'figma:asset/13d8efac0497e8c6a71b700bb948b9e4a1c20a9a.png';

export function Header() {
  const [isVisible, setIsVisible] = useState(true);
  const [lastScrollY, setLastScrollY] = useState(0);

  useEffect(() => {
    const handleScroll = () => {
      const currentScrollY = window.scrollY;
      
      if (currentScrollY > lastScrollY && currentScrollY > 100) {
        // Scrolling down & past threshold
        setIsVisible(false);
      } else {
        // Scrolling up or at top
        setIsVisible(true);
      }
      
      setLastScrollY(currentScrollY);
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, [lastScrollY]);

  return (
    <div 
      className={`sticky top-0 bg-white z-50 border-b border-gray-100 transition-transform duration-300 ease-in-out ${
        isVisible ? 'translate-y-0' : '-translate-y-full'
      }`}
    >
      <div className="flex items-center justify-between px-3 py-1">
        <div className="flex items-center">
          <h1 className="text-2xl font-bold text-gray-900">ChekMate</h1>
        </div>
        
        <div className="flex-1 max-w-sm mx-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={16} />
            <input
              type="text"
              placeholder="Search here ..."
              className="w-full pl-9 pr-3 py-1.5 bg-gray-50 rounded-full border-none outline-none focus:ring-2 focus:ring-orange-200 text-sm"
            />
          </div>
        </div>
      </div>
    </div>
  );
}