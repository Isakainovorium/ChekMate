/// Mock data for development and testing
class MockData {
  // Mock users
  static const List<Map<String, dynamic>> users = [
    {
      'id': '1',
      'name': 'John Doe',
      'username': '@johndoe',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'bio': 'Software developer | Coffee enthusiast ☕',
      'followers': 1234,
      'following': 567,
      'isVerified': true,
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'username': '@janesmith',
      'avatar': 'https://i.pravatar.cc/150?img=2',
      'bio': 'Designer | Traveler 🌍',
      'followers': 5678,
      'following': 890,
      'isVerified': true,
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'username': '@mikej',
      'avatar': 'https://i.pravatar.cc/150?img=3',
      'bio': 'Photographer | Nature lover 📸',
      'followers': 2345,
      'following': 345,
      'isVerified': false,
    },
  ];

  // Mock posts
  static const List<Map<String, dynamic>> posts = [
    {
      'id': '1',
      'authorId': '1',
      'content': 'Just finished an amazing project! 🎉',
      'imageUrl': 'https://picsum.photos/400/300?random=1',
      'likes': 142,
      'comments': 23,
      'shares': 5,
      'timestamp': '2h ago',
    },
    {
      'id': '2',
      'authorId': '2',
      'content': 'Beautiful sunset today! 🌅',
      'imageUrl': 'https://picsum.photos/400/300?random=2',
      'likes': 567,
      'comments': 45,
      'shares': 12,
      'timestamp': '5h ago',
    },
    {
      'id': '3',
      'authorId': '3',
      'content': 'New camera gear arrived! Can\'t wait to test it out.',
      'imageUrl': null,
      'likes': 89,
      'comments': 12,
      'shares': 3,
      'timestamp': '1d ago',
    },
  ];

  // Mock messages
  static const List<Map<String, dynamic>> conversations = [
    {
      'id': '1',
      'userId': '1',
      'name': 'John Doe',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'lastMessage': 'Hey! How are you doing?',
      'timestamp': '2m ago',
      'unreadCount': 2,
      'isOnline': true,
    },
    {
      'id': '2',
      'userId': '2',
      'name': 'Jane Smith',
      'avatar': 'https://i.pravatar.cc/150?img=2',
      'lastMessage': 'Thanks for the help!',
      'timestamp': '1h ago',
      'unreadCount': 0,
      'isOnline': false,
    },
    {
      'id': '3',
      'userId': '3',
      'name': 'Mike Johnson',
      'avatar': 'https://i.pravatar.cc/150?img=3',
      'lastMessage': 'See you tomorrow!',
      'timestamp': '3h ago',
      'unreadCount': 1,
      'isOnline': true,
    },
  ];

  // Mock messages in a conversation
  static const List<Map<String, dynamic>> messages = [
    {
      'id': '1',
      'senderId': '1',
      'text': 'Hey! How are you doing?',
      'timestamp': '10:30 AM',
      'isMe': false,
    },
    {
      'id': '2',
      'senderId': 'me',
      'text': 'I\'m good! How about you?',
      'timestamp': '10:32 AM',
      'isMe': true,
    },
    {
      'id': '3',
      'senderId': '1',
      'text': 'Great! Want to grab coffee later?',
      'timestamp': '10:35 AM',
      'isMe': false,
    },
    {
      'id': '4',
      'senderId': 'me',
      'text': 'Sure! What time works for you?',
      'timestamp': '10:36 AM',
      'isMe': true,
    },
  ];

  // Mock notifications
  static const List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'type': 'like',
      'userId': '1',
      'userName': 'John Doe',
      'userAvatar': 'https://i.pravatar.cc/150?img=1',
      'message': 'liked your post',
      'timestamp': '5m ago',
      'isRead': false,
    },
    {
      'id': '2',
      'type': 'comment',
      'userId': '2',
      'userName': 'Jane Smith',
      'userAvatar': 'https://i.pravatar.cc/150?img=2',
      'message': 'commented on your post',
      'timestamp': '1h ago',
      'isRead': false,
    },
    {
      'id': '3',
      'type': 'follow',
      'userId': '3',
      'userName': 'Mike Johnson',
      'userAvatar': 'https://i.pravatar.cc/150?img=3',
      'message': 'started following you',
      'timestamp': '2h ago',
      'isRead': true,
    },
  ];

  // Mock stories
  static const List<Map<String, dynamic>> stories = [
    {
      'id': '1',
      'userId': '1',
      'userName': 'John Doe',
      'userAvatar': 'https://i.pravatar.cc/150?img=1',
      'imageUrl': 'https://picsum.photos/400/600?random=10',
      'timestamp': '2h ago',
      'isViewed': false,
    },
    {
      'id': '2',
      'userId': '2',
      'userName': 'Jane Smith',
      'userAvatar': 'https://i.pravatar.cc/150?img=2',
      'imageUrl': 'https://picsum.photos/400/600?random=11',
      'timestamp': '5h ago',
      'isViewed': true,
    },
  ];

  // Mock date ratings
  static const List<Map<String, dynamic>> dateRatings = [
    {
      'id': '1',
      'name': 'Sarah Williams',
      'age': 28,
      'location': 'New York, NY',
      'imageUrl': 'https://i.pravatar.cc/400?img=10',
      'bio': 'Love hiking and trying new restaurants!',
      'interests': ['Travel', 'Food', 'Fitness'],
    },
    {
      'id': '2',
      'name': 'Alex Chen',
      'age': 32,
      'location': 'San Francisco, CA',
      'imageUrl': 'https://i.pravatar.cc/400?img=11',
      'bio': 'Tech enthusiast and coffee addict ☕',
      'interests': ['Technology', 'Coffee', 'Music'],
    },
    {
      'id': '3',
      'name': 'Emily Rodriguez',
      'age': 26,
      'location': 'Los Angeles, CA',
      'imageUrl': 'https://i.pravatar.cc/400?img=12',
      'bio': 'Artist and yoga instructor 🧘‍♀️',
      'interests': ['Art', 'Yoga', 'Nature'],
    },
  ];

  // Mock subscription tiers
  static const List<Map<String, dynamic>> subscriptionTiers = [
    {
      'id': 'free',
      'name': 'Free',
      'price': 0,
      'features': [
        'Basic profile',
        'Limited swipes per day',
        'Standard matching',
      ],
    },
    {
      'id': 'premium',
      'name': 'Premium',
      'price': 9.99,
      'features': [
        'Unlimited swipes',
        'See who liked you',
        'Advanced filters',
        'No ads',
      ],
      'popular': true,
    },
    {
      'id': 'vip',
      'name': 'VIP',
      'price': 19.99,
      'features': [
        'All Premium features',
        'Priority matching',
        'Exclusive events',
        'Profile boost',
        'Read receipts',
      ],
    },
  ];
}
