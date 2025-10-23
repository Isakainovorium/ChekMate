import React, { useState } from 'react';
import { RateYourDateHeader } from './RateYourDateHeader';
import { ProfileCard } from './ProfileCard';
import { FlippableProfileCard } from './FlippableProfileCard';
import { LocationSelector } from './LocationSelector';

const profiles = [
  {
    id: '1',
    name: 'John',
    avatar: 'https://images.unsplash.com/photo-1758639842438-718755aa57e4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMG1hbiUyMHBvcnRyYWl0JTIwcHJvZmVzc2lvbmFsJTIwaGVhZHNob3R8ZW58MXx8fHwxNzU5NzU1NDE5fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    gender: 'Male',
    years: 2,
    location: '125 Anywhere St., Any City',
    dateStory: 'We went to this cozy Italian restaurant downtown. John was incredibly thoughtful - he remembered I mentioned being vegetarian and had already called ahead to ask about their best veggie options. The conversation flowed naturally, and we ended up talking for 3 hours straight! He walked me to my car and texted to make sure I got home safely.',
    dateLocation: 'Bella Vista Italian Restaurant',
    dateActivity: 'Dinner Date',
    dateRating: 4.2,
    totalRatings: 127,
    wowCount: 89,
    gtfohCount: 12,
    chekmateCount: 26
  },
  {
    id: '2',
    name: 'Pedro',
    avatar: 'https://images.unsplash.com/photo-1758599543154-76ec1c4257df?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwcm9mZXNzaW9uYWwlMjBwb3J0cmFpdCUyMGJlYXJkfGVufDF8fHx8MTc1OTc1NTQyM3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    gender: 'Male',
    years: 3,
    location: '125 Anywhere St., Any City',
    dateStory: 'Pedro planned this amazing hiking date at sunrise. He brought coffee, pastries, and even a blanket for us to sit on at the viewpoint. The views were breathtaking, but honestly, I was more impressed by how prepared and considerate he was. We watched the sunrise together and he shared stories about his travels. Definitely one of the most unique and memorable first dates I\'ve been on!',
    dateLocation: 'Mountain View Trail',
    dateActivity: 'Hiking Adventure',
    dateRating: 4.7,
    totalRatings: 203,
    wowCount: 156,
    gtfohCount: 8,
    chekmateCount: 39
  },
  {
    id: '3',
    name: 'Ben',
    avatar: 'https://images.unsplash.com/photo-1543132220-e7fef0b974e7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMG1hbiUyMGNhc3VhbCUyMHBvcnRyYWl0fGVufDF8fHx8MTc1OTc0MTMzOXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    gender: 'Male',
    years: 2,
    location: '125 Anywhere St., Any City',
    dateStory: 'Ben seemed really nice over text, but in person it was a different story. He showed up 20 minutes late without any apology, spent most of dinner on his phone, and then had the audacity to suggest we split the bill after ordering the most expensive items on the menu. When I politely declined a second date, he got really defensive and rude. Definitely not ChekMate material.',
    dateLocation: 'Downtown Sports Bar',
    dateActivity: 'Casual Drinks',
    dateRating: 1.8,
    totalRatings: 94,
    wowCount: 15,
    gtfohCount: 67,
    chekmateCount: 12
  },
  {
    id: '4',
    name: 'Alex',
    avatar: 'https://images.unsplash.com/photo-1656313826909-1f89d1702a81?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxibGFjayUyMG1hbiUyMHByb2Zlc3Npb25hbCUyMHBvcnRyYWl0fGVufDF8fHx8MTc1OTc1NTQyOHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    gender: 'Male',
    years: 3,
    location: '125 Anywhere St., Any City',
    dateStory: 'OMG where do I even start?! Alex planned the most incredible surprise date. He picked me up in a classic convertible and drove us to this secret rooftop garden in the city. There was a private dinner setup with string lights, my favorite flowers, and a playlist of songs we both loved. We danced under the stars and talked until 2am. This man is HUSBAND MATERIAL! 💍',
    dateLocation: 'Secret Rooftop Garden',
    dateActivity: 'Surprise Romantic Evening',
    dateRating: 4.9,
    totalRatings: 312,
    wowCount: 98,
    gtfohCount: 3,
    chekmateCount: 211
  },
  {
    id: '5',
    name: 'Robert',
    avatar: 'https://images.unsplash.com/photo-1758639842438-718755aa57e4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMG1hbiUyMHBvcnRyYWl0JTIwcHJvZmVzc2lvbmFsJTIwaGVhZHNob3R8ZW58MXx8fHwxNzU5NzU1NDE5fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    gender: 'Male',
    years: 2,
    location: '125 Anywhere St., Any City',
    dateStory: 'Robert took me to a local art gallery opening, which was actually really cool! He was knowledgeable about art and had interesting perspectives on the pieces. We grabbed coffee afterward and had great conversations about creativity, travel, and life goals. He was respectful, engaging, and genuinely seemed interested in getting to know me. A solid first date that left me wanting to see him again.',
    dateLocation: 'Modern Art Gallery & Café',
    dateActivity: 'Cultural Date',
    dateRating: 4.1,
    totalRatings: 156,
    wowCount: 102,
    gtfohCount: 18,
    chekmateCount: 36
  },
  {
    id: '6',
    name: 'Julian',
    avatar: 'https://images.unsplash.com/photo-1758599543154-76ec1c4257df?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwcm9mZXNzaW9uYWwlMjBwb3J0cmFpdCUyMGJlYXJkfGVufDF8fHx8MTc1OTc1NTQyM3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    gender: 'Male',
    years: 3,
    location: '125 Anywhere St., Any City',
    dateStory: 'Julian invited me to a cooking class, which sounded fun in theory. However, he was super competitive about everything, kept mansplaining cooking techniques to me (I\'m literally a chef!), and got visibly frustrated when our dish didn\'t turn out perfect. The whole experience felt more like a competition than a date. Nice guy, but our personalities just don\'t mesh well.',
    dateLocation: 'Culinary Studio Downtown',
    dateActivity: 'Couples Cooking Class',
    dateRating: 2.4,
    totalRatings: 87,
    wowCount: 23,
    gtfohCount: 51,
    chekmateCount: 13
  }
];

interface Location {
  lat: number;
  lng: number;
  address: string;
  city: string;
  state: string;
}

interface RateYourDateProps {
  onShowWidget?: () => void;
}

export function RateYourDate({ onShowWidget }: RateYourDateProps) {
  const [showLocationSelector, setShowLocationSelector] = useState(false);
  const [selectedLocation, setSelectedLocation] = useState<Location | null>(null);
  const [radiusMiles, setRadiusMiles] = useState(50);
  const [userRatings, setUserRatings] = useState<Record<string, 'wow' | 'gtfoh' | 'chekmate'>>({});

  const handleLocationSelect = (location: Location) => {
    setSelectedLocation(location);
    setShowLocationSelector(false);
  };

  const handleRadiusChange = (newRadius: number) => {
    setRadiusMiles(newRadius);
  };

  const handleRating = (profileId: string, rating: 'wow' | 'gtfoh' | 'chekmate') => {
    setUserRatings(prev => ({
      ...prev,
      [profileId]: rating
    }));

    // Show success feedback
    console.log(`Rated ${profileId} as ${rating}`);
    
    // Here you would typically send to backend API
    // api.submitRating(profileId, rating);
  };

  return (
    <>
      <LocationSelector
        isOpen={showLocationSelector}
        onClose={() => setShowLocationSelector(false)}
        onLocationSelect={handleLocationSelect}
        currentLocation={selectedLocation || undefined}
        radiusMiles={radiusMiles}
        onRadiusChange={handleRadiusChange}
      />
      
      <div className="min-h-screen bg-gray-50">
        <RateYourDateHeader 
          onShowWidget={onShowWidget}
          onLocationClick={() => setShowLocationSelector(true)}
          selectedLocation={selectedLocation}
        />
        
        {/* Profile Grid */}
        <div className="px-4 pb-20">
          <div className="grid grid-cols-2 gap-4">
            {profiles.map((profile) => (
              <FlippableProfileCard 
                key={profile.id} 
                {...profile} 
                userRating={userRatings[profile.id] || null}
                onRate={(profileId, rating) => handleRating(profileId, rating)}
              />
            ))}
          </div>
          
          {/* Next Button */}
          <div className="flex justify-center mt-6">
            <button className="w-12 h-12 bg-orange-400 rounded-full flex items-center justify-center shadow-lg">
              <svg 
                width="20" 
                height="20" 
                viewBox="0 0 24 24" 
                fill="none" 
                className="text-white"
              >
                <path 
                  d="M9 18l6-6-6-6" 
                  stroke="currentColor" 
                  strokeWidth="2" 
                  strokeLinecap="round" 
                  strokeLinejoin="round"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </>
  );
}