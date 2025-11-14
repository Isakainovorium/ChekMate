import React, { useState } from 'react';
import { ProfileHeader } from './ProfileHeader';
import { ProfileStats } from './ProfileStats';
import { VideoCard } from './VideoCard';
import { BottomNavigation } from './BottomNavigation';
import { VideoPlayer } from './VideoPlayer';
import { MessagingInterface } from './MessagingInterface';
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

interface UserProfileProps {
  bottomNavTab: string;
  onBottomNavChange: (tab: string) => void;
}

export function UserProfile({ bottomNavTab, onBottomNavChange }: UserProfileProps) {
  const [isFollowing, setIsFollowing] = useState(false);
  const [followerCount, setFollowerCount] = useState(55000);
  const [selectedVideo, setSelectedVideo] = useState<typeof mockVideos[0] | null>(null);
  const [showMessaging, setShowMessaging] = useState(false);

  const handleFollowClick = () => {
    setIsFollowing(!isFollowing);
    setFollowerCount(prev => isFollowing ? prev - 1 : prev + 1);
  };

  const formatFollowerCount = (count: number) => {
    if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}K`;
    }
    return count.toString();
  };

  const handleVideoClick = (video: typeof mockVideos[0]) => {
    setSelectedVideo(video);
  };

  const handleMessageClick = () => {
    setShowMessaging(true);
  };

  const userInfo = {
    name: "Simone Gabrielle",
    username: "@thatgurlmone",
    bio: "Hello, I'm Simone Gabrielle Welcome to my profile!",
    avatar: exampleImage
  };

  return (
    <>
      <VideoPlayer
        isOpen={!!selectedVideo}
        onClose={() => setSelectedVideo(null)}
        video={selectedVideo || mockVideos[0]}
        userName={userInfo.name}
        userAvatar={userInfo.avatar}
      />
      
      <MessagingInterface
        isOpen={showMessaging}
        onClose={() => setShowMessaging(false)}
        recipient={userInfo}
      />
      
      <div className="min-h-screen bg-gray-50">
        <ProfileHeader
          name={userInfo.name}
          username={userInfo.username}
          bio={userInfo.bio}
          avatar={userInfo.avatar}
          isFollowing={isFollowing}
          onFollowClick={handleFollowClick}
          onMessageClick={handleMessageClick}
        />
        
        <ProfileStats
          posts={200}
          followers={formatFollowerCount(followerCount)}
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
        
        <BottomNavigation activeTab={bottomNavTab} onTabChange={onBottomNavChange} />
      </div>
    </>
  );
}