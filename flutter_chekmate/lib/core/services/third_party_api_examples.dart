import 'package:dio/dio.dart';
import 'package:flutter_chekmate/core/services/http_client_service.dart';

/// Third-Party API Examples
///
/// Demonstrates how to integrate with various third-party APIs using HttpClientService.
/// These are example implementations that can be extended for production use.
///
/// APIs Covered:
/// - Giphy API (GIF search for messages)
/// - Spotify API (share music in posts)
/// - Stripe API (subscription payments)
/// - Geocoding API (reverse geocoding)
/// - Content Moderation API (image/text moderation)

/// Giphy API Service
///
/// Search and retrieve GIFs for messaging features
class GiphyApiService {
  GiphyApiService({
    required this.apiKey,
  });

  final String apiKey;
  final String baseUrl = 'https://api.giphy.com/v1';

  /// Search GIFs
  ///
  /// [query] - Search query (e.g., 'funny cat')
  /// [limit] - Number of results (default: 25)
  /// [offset] - Pagination offset (default: 0)
  Future<List<GiphyGif>> searchGifs({
    required String query,
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final client = HttpClientService.instance;
      final response = await client.get<Map<String, dynamic>>(
        '$baseUrl/gifs/search',
        queryParameters: {
          'api_key': apiKey,
          'q': query,
          'limit': limit,
          'offset': offset,
          'rating': 'g', // Safe for work
          'lang': 'en',
        },
      );

      final data = response.data?['data'] as List? ?? [];
      return data
          .map((json) => GiphyGif.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw GiphyApiException('Failed to search GIFs: $e');
    }
  }

  /// Get trending GIFs
  ///
  /// [limit] - Number of results (default: 25)
  Future<List<GiphyGif>> getTrendingGifs({int limit = 25}) async {
    try {
      final client = HttpClientService.instance;
      final response = await client.get<Map<String, dynamic>>(
        '$baseUrl/gifs/trending',
        queryParameters: {
          'api_key': apiKey,
          'limit': limit,
          'rating': 'g',
        },
      );

      final data = response.data?['data'] as List? ?? [];
      return data
          .map((json) => GiphyGif.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw GiphyApiException('Failed to get trending GIFs: $e');
    }
  }
}

/// Giphy GIF Model
class GiphyGif {
  GiphyGif({
    required this.id,
    required this.title,
    required this.url,
    required this.previewUrl,
  });

  factory GiphyGif.fromJson(Map<String, dynamic> json) {
    return GiphyGif(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['images']['original']['url'] as String,
      previewUrl: json['images']['preview_gif']['url'] as String,
    );
  }

  final String id;
  final String title;
  final String url;
  final String previewUrl;
}

class GiphyApiException implements Exception {
  const GiphyApiException(this.message);
  final String message;
  @override
  String toString() => 'GiphyApiException: $message';
}

/// Spotify API Service
///
/// Search and retrieve music tracks for sharing in posts
class SpotifyApiService {
  SpotifyApiService({
    required this.clientId,
    required this.clientSecret,
  });

  final String clientId;
  final String clientSecret;
  final String baseUrl = 'https://api.spotify.com/v1';

  String? _accessToken;

  /// Get access token
  Future<String> _getAccessToken() async {
    if (_accessToken != null) return _accessToken!;

    try {
      final client = HttpClientService.instance;
      final response = await client.post<Map<String, dynamic>>(
        'https://accounts.spotify.com/api/token',
        data: {
          'grant_type': 'client_credentials',
        },
        options: Options(
          headers: {
            'Authorization':
                'Basic ${_base64Encode('$clientId:$clientSecret')}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      _accessToken = response.data?['access_token'] as String?;
      if (_accessToken == null) {
        throw const SpotifyApiException('Access token not found in response');
      }
      return _accessToken!;
    } catch (e) {
      throw SpotifyApiException('Failed to get access token: $e');
    }
  }

  /// Search tracks
  ///
  /// [query] - Search query (e.g., 'Bohemian Rhapsody')
  /// [limit] - Number of results (default: 20)
  Future<List<SpotifyTrack>> searchTracks({
    required String query,
    int limit = 20,
  }) async {
    try {
      final token = await _getAccessToken();
      final client = HttpClientService.instance;
      final response = await client.get<Map<String, dynamic>>(
        '$baseUrl/search',
        queryParameters: {
          'q': query,
          'type': 'track',
          'limit': limit,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final tracks = response.data?['tracks']?['items'] as List? ?? [];
      return tracks
          .map((json) => SpotifyTrack.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw SpotifyApiException('Failed to search tracks: $e');
    }
  }

  String _base64Encode(String str) {
    return str; // Simplified - use dart:convert base64 in production
  }
}

/// Spotify Track Model
class SpotifyTrack {
  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artist,
    required this.album,
    required this.previewUrl,
    required this.externalUrl,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      id: json['id'] as String,
      name: json['name'] as String,
      artist: (json['artists'] as List).first['name'] as String,
      album: json['album']['name'] as String,
      previewUrl: json['preview_url'] as String?,
      externalUrl: json['external_urls']['spotify'] as String,
    );
  }

  final String id;
  final String name;
  final String artist;
  final String album;
  final String? previewUrl;
  final String externalUrl;
}

class SpotifyApiException implements Exception {
  const SpotifyApiException(this.message);
  final String message;
  @override
  String toString() => 'SpotifyApiException: $message';
}

/// Stripe API Service
///
/// Handle subscription payments and in-app purchases
class StripeApiService {
  StripeApiService({
    required this.secretKey,
  });

  final String secretKey;
  final String baseUrl = 'https://api.stripe.com/v1';

  /// Create payment intent
  ///
  /// [amount] - Amount in cents (e.g., 1000 = $10.00)
  /// [currency] - Currency code (e.g., 'usd')
  Future<String> createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    try {
      final client = HttpClientService.instance;
      final response = await client.post<Map<String, dynamic>>(
        '$baseUrl/payment_intents',
        data: {
          'amount': amount,
          'currency': currency,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $secretKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      final clientSecret = response.data?['client_secret'] as String?;
      if (clientSecret == null) {
        throw const StripeApiException('Client secret not found in response');
      }
      return clientSecret;
    } catch (e) {
      throw StripeApiException('Failed to create payment intent: $e');
    }
  }

  /// Create subscription
  ///
  /// [customerId] - Stripe customer ID
  /// [priceId] - Stripe price ID
  Future<Map<String, dynamic>> createSubscription({
    required String customerId,
    required String priceId,
  }) async {
    try {
      final client = HttpClientService.instance;
      final response = await client.post<Map<String, dynamic>>(
        '$baseUrl/subscriptions',
        data: {
          'customer': customerId,
          'items[0][price]': priceId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $secretKey',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw StripeApiException('Failed to create subscription: $e');
    }
  }
}

class StripeApiException implements Exception {
  const StripeApiException(this.message);
  final String message;
  @override
  String toString() => 'StripeApiException: $message';
}

/// Geocoding API Service
///
/// Reverse geocoding for location features
class GeocodingApiService {
  GeocodingApiService({
    required this.apiKey,
  });

  final String apiKey;
  final String baseUrl = 'https://maps.googleapis.com/maps/api';

  /// Reverse geocode coordinates to address
  ///
  /// [latitude] - Latitude coordinate
  /// [longitude] - Longitude coordinate
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final client = HttpClientService.instance;
      final response = await client.get<Map<String, dynamic>>(
        '$baseUrl/geocode/json',
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': apiKey,
        },
      );

      final results = response.data?['results'] as List? ?? [];
      if (results.isEmpty) {
        throw const GeocodingApiException('No address found');
      }

      return results.first['formatted_address'] as String;
    } catch (e) {
      throw GeocodingApiException('Failed to reverse geocode: $e');
    }
  }
}

class GeocodingApiException implements Exception {
  const GeocodingApiException(this.message);
  final String message;
  @override
  String toString() => 'GeocodingApiException: $message';
}

/// Content Moderation API Service
///
/// Moderate images and text for inappropriate content
class ContentModerationApiService {
  ContentModerationApiService({
    required this.apiKey,
  });

  final String apiKey;
  final String baseUrl = 'https://api.moderatecontent.com/moderate/v1';

  /// Moderate image
  ///
  /// [imageUrl] - URL of image to moderate
  /// Returns true if image is safe, false if inappropriate
  Future<bool> moderateImage(String imageUrl) async {
    try {
      final client = HttpClientService.instance;
      final response = await client.post<Map<String, dynamic>>(
        '$baseUrl/image',
        data: {
          'url': imageUrl,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );

      final rating = response.data?['rating'] as String?;
      if (rating == null) {
        throw const ContentModerationException('Rating not found in response');
      }
      return rating == 'safe';
    } catch (e) {
      throw ContentModerationException('Failed to moderate image: $e');
    }
  }

  /// Moderate text
  ///
  /// [text] - Text to moderate
  /// Returns true if text is safe, false if inappropriate
  Future<bool> moderateText(String text) async {
    try {
      final client = HttpClientService.instance;
      final response = await client.post<Map<String, dynamic>>(
        '$baseUrl/text',
        data: {
          'text': text,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );

      final flagged = response.data?['flagged'] as bool? ?? false;
      return !flagged;
    } catch (e) {
      throw ContentModerationException('Failed to moderate text: $e');
    }
  }
}

class ContentModerationException implements Exception {
  const ContentModerationException(this.message);
  final String message;
  @override
  String toString() => 'ContentModerationException: $message';
}
