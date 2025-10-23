import React, { useState } from 'react';
import { Bell, Share, Settings } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { ProfileStats } from './ProfileStats';
import { VideoCard } from './VideoCard';
import { BottomNavigation } from './BottomNavigation';
import { VideoPlayer } from './VideoPlayer';
import { SettingsPage } from './SettingsPage';
import { ProfilePictureChanger } from './ProfilePictureChanger';
import { EditProfile } from './EditProfile';
import { ShareProfile } from './ShareProfile';
import exampleImage from 'figma:asset/285ff4cce25e80c5ea02756d790113a642d395c2.png';

const mockVideos = [
  {
    id: '1',
    thumbnail: 'https://images.unsplash.com/photo-1552011571-db69d3a55457?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHRhbGtpbmclMjBwaG9uZSUyMGRyYW1hdGljJTIwbGlnaHRpbmd8ZW58MXx8fHwxNzU5NzU3MTA5fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    title: 'Why Doja Dior Scammed: A thread Just so there isn\'t any confusion, Ye me and her had a contract that we both signed that stated all the Items I had for promo would be posted within 2 week',
    views: '1.1M',
    isChecked: true
  },
  {
    id: '2',
    thumbnail: 'https://images.unsplash.com/photo-1758522482313-18d6c563dc5a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb3VwbGUlMjBhcmd1aW5nJTIwcmVsYXRpb25zaGlwJTIwZHJhbWF8ZW58MXx8fHwxNzU5NzU3MTEzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    title: 'Part One- Who TF Did I Marry??',
    views: '3.1M',
    isChecked: true
  },
  {
    id: '3',
    thumbnail: 'https://images.unsplash.com/photo-1758611975583-fddf609226a0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHVwc2V0JTIwZW1vdGlvbmFsJTIwcGhvbmUlMjBjYWxsfGVufDF8fHx8MTc1OTc1NzExN3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    title: 'Came home early and caught my girl cheating',
    views: '2.1M',
    isChecked: false
  },
  {
    id: '4',
    thumbnail: 'https://images.unsplash.com/photo-1669627961229-987550948857?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZXJzb24lMjBiZXRyYXlhbCUyMHNob2NrZWQlMjBleHByZXNzaW9ufGVufDF8fHx8MTc1OTc1NzEyMXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    title: 'Wife Caught Her Husband On A 300 Dollar Date With His BabyMomma 😯😯',
    views: '4.2M',
    isChecked: false
  }
];

interface MyProfileProps {
  bottomNavTab: string;
  onBottomNavChange: (tab: string) => void;
  userAvatar: string;
  onAvatarChange: (newAvatar: string) => void;
  username?: string;
  bio?: string;
  onProfileUpdate?: (username: string, bio: string) => void;
}

export function MyProfile({ 
  bottomNavTab, 
  onBottomNavChange, 
  userAvatar, 
  onAvatarChange,
  username = "ChekMate_User",
  bio = "Living my best life and looking for someone to share adventures with! 🌟 Love hiking, cooking, and spontaneous road trips.",
  onProfileUpdate
}: MyProfileProps) {
  const [selectedVideo, setSelectedVideo] = useState<typeof mockVideos[0] | null>(null);
  const [showSettings, setShowSettings] = useState(false);
  const [showPictureChanger, setShowPictureChanger] = useState(false);
  const [showEditProfile, setShowEditProfile] = useState(false);
  const [showShareProfile, setShowShareProfile] = useState(false);
  const [currentUsername, setCurrentUsername] = useState(username);
  const [currentBio, setCurrentBio] = useState(bio);

  const handleVideoClick = (video: typeof mockVideos[0]) => {
    setSelectedVideo(video);
  };

  const handleProfileUpdate = (newUsername: string, newBio: string) => {
    setCurrentUsername(newUsername);
    setCurrentBio(newBio);
    onProfileUpdate?.(newUsername, newBio);
  };

  const userInfo = {
    name: "Simone Gabrielle",
    username: `@${currentUsername}`,
    bio: currentBio,
    avatar: userAvatar
  };

  if (showSettings) {
    return <SettingsPage onBack={() => setShowSettings(false)} />;
  }

  return (
    <>
      <VideoPlayer
        isOpen={!!selectedVideo}
        onClose={() => setSelectedVideo(null)}
        video={selectedVideo || mockVideos[0]}
        userName={userInfo.name}
        userAvatar={userInfo.avatar}
      />

      <ProfilePictureChanger
        isOpen={showPictureChanger}
        onClose={() => setShowPictureChanger(false)}
        currentAvatar={userInfo.avatar}
        onSave={onAvatarChange}
      />

      <EditProfile
        isOpen={showEditProfile}
        onClose={() => setShowEditProfile(false)}
        currentUsername={currentUsername}
        currentBio={currentBio}
        userAvatar={userAvatar}
        onSave={handleProfileUpdate}
      />

      <ShareProfile
        isOpen={showShareProfile}
        onClose={() => setShowShareProfile(false)}
        username={currentUsername}
        bio={currentBio}
        avatar={userAvatar}
        profileStats={{
          followers: 1234,
          following: 567,
          posts: 89
        }}
      />
      
      <div className="min-h-screen bg-gray-50">
        {/* My Profile Header */}
        <div className="bg-white px-4 py-6">
          {/* Top icons */}
          <div className="flex justify-end space-x-4 mb-6">
            <button>
              <Bell size={24} className="text-gray-700" />
            </button>
            <button onClick={() => setShowShareProfile(true)}>
              <Share size={24} className="text-gray-700" />
            </button>
          </div>

          {/* Profile info and avatar */}
          <div className="flex items-start justify-between mb-6">
            <div className="flex-1">
              <h1 className="text-2xl font-bold text-gray-900 mb-1">{userInfo.name}</h1>
              <p className="text-gray-600 text-base mb-4">{userInfo.username}</p>
              <p className="text-gray-800 text-sm leading-relaxed">{userInfo.bio}</p>
            </div>
            
            {/* Profile picture with gradient border */}
            <div className="ml-6">
              <div className="w-24 h-24 rounded-full p-1 bg-gradient-to-r from-yellow-400 to-orange-400">
                <button 
                  onClick={() => setShowPictureChanger(true)}
                  className="w-full h-full rounded-full relative group cursor-pointer"
                >
                  <ImageWithFallback
                    src={userInfo.avatar}
                    alt={userInfo.name}
                    className="w-full h-full rounded-full object-cover bg-white p-1"
                  />
                  {/* Hover overlay */}
                  <div className="absolute inset-0 bg-black bg-opacity-40 rounded-full opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                    <div className="text-white text-xs font-medium text-center">
                      Change<br/>Photo
                    </div>
                  </div>
                </button>
              </div>
            </div>
          </div>

          {/* Action buttons - Edit Profile and Settings for own profile */}
          <div className="flex space-x-3">
            <button 
              onClick={() => setShowEditProfile(true)}
              className="flex-1 py-2 px-4 rounded-lg font-medium bg-orange-400 text-white hover:bg-orange-500 transition-colors"
            >
              Edit Profile
            </button>
            <button 
              onClick={() => setShowSettings(true)}
              className="flex-1 py-2 px-4 rounded-lg font-medium bg-gray-200 text-gray-800 hover:bg-gray-300 transition-colors flex items-center justify-center space-x-2"
            >
              <Settings size={16} />
              <span>Settings</span>
            </button>
          </div>
        </div>
        
        <ProfileStats
          posts={200}
          followers="55K"
          subscribers="5K"
          likes="1M"
        />
        
        {/* Video grid */}
        <div className="p-4 pb-20">
          <div className="grid grid-cols-2 gap-4">
            {mockVideos.map((video) => (
              <VideoCard 
                key={video.id} 
                {...video} 
                onClick={() => handleVideoClick(video)}
              />
            ))}
          </div>
        </div>
        
        <BottomNavigation activeTab={bottomNavTab} onTabChange={onBottomNavChange} hideNavigation={false} onCreateClick={() => {}} />
      </div>
    </>
  );
}