import React from 'react';
import { Post } from './Post';

const followingPosts = [
  {
    id: 'f1',
    username: 'Simone Gabrielle',
    avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: 'Update on my dating life: Finally went on that coffee date I was nervous about! ☕️ Sometimes taking that leap of faith pays off 💕',
    likes: 1850,
    comments: 142,
    shares: 38,
    timestamp: '1h ago'
  },
  {
    id: 'f2',
    username: 'MikeD_Official',
    avatar: 'https://images.unsplash.com/photo-1672685667592-0392f458f46f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NTk3MTMyNTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: 'Lesson learned: Never underestimate the power of actually listening on a date. Put your phone away and be present 📱❌',
    image: 'https://images.unsplash.com/photo-1559292584-b28c39b09a3f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb3VwbGUlMjBjb2ZmZWUlMjBkYXRlfGVufDF8fHx8MTc1OTc1NzkzNXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    likes: 2340,
    comments: 189,
    shares: 156,
    timestamp: '3h ago'
  },
  {
    id: 'f3',
    username: 'JessicaM',
    avatar: 'https://images.unsplash.com/photo-1655249493799-9cee4fe983bb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2Zlc3Npb25hbCUyMGhlYWRzaG90fGVufDF8fHx8MTc1OTczMDU0M3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: 'Red flag spotted: They spent the entire dinner talking about their ex 🚩 Trust your instincts, people!',
    likes: 3200,
    comments: 287,
    shares: 94,
    timestamp: '5h ago'
  },
  {
    id: 'f4',
    username: 'SarahJ_Stories',
    avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: 'Date night makeup tutorial coming tomorrow! Nothing boosts confidence like feeling amazing in your own skin ✨💄',
    image: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWtldXAlMjBiZWF1dHklMjB3b21hbnxlbnwxfHx8fDE3NTk3NTc5NDV8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    likes: 1680,
    comments: 93,
    shares: 47,
    timestamp: '8h ago'
  },
  {
    id: 'f5',
    username: 'Tbabee100',
    avatar: 'https://images.unsplash.com/photo-1618590067690-2db34a87750a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBzZWxmaWV8ZW58MXx8fHwxNzU5NzU0Mjc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: 'Follow-up to my story: We\'re officially dating now! 💕 Sometimes the best love stories have the messiest beginnings',
    likes: 4580,
    comments: 156,
    shares: 234,
    timestamp: '12h ago'
  },
  {
    id: 'f6',
    username: 'DatingCoachAlex',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwcm9mZXNzaW9uYWwlMjBzbWlsZXxlbnwxfHx8fDE3NTk3NTc5NTB8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    content: 'Dating tip: The 3-date rule isn\'t about physical intimacy. It\'s about giving someone 3 real chances to show you who they are 💫',
    likes: 890,
    comments: 67,
    shares: 123,
    timestamp: '1d ago'
  }
];

interface FollowingProps {
  onShareModalOpen?: () => void;
  onShareModalClose?: () => void;
}

export function Following({ onShareModalOpen, onShareModalClose }: FollowingProps) {
  if (followingPosts.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-16 px-4">
        <div className="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mb-6">
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none" className="text-gray-400">
            <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <circle cx="9" cy="7" r="4" stroke="currentColor" strokeWidth="2"/>
            <path d="m19 8 2 2-2 2" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <path d="m17 10 2-2-2-2" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>
        
        <h3 className="text-xl font-semibold text-gray-900 mb-2">No Following Yet</h3>
        <p className="text-gray-600 text-center mb-6 max-w-sm">
          Start following people to see their latest dating stories and advice in your Following feed.
        </p>
        
        <button className="px-6 py-3 bg-orange-400 text-white rounded-full font-medium hover:bg-orange-500 transition-colors">
          Discover People
        </button>
      </div>
    );
  }

  return (
    <div className="pb-16">
      {/* Following indicator */}
      <div className="bg-white border-b border-gray-100 px-4 py-3">
        <div className="flex items-center space-x-2">
          <div className="w-2 h-2 bg-orange-400 rounded-full"></div>
          <span className="text-sm text-gray-600">Latest from people you follow</span>
        </div>
      </div>

      {/* Following posts */}
      {followingPosts.map((post) => (
        <Post 
          key={post.id} 
          {...post} 
          onShareModalOpen={onShareModalOpen}
          onShareModalClose={onShareModalClose}
        />
      ))}
      
      {/* Load more section */}
      <div className="bg-white border-b border-gray-100 px-4 py-6 text-center">
        <button className="text-orange-400 font-medium hover:text-orange-500 transition-colors">
          Load more posts
        </button>
      </div>
    </div>
  );
}