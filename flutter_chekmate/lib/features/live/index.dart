/// Live Streaming Feature - FREE WebRTC + Firebase
/// 
/// No paid streaming services required!
/// Uses:
/// - WebRTC for peer-to-peer video streaming
/// - Firebase Firestore for signaling
/// - Google's free STUN servers for NAT traversal
library live;

// Domain
export 'domain/entities/live_stream_entity.dart';

// Data
export 'data/datasources/live_stream_remote_datasource.dart';

// Services
export 'services/agora_service.dart'; // Actually WebRTC service (file name kept for compatibility)

// Presentation
export 'presentation/providers/live_providers.dart';
export 'presentation/pages/live_page.dart';
export 'presentation/pages/go_live_page.dart';
export 'presentation/pages/broadcast_page.dart';
export 'presentation/pages/watch_live_page.dart';
