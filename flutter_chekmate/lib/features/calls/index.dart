/// Calls Feature - FREE WebRTC + Firebase
/// 
/// No paid calling services required!
/// Uses:
/// - WebRTC for peer-to-peer audio/video calls
/// - Firebase Firestore for signaling
/// - Google's free STUN servers for NAT traversal
library calls;

// Domain
export 'domain/entities/call_entity.dart';

// Data
export 'data/datasources/call_remote_datasource.dart';

// Services
export 'services/call_service.dart';

// Presentation
export 'presentation/providers/call_providers.dart';
export 'presentation/pages/call_page.dart';
export 'presentation/pages/incoming_call_page.dart';
export 'presentation/pages/outgoing_call_page.dart';
