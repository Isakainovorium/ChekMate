import React, { useState, useEffect, useCallback, memo } from 'react';
import { MapPin, Search, Navigation, X, Check, AlertCircle } from 'lucide-react';

interface Location {
  lat: number;
  lng: number;
  address: string;
  city: string;
  state: string;
}

interface LocationSelectorProps {
  isOpen: boolean;
  onClose: () => void;
  onLocationSelect: (location: Location) => void;
  currentLocation?: Location;
  radiusMiles?: number;
  onRadiusChange?: (radius: number) => void;
}

// Mock map component since we can't use external mapping libraries
const MapComponent = ({ 
  center, 
  onLocationSelect, 
  radius 
}: { 
  center: Location; 
  onLocationSelect: (location: Location) => void;
  radius: number;
}) => {
  const [isDragging, setIsDragging] = useState(false);
  const [markerPosition, setMarkerPosition] = useState({ x: 50, y: 50 }); // Center of map

  const handleMapClick = useCallback((e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = ((e.clientX - rect.left) / rect.width) * 100;
    const y = ((e.clientY - rect.top) / rect.height) * 100;
    
    setMarkerPosition({ x, y });
    
    // Convert click position to approximate lat/lng (mock calculation)
    const lat = center.lat + (50 - y) * 0.01; // Mock conversion
    const lng = center.lng + (x - 50) * 0.01; // Mock conversion
    
    // Reverse geocode to get address (mock)
    const mockAddress = `${Math.floor(Math.random() * 9999)} Main St`;
    const mockCity = ['Downtown', 'Midtown', 'Uptown', 'Central'][Math.floor(Math.random() * 4)];
    
    onLocationSelect({
      lat,
      lng,
      address: mockAddress,
      city: mockCity,
      state: 'CA'
    });
  }, [center, onLocationSelect]);

  return (
    <div 
      className="relative w-full h-full bg-gradient-to-br from-green-100 to-blue-100 rounded-lg overflow-hidden cursor-crosshair"
      onClick={handleMapClick}
    >
      {/* Mock map background with streets */}
      <svg className="absolute inset-0 w-full h-full" viewBox="0 0 100 100" preserveAspectRatio="none">
        {/* Mock street lines */}
        <line x1="0" y1="25" x2="100" y2="25" stroke="#cbd5e1" strokeWidth="0.5" />
        <line x1="0" y1="50" x2="100" y2="50" stroke="#cbd5e1" strokeWidth="0.8" />
        <line x1="0" y1="75" x2="100" y2="75" stroke="#cbd5e1" strokeWidth="0.5" />
        <line x1="25" y1="0" x2="25" y2="100" stroke="#cbd5e1" strokeWidth="0.5" />
        <line x1="50" y1="0" x2="50" y2="100" stroke="#cbd5e1" strokeWidth="0.8" />
        <line x1="75" y1="0" x2="75" y2="100" stroke="#cbd5e1" strokeWidth="0.5" />
        
        {/* Radius circle */}
        <circle 
          cx={markerPosition.x} 
          cy={markerPosition.y} 
          r={Math.min(radius * 0.8, 40)} 
          fill="rgba(249, 115, 22, 0.15)" 
          stroke="#f97316" 
          strokeWidth="0.4"
          strokeDasharray="3,2"
          className="animate-pulse"
        />
        
        {/* Inner radius circle for better visibility */}
        <circle 
          cx={markerPosition.x} 
          cy={markerPosition.y} 
          r={Math.min(radius * 0.5, 25)} 
          fill="rgba(249, 115, 22, 0.05)" 
          stroke="#f97316" 
          strokeWidth="0.2"
          strokeDasharray="1,1"
        />
      </svg>
      
      {/* Location marker */}
      <div 
        className="absolute transform -translate-x-1/2 -translate-y-full z-10 transition-all duration-200"
        style={{ 
          left: `${markerPosition.x}%`, 
          top: `${markerPosition.y}%`,
          filter: 'drop-shadow(0 2px 4px rgba(0,0,0,0.3))'
        }}
      >
        <MapPin size={32} className="text-orange-500 fill-current" />
      </div>
      
      {/* Mock buildings/landmarks */}
      <div className="absolute top-4 left-4 w-3 h-3 bg-gray-400 rounded opacity-60"></div>
      <div className="absolute top-6 right-8 w-2 h-4 bg-gray-500 rounded opacity-60"></div>
      <div className="absolute bottom-8 left-12 w-4 h-2 bg-gray-400 rounded opacity-60"></div>
      <div className="absolute bottom-4 right-4 w-3 h-3 bg-green-600 rounded-full opacity-60"></div>
    </div>
  );
};

// Custom CSS for the slider
const sliderStyles = `
  .slider::-webkit-slider-thumb {
    appearance: none;
    height: 18px;
    width: 18px;
    border-radius: 50%;
    background: #f97316;
    cursor: pointer;
    border: 2px solid #fff;
    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
  }
  
  .slider::-moz-range-thumb {
    height: 18px;
    width: 18px;
    border-radius: 50%;
    background: #f97316;
    cursor: pointer;
    border: 2px solid #fff;
    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
  }
`;

export const LocationSelector = memo(function LocationSelector({ 
  isOpen, 
  onClose, 
  onLocationSelect, 
  currentLocation,
  radiusMiles = 50,
  onRadiusChange
}: LocationSelectorProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedLocation, setSelectedLocation] = useState<Location>(
    currentLocation || {
      lat: 34.0522,
      lng: -118.2437,
      address: 'Los Angeles',
      city: 'Los Angeles',
      state: 'CA'
    }
  );
  const [isGettingLocation, setIsGettingLocation] = useState(false);
  const [locationError, setLocationError] = useState<string | null>(null);
  const [searchResults, setSearchResults] = useState<Location[]>([]);
  const [currentRadiusMiles, setRadiusMiles] = useState(radiusMiles);

  // Mock search results
  const mockSearchResults = [
    { lat: 34.0522, lng: -118.2437, address: '123 Hollywood Blvd', city: 'Hollywood', state: 'CA' },
    { lat: 34.0928, lng: -118.3287, address: '456 Sunset Strip', city: 'West Hollywood', state: 'CA' },
    { lat: 33.9425, lng: -118.4081, address: '789 Manhattan Beach Blvd', city: 'Manhattan Beach', state: 'CA' },
    { lat: 34.1478, lng: -118.1445, address: '321 Colorado Blvd', city: 'Pasadena', state: 'CA' },
    { lat: 33.8358, lng: -118.2773, address: '654 Redondo Beach Blvd', city: 'Redondo Beach', state: 'CA' }
  ];

  useEffect(() => {
    if (searchQuery.length > 2) {
      // Mock search delay
      const timer = setTimeout(() => {
        const filtered = mockSearchResults.filter(location =>
          location.address.toLowerCase().includes(searchQuery.toLowerCase()) ||
          location.city.toLowerCase().includes(searchQuery.toLowerCase())
        );
        setSearchResults(filtered);
      }, 300);

      return () => clearTimeout(timer);
    } else {
      setSearchResults([]);
    }
  }, [searchQuery]);

  const getCurrentLocation = useCallback(() => {
    setIsGettingLocation(true);
    setLocationError(null);

    if ('geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          
          // Mock reverse geocoding
          const mockLocation: Location = {
            lat: latitude,
            lng: longitude,
            address: 'Current Location',
            city: 'Your City',
            state: 'CA'
          };
          
          setSelectedLocation(mockLocation);
          setIsGettingLocation(false);
        },
        (error) => {
          setLocationError('Unable to get your location. Please search manually.');
          setIsGettingLocation(false);
        },
        {
          timeout: 10000,
          enableHighAccuracy: true
        }
      );
    } else {
      setLocationError('Geolocation is not supported by this browser.');
      setIsGettingLocation(false);
    }
  }, []);

  const handleLocationSelect = (location: Location) => {
    setSelectedLocation(location);
    setSearchResults([]);
    setSearchQuery('');
  };

  const handleConfirm = () => {
    onLocationSelect(selectedLocation);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <>
      <style dangerouslySetInnerHTML={{ __html: sliderStyles }} />
      <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl w-full max-w-4xl h-[90vh] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b border-gray-200">
          <h2 className="text-xl font-semibold text-gray-900">Select Location</h2>
          <button 
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-full transition-colors"
          >
            <X size={20} className="text-gray-600" />
          </button>
        </div>

        {/* Search Bar */}
        <div className="p-4 border-b border-gray-100">
          <div className="relative">
            <Search size={20} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder="Search for an address or place..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-lg focus:ring-2 focus:ring-orange-200 focus:border-orange-400 transition-colors"
            />
          </div>

          {/* Current Location Button */}
          <button
            onClick={getCurrentLocation}
            disabled={isGettingLocation}
            className="mt-3 flex items-center space-x-2 px-4 py-2 bg-orange-50 text-orange-600 rounded-lg hover:bg-orange-100 transition-colors disabled:opacity-50"
          >
            <Navigation size={16} />
            <span>{isGettingLocation ? 'Getting location...' : 'Use current location'}</span>
          </button>

          {/* Location Error */}
          {locationError && (
            <div className="mt-3 flex items-center space-x-2 p-3 bg-red-50 text-red-600 rounded-lg">
              <AlertCircle size={16} />
              <span className="text-sm">{locationError}</span>
            </div>
          )}
        </div>

        {/* Main Content */}
        <div className="flex-1 flex overflow-hidden">
          {/* Search Results / Map Controls */}
          <div className="w-80 border-r border-gray-200 flex flex-col">
            {searchResults.length > 0 ? (
              <div className="flex-1 overflow-y-auto">
                <div className="p-2">
                  <h3 className="text-sm font-medium text-gray-700 mb-2">Search Results</h3>
                  {searchResults.map((location, index) => (
                    <button
                      key={index}
                      onClick={() => handleLocationSelect(location)}
                      className="w-full text-left p-3 hover:bg-gray-50 rounded-lg transition-colors mb-1"
                    >
                      <div className="flex items-start space-x-3">
                        <MapPin size={16} className="text-gray-400 mt-1 flex-shrink-0" />
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium text-gray-900 truncate">
                            {location.address}
                          </p>
                          <p className="text-xs text-gray-600">
                            {location.city}, {location.state}
                          </p>
                        </div>
                      </div>
                    </button>
                  ))}
                </div>
              </div>
            ) : (
              <div className="p-4">
                <h3 className="text-sm font-medium text-gray-700 mb-4">Map Controls</h3>
                
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-600 mb-2">
                      Search Radius
                    </label>
                    <div className="flex items-center space-x-3">
                      <input
                        type="range"
                        min="5"
                        max="100"
                        value={currentRadiusMiles}
                        onChange={(e) => {
                          const newRadius = parseInt(e.target.value);
                          setRadiusMiles(newRadius);
                          onRadiusChange?.(newRadius);
                        }}
                        className="flex-1 accent-orange-500 h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer slider"
                      />
                      <span className="text-sm text-gray-600 font-medium w-16 bg-orange-50 px-2 py-1 rounded text-center">
                        {currentRadiusMiles} mi
                      </span>
                    </div>
                    <div className="flex justify-between text-xs text-gray-400 mt-1">
                      <span>5 mi</span>
                      <span>100 mi</span>
                    </div>
                  </div>

                  <div className="space-y-3">
                    <div className="p-3 bg-orange-50 rounded-lg">
                      <h4 className="text-sm font-medium text-orange-800 mb-1">How to use:</h4>
                      <ul className="text-xs text-orange-700 space-y-1">
                        <li>• Click anywhere on the map to set location</li>
                        <li>• Search for specific addresses above</li>
                        <li>• Use current location for GPS accuracy</li>
                        <li>• Adjust radius to expand/narrow your search area</li>
                      </ul>
                    </div>
                    
                    <div className="p-3 bg-blue-50 rounded-lg">
                      <h4 className="text-sm font-medium text-blue-800 mb-1">Dating Tips:</h4>
                      <p className="text-xs text-blue-700">
                        {currentRadiusMiles <= 25 
                          ? "Perfect for local dates and nearby connections!"
                          : currentRadiusMiles <= 50
                          ? "Good balance between options and travel distance."
                          : "Wide search area - great for finding more matches!"
                        }
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Map */}
          <div className="flex-1 p-4">
            <div className="w-full h-full border border-gray-200 rounded-lg overflow-hidden">
              <MapComponent
                center={selectedLocation}
                onLocationSelect={handleLocationSelect}
                radius={currentRadiusMiles}
              />
            </div>
          </div>
        </div>

        {/* Selected Location & Actions */}
        <div className="border-t border-gray-200 p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <MapPin size={20} className="text-orange-500" />
              <div>
                <p className="font-medium text-gray-900">
                  {selectedLocation.address}
                </p>
                <p className="text-sm text-gray-600">
                  {selectedLocation.city}, {selectedLocation.state}
                </p>
                <p className="text-xs text-orange-600">
                  {currentRadiusMiles} mile radius for date matches
                </p>
              </div>
            </div>
            
            <div className="flex space-x-3">
              <button
                onClick={onClose}
                className="px-6 py-2 border border-gray-200 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleConfirm}
                className="px-6 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors flex items-center space-x-2"
              >
                <Check size={16} />
                <span>Confirm Location</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    </>
  );
});