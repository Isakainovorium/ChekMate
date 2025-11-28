import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

/// WebRTC configuration using free STUN servers
/// No paid services required - uses Firebase for signaling
class CallWebRTCConfig {
  static const Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ],
  };
}

/// Call connection state
enum CallConnectionState {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
  failed,
}

/// WebRTC Call Service
/// Uses Firebase Firestore for signaling (FREE with existing Firebase)
/// Uses Google's free STUN servers for NAT traversal
class CallService {
  CallService._();
  static final CallService instance = CallService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;

  bool _isInitialized = false;
  String? _currentCallId;
  bool _isVideoCall = false;

  StreamSubscription? _signalSubscription;

  // Stream controllers for events
  final _connectionStateController = StreamController<CallConnectionState>.broadcast();
  final _localVideoController = StreamController<RTCVideoRenderer>.broadcast();
  final _remoteVideoController = StreamController<RTCVideoRenderer>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Public streams
  Stream<CallConnectionState> get connectionState => _connectionStateController.stream;
  Stream<RTCVideoRenderer> get localVideo => _localVideoController.stream;
  Stream<RTCVideoRenderer> get remoteVideo => _remoteVideoController.stream;
  Stream<String> get errors => _errorController.stream;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Get local renderer
  RTCVideoRenderer? get localRenderer => _localRenderer;

  /// Get remote renderer
  RTCVideoRenderer? get remoteRenderer => _remoteRenderer;

  /// Get current call ID
  String? get currentCallId => _currentCallId;

  /// Check if this is a video call
  bool get isVideoCall => _isVideoCall;

  /// Initialize the service
  Future<void> initialize({bool video = false}) async {
    if (_isInitialized) return;

    try {
      _isVideoCall = video;

      // Request permissions
      await _requestPermissions(video: video);

      // Initialize renderers
      _localRenderer = RTCVideoRenderer();
      _remoteRenderer = RTCVideoRenderer();
      await _localRenderer!.initialize();
      await _remoteRenderer!.initialize();

      _isInitialized = true;
      developer.log('CallService initialized (video: $video)', name: 'CallService');
    } catch (e) {
      developer.log('Failed to initialize: $e', name: 'CallService');
      _errorController.add('Failed to initialize: $e');
      rethrow;
    }
  }

  /// Request camera and microphone permissions
  Future<void> _requestPermissions({bool video = false}) async {
    if (kIsWeb) return;

    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      throw Exception('Microphone permission denied');
    }

    if (video) {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        throw Exception('Camera permission denied');
      }
    }
  }

  /// Start a call (caller side)
  Future<void> startCall({
    required String callId,
    required bool isVideo,
  }) async {
    if (!_isInitialized) await initialize(video: isVideo);

    try {
      _currentCallId = callId;
      _isVideoCall = isVideo;
      _connectionStateController.add(CallConnectionState.connecting);

      // Get local media stream
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': isVideo
            ? {
                'facingMode': 'user',
                'width': {'ideal': 1280},
                'height': {'ideal': 720},
              }
            : false,
      });

      _localRenderer!.srcObject = _localStream;
      _localVideoController.add(_localRenderer!);

      // Create peer connection
      _peerConnection = await createPeerConnection(CallWebRTCConfig.configuration);

      // Add local stream tracks
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

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
              .collection('calls')
              .doc(callId)
              .collection('caller_candidates')
              .add(candidate.toMap());
        }
      };

      _peerConnection!.onConnectionState = (state) {
        _handleConnectionState(state);
      };

      // Create offer
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // Save offer to Firestore
      await _firestore.collection('calls').doc(callId).update({
        'offer': {'sdp': offer.sdp, 'type': offer.type},
      });

      // Listen for answer
      _signalSubscription = _firestore
          .collection('calls')
          .doc(callId)
          .snapshots()
          .listen((snapshot) async {
        final data = snapshot.data();
        if (data != null && data['answer'] != null && _peerConnection != null) {
          final answer = RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          );
          
          if (_peerConnection!.signalingState == 
              RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
            await _peerConnection!.setRemoteDescription(answer);
          }
        }
      });

      // Listen for receiver's ICE candidates
      _firestore
          .collection('calls')
          .doc(callId)
          .collection('receiver_candidates')
          .snapshots()
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          _peerConnection?.addCandidate(RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ));
        }
      });

      developer.log('Started call: $callId', name: 'CallService');
    } catch (e) {
      developer.log('Failed to start call: $e', name: 'CallService');
      _connectionStateController.add(CallConnectionState.failed);
      _errorController.add('Failed to start call: $e');
      rethrow;
    }
  }

  /// Answer a call (receiver side)
  Future<void> answerCall({
    required String callId,
    required bool isVideo,
  }) async {
    if (!_isInitialized) await initialize(video: isVideo);

    try {
      _currentCallId = callId;
      _isVideoCall = isVideo;
      _connectionStateController.add(CallConnectionState.connecting);

      // Get local media stream
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': isVideo
            ? {
                'facingMode': 'user',
                'width': {'ideal': 1280},
                'height': {'ideal': 720},
              }
            : false,
      });

      _localRenderer!.srcObject = _localStream;
      _localVideoController.add(_localRenderer!);

      // Create peer connection
      _peerConnection = await createPeerConnection(CallWebRTCConfig.configuration);

      // Add local stream tracks
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

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
              .collection('calls')
              .doc(callId)
              .collection('receiver_candidates')
              .add(candidate.toMap());
        }
      };

      _peerConnection!.onConnectionState = (state) {
        _handleConnectionState(state);
      };

      // Get the offer from Firestore
      final callDoc = await _firestore.collection('calls').doc(callId).get();
      final callData = callDoc.data();
      
      if (callData == null || callData['offer'] == null) {
        throw Exception('No offer found for this call');
      }

      final offer = RTCSessionDescription(
        callData['offer']['sdp'],
        callData['offer']['type'],
      );
      await _peerConnection!.setRemoteDescription(offer);

      // Create answer
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      // Save answer to Firestore
      await _firestore.collection('calls').doc(callId).update({
        'answer': {'sdp': answer.sdp, 'type': answer.type},
      });

      // Listen for caller's ICE candidates
      _firestore
          .collection('calls')
          .doc(callId)
          .collection('caller_candidates')
          .snapshots()
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          _peerConnection?.addCandidate(RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ));
        }
      });

      developer.log('Answered call: $callId', name: 'CallService');
    } catch (e) {
      developer.log('Failed to answer call: $e', name: 'CallService');
      _connectionStateController.add(CallConnectionState.failed);
      _errorController.add('Failed to answer call: $e');
      rethrow;
    }
  }

  void _handleConnectionState(RTCPeerConnectionState state) {
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        _connectionStateController.add(CallConnectionState.connected);
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        _connectionStateController.add(CallConnectionState.disconnected);
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        _connectionStateController.add(CallConnectionState.failed);
        break;
      case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
        _connectionStateController.add(CallConnectionState.connecting);
        break;
      default:
        break;
    }
  }

  /// End the current call
  Future<void> endCall() async {
    try {
      // Close peer connection
      await _peerConnection?.close();
      _peerConnection = null;

      // Stop local stream
      _localStream?.getTracks().forEach((track) => track.stop());
      _localStream = null;
      _remoteStream = null;

      // Cancel signal subscription
      await _signalSubscription?.cancel();
      _signalSubscription = null;

      _currentCallId = null;
      _connectionStateController.add(CallConnectionState.idle);

      developer.log('Ended call', name: 'CallService');
    } catch (e) {
      developer.log('Error ending call: $e', name: 'CallService');
    }
  }

  /// Toggle local audio (mute/unmute)
  void toggleMute(bool muted) {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !muted;
    });
  }

  /// Toggle local video (on/off)
  void toggleVideo(bool videoOff) {
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = !videoOff;
    });
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_localStream != null && _isVideoCall) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  /// Toggle speaker
  Future<void> toggleSpeaker(bool speakerOn) async {
    Helper.setSpeakerphoneOn(speakerOn);
  }

  /// Dispose the service
  Future<void> dispose() async {
    await endCall();

    await _localRenderer?.dispose();
    await _remoteRenderer?.dispose();
    _localRenderer = null;
    _remoteRenderer = null;

    _isInitialized = false;

    await _connectionStateController.close();
    await _localVideoController.close();
    await _remoteVideoController.close();
    await _errorController.close();
  }
}
