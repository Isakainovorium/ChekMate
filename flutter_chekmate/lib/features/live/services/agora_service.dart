import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

/// WebRTC configuration using free STUN servers
/// No paid services required - uses Firebase for signaling
class WebRTCConfig {
  /// Free public STUN servers (Google's free servers)
  static const Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
    ],
  };
}

/// User role in the stream
enum StreamUserRole {
  broadcaster,
  viewer,
}

/// Connection state
enum StreamConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

/// WebRTC Live Streaming Service
/// Uses Firebase Firestore for signaling (FREE with your existing Firebase)
/// Uses Google's free STUN servers for NAT traversal
class LiveStreamService {
  LiveStreamService._();
  static final LiveStreamService instance = LiveStreamService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;
  
  bool _isInitialized = false;
  String? _currentStreamId;
  StreamUserRole _currentRole = StreamUserRole.viewer;
  
  StreamSubscription? _signalSubscription;
  final Map<String, RTCPeerConnection> _viewerConnections = {};

  // Stream controllers for events
  final _connectionStateController = StreamController<StreamConnectionState>.broadcast();
  final _viewerCountController = StreamController<int>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _localVideoController = StreamController<RTCVideoRenderer>.broadcast();
  final _remoteVideoController = StreamController<RTCVideoRenderer>.broadcast();

  // Public streams
  Stream<StreamConnectionState> get connectionState => _connectionStateController.stream;
  Stream<int> get viewerCount => _viewerCountController.stream;
  Stream<String> get errors => _errorController.stream;
  Stream<RTCVideoRenderer> get localVideo => _localVideoController.stream;
  Stream<RTCVideoRenderer> get remoteVideo => _remoteVideoController.stream;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Get local renderer
  RTCVideoRenderer? get localRenderer => _localRenderer;

  /// Get remote renderer
  RTCVideoRenderer? get remoteRenderer => _remoteRenderer;

  /// Get current stream ID
  String? get currentStreamId => _currentStreamId;

  /// Get current role
  StreamUserRole get currentRole => _currentRole;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await _requestPermissions();

      // Initialize renderers
      _localRenderer = RTCVideoRenderer();
      _remoteRenderer = RTCVideoRenderer();
      await _localRenderer!.initialize();
      await _remoteRenderer!.initialize();

      _isInitialized = true;
      developer.log('LiveStreamService initialized', name: 'LiveStreamService');
    } catch (e) {
      developer.log('Failed to initialize: $e', name: 'LiveStreamService');
      _errorController.add('Failed to initialize: $e');
      rethrow;
    }
  }

  /// Request camera and microphone permissions
  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus != PermissionStatus.granted) {
      throw Exception('Camera permission denied');
    }
    if (micStatus != PermissionStatus.granted) {
      throw Exception('Microphone permission denied');
    }
  }

  /// Start broadcasting (Go Live)
  Future<void> startBroadcast({required String streamId}) async {
    if (!_isInitialized) await initialize();

    try {
      _currentStreamId = streamId;
      _currentRole = StreamUserRole.broadcaster;
      _connectionStateController.add(StreamConnectionState.connecting);

      // Get local media stream
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
      });

      _localRenderer!.srcObject = _localStream;
      _localVideoController.add(_localRenderer!);

      // Listen for viewer connection requests
      _signalSubscription = _firestore
          .collection('live_streams')
          .doc(streamId)
          .collection('viewers')
          .snapshots()
          .listen(_handleViewerSignals);

      _connectionStateController.add(StreamConnectionState.connected);
      developer.log('Started broadcast: $streamId', name: 'LiveStreamService');
    } catch (e) {
      developer.log('Failed to start broadcast: $e', name: 'LiveStreamService');
      _connectionStateController.add(StreamConnectionState.failed);
      _errorController.add('Failed to start broadcast: $e');
      rethrow;
    }
  }

  /// Handle incoming viewer connection requests
  Future<void> _handleViewerSignals(QuerySnapshot snapshot) async {
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        final viewerId = change.doc.id;
        final data = change.doc.data() as Map<String, dynamic>?;
        
        if (data != null && data['offer'] != null) {
          await _handleViewerOffer(viewerId, data);
        }
      }
    }
    
    _viewerCountController.add(snapshot.docs.length);
  }

  /// Handle a viewer's offer and send answer
  Future<void> _handleViewerOffer(String viewerId, Map<String, dynamic> data) async {
    try {
      // Create peer connection for this viewer
      final pc = await createPeerConnection(WebRTCConfig.configuration);
      _viewerConnections[viewerId] = pc;

      // Add local stream tracks
      _localStream?.getTracks().forEach((track) {
        pc.addTrack(track, _localStream!);
      });

      // Handle ICE candidates
      pc.onIceCandidate = (candidate) {
        if (candidate.candidate != null) {
          _firestore
              .collection('live_streams')
              .doc(_currentStreamId)
              .collection('viewers')
              .doc(viewerId)
              .collection('broadcaster_candidates')
              .add(candidate.toMap());
        }
      };

      // Set remote description (viewer's offer)
      final offer = RTCSessionDescription(
        data['offer']['sdp'],
        data['offer']['type'],
      );
      await pc.setRemoteDescription(offer);

      // Create and send answer
      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);

      await _firestore
          .collection('live_streams')
          .doc(_currentStreamId)
          .collection('viewers')
          .doc(viewerId)
          .update({
        'answer': {'sdp': answer.sdp, 'type': answer.type},
      });

      // Listen for viewer's ICE candidates
      _firestore
          .collection('live_streams')
          .doc(_currentStreamId)
          .collection('viewers')
          .doc(viewerId)
          .collection('viewer_candidates')
          .snapshots()
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          final candidateData = doc.data();
          pc.addCandidate(RTCIceCandidate(
            candidateData['candidate'],
            candidateData['sdpMid'],
            candidateData['sdpMLineIndex'],
          ));
        }
      });

      developer.log('Connected to viewer: $viewerId', name: 'LiveStreamService');
    } catch (e) {
      developer.log('Failed to handle viewer offer: $e', name: 'LiveStreamService');
    }
  }

  /// Join a stream as viewer (Watch Live)
  Future<void> joinAsViewer({required String streamId}) async {
    if (!_isInitialized) await initialize();

    try {
      _currentStreamId = streamId;
      _currentRole = StreamUserRole.viewer;
      _connectionStateController.add(StreamConnectionState.connecting);

      // Create peer connection
      _peerConnection = await createPeerConnection(WebRTCConfig.configuration);

      // Handle incoming stream
      _peerConnection!.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteRenderer!.srcObject = _remoteStream;
          _remoteVideoController.add(_remoteRenderer!);
        }
      };

      // Handle ICE candidates
      _peerConnection!.onIceCandidate = (candidate) {
        if (candidate.candidate != null) {
          _firestore
              .collection('live_streams')
              .doc(streamId)
              .collection('viewers')
              .doc(_getViewerId())
              .collection('viewer_candidates')
              .add(candidate.toMap());
        }
      };

      _peerConnection!.onConnectionState = (state) {
        switch (state) {
          case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
            _connectionStateController.add(StreamConnectionState.connected);
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
            _connectionStateController.add(StreamConnectionState.disconnected);
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
            _connectionStateController.add(StreamConnectionState.failed);
            break;
          default:
            break;
        }
      };

      // Create offer
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      await _peerConnection!.setLocalDescription(offer);

      // Send offer to broadcaster via Firestore
      final viewerDoc = _firestore
          .collection('live_streams')
          .doc(streamId)
          .collection('viewers')
          .doc(_getViewerId());

      await viewerDoc.set({
        'offer': {'sdp': offer.sdp, 'type': offer.type},
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Listen for answer from broadcaster
      viewerDoc.snapshots().listen((snapshot) async {
        final data = snapshot.data();
        if (data != null && data['answer'] != null) {
          final answer = RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          );
          await _peerConnection!.setRemoteDescription(answer);
        }
      });

      // Listen for broadcaster's ICE candidates
      viewerDoc.collection('broadcaster_candidates').snapshots().listen((snapshot) {
        for (final doc in snapshot.docs) {
          final candidateData = doc.data();
          _peerConnection!.addCandidate(RTCIceCandidate(
            candidateData['candidate'],
            candidateData['sdpMid'],
            candidateData['sdpMLineIndex'],
          ));
        }
      });

      developer.log('Joined stream as viewer: $streamId', name: 'LiveStreamService');
    } catch (e) {
      developer.log('Failed to join stream: $e', name: 'LiveStreamService');
      _connectionStateController.add(StreamConnectionState.failed);
      _errorController.add('Failed to join stream: $e');
      rethrow;
    }
  }

  /// Generate a unique viewer ID
  String _getViewerId() {
    return 'viewer_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Leave the current stream
  Future<void> leaveStream() async {
    try {
      // Close all viewer connections (if broadcaster)
      for (final pc in _viewerConnections.values) {
        await pc.close();
      }
      _viewerConnections.clear();

      // Close main peer connection
      await _peerConnection?.close();
      _peerConnection = null;

      // Stop local stream
      _localStream?.getTracks().forEach((track) => track.stop());
      _localStream = null;

      // Cancel signal subscription
      await _signalSubscription?.cancel();
      _signalSubscription = null;

      _currentStreamId = null;
      _connectionStateController.add(StreamConnectionState.disconnected);
      
      developer.log('Left stream', name: 'LiveStreamService');
    } catch (e) {
      developer.log('Error leaving stream: $e', name: 'LiveStreamService');
    }
  }

  /// Toggle local video
  Future<void> toggleVideo(bool enabled) async {
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  /// Toggle local audio
  Future<void> toggleAudio(bool enabled) async {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = enabled;
    });
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    await leaveStream();
    
    await _localRenderer?.dispose();
    await _remoteRenderer?.dispose();
    _localRenderer = null;
    _remoteRenderer = null;
    
    _isInitialized = false;

    await _connectionStateController.close();
    await _viewerCountController.close();
    await _errorController.close();
    await _localVideoController.close();
    await _remoteVideoController.close();
  }
}
