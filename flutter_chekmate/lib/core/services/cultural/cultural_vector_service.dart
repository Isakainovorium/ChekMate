import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_chekmate/core/services/cultural/location_context_service.dart';

/// Service for generating and managing cultural vector embeddings
/// Uses Sentence Transformers model for text-to-vector conversion
class CulturalVectorService {
  final String _embeddingServiceUrl;
  final http.Client _httpClient;
  static const int vectorDimension = 384; // all-MiniLM-L6-v2 dimension

  CulturalVectorService({
    String? embeddingServiceUrl,
    http.Client? httpClient,
  })  : _embeddingServiceUrl = embeddingServiceUrl ??
            const String.fromEnvironment('EMBEDDING_SERVICE_URL',
                defaultValue: 'http://localhost:8080/embeddings'),
        _httpClient = httpClient ?? http.Client();

  /// Generate embedding vector from text description
  Future<List<double>> generateEmbedding(String text) async {
    if (text.isEmpty) {
      return List.filled(vectorDimension, 0.0);
    }

    try {
      // For local development, use mock embeddings
      // In production, this would call the actual embedding service
      if (_embeddingServiceUrl.contains('localhost')) {
        return _generateMockEmbedding(text);
      }

      final response = await _httpClient.post(
        Uri.parse(_embeddingServiceUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'model': 'all-MiniLM-L6-v2',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final embedding = (data['embedding'] as List)
            .map((e) => (e as num).toDouble())
            .toList();

        if (embedding.length != vectorDimension) {
          throw Exception(
              'Invalid embedding dimension: ${embedding.length} != $vectorDimension');
        }

        return embedding;
      } else {
        throw Exception('Failed to generate embedding: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating embedding: $e');
      // Fallback to mock embedding in case of error
      return _generateMockEmbedding(text);
    }
  }

  /// Generate embeddings for multiple texts in batch
  Future<List<List<double>>> generateBatchEmbeddings(
    List<String> texts,
  ) async {
    if (texts.isEmpty) {
      return [];
    }

    try {
      // For local development, use mock embeddings
      if (_embeddingServiceUrl.contains('localhost')) {
        return texts.map((text) => _generateMockEmbedding(text)).toList();
      }

      final response = await _httpClient.post(
        Uri.parse('$_embeddingServiceUrl/batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'texts': texts,
          'model': 'all-MiniLM-L6-v2',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final embeddings = (data['embeddings'] as List)
            .map((embedding) =>
                (embedding as List).map((e) => (e as num).toDouble()).toList())
            .toList();

        return embeddings;
      } else {
        throw Exception(
            'Failed to generate batch embeddings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating batch embeddings: $e');
      // Fallback to mock embeddings
      return texts.map((text) => _generateMockEmbedding(text)).toList();
    }
  }

  /// Calculate cosine similarity between two vectors
  static double calculateCosineSimilarity(
    List<double> vector1,
    List<double> vector2,
  ) {
    if (vector1.length != vector2.length) {
      throw ArgumentError('Vectors must have the same dimension');
    }

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < vector1.length; i++) {
      dotProduct += vector1[i] * vector2[i];
      norm1 += vector1[i] * vector1[i];
      norm2 += vector2[i] * vector2[i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) {
      return 0.0;
    }

    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }

  /// Find most similar vectors from a list
  List<SimilarityResult> findMostSimilar({
    required List<double> queryVector,
    required List<VectorDocument> documents,
    int topK = 10,
    double minSimilarity = 0.0,
  }) {
    final results = <SimilarityResult>[];

    for (final doc in documents) {
      final similarity = calculateCosineSimilarity(queryVector, doc.vector);

      if (similarity >= minSimilarity) {
        results.add(SimilarityResult(
          documentId: doc.id,
          similarity: similarity,
          metadata: doc.metadata,
        ));
      }
    }

    // Sort by similarity (descending)
    results.sort((a, b) => b.similarity.compareTo(a.similarity));

    // Return top K results
    return results.take(topK).toList();
  }

  /// Combine multiple vectors using weighted average
  List<double> combineVectors(
    List<List<double>> vectors,
    List<double>? weights,
  ) {
    if (vectors.isEmpty) {
      return List.filled(vectorDimension, 0.0);
    }

    // Use equal weights if not provided
    final vectorWeights =
        weights ?? List.filled(vectors.length, 1.0 / vectors.length);

    if (vectors.length != vectorWeights.length) {
      throw ArgumentError('Number of vectors and weights must match');
    }

    // Initialize combined vector
    final combined = List.filled(vectorDimension, 0.0);

    // Weighted sum
    for (int i = 0; i < vectors.length; i++) {
      final vector = vectors[i];
      final weight = vectorWeights[i];

      for (int j = 0; j < vectorDimension; j++) {
        combined[j] += vector[j] * weight;
      }
    }

    // Normalize the combined vector
    return _normalizeVector(combined);
  }

  /// Normalize a vector to unit length
  List<double> _normalizeVector(List<double> vector) {
    double norm = 0.0;
    for (final value in vector) {
      norm += value * value;
    }

    if (norm == 0.0) {
      return vector;
    }

    norm = sqrt(norm);
    return vector.map((v) => v / norm).toList();
  }

  /// Generate a deterministic mock embedding from text
  /// Used for local development and testing
  List<double> _generateMockEmbedding(String text) {
    final random = Random(text.hashCode);
    final embedding = List.generate(
      vectorDimension,
      (_) => (random.nextDouble() - 0.5) * 2.0, // Range: -1.0 to 1.0
    );

    // Normalize to unit vector
    return _normalizeVector(embedding);
  }

  /// Calculate centroid of multiple vectors
  List<double> calculateCentroid(List<List<double>> vectors) {
    if (vectors.isEmpty) {
      return List.filled(vectorDimension, 0.0);
    }

    final centroid = List.filled(vectorDimension, 0.0);

    // Sum all vectors
    for (final vector in vectors) {
      for (int i = 0; i < vectorDimension; i++) {
        centroid[i] += vector[i];
      }
    }

    // Average
    for (int i = 0; i < vectorDimension; i++) {
      centroid[i] /= vectors.length;
    }

    return _normalizeVector(centroid);
  }

  /// Calculate diversity score for a set of vectors
  /// Higher score means more diverse cultural profiles
  double calculateDiversityScore(List<List<double>> vectors) {
    if (vectors.length < 2) {
      return 0.0;
    }

    double totalDistance = 0.0;
    int comparisons = 0;

    for (int i = 0; i < vectors.length - 1; i++) {
      for (int j = i + 1; j < vectors.length; j++) {
        final similarity = calculateCosineSimilarity(vectors[i], vectors[j]);
        totalDistance += (1.0 - similarity); // Convert similarity to distance
        comparisons++;
      }
    }

    return comparisons > 0 ? totalDistance / comparisons : 0.0;
  }

  /// Generate cultural vector with location context included
  Future<List<double>> generateCulturalVectorWithLocation({
    required String? heritageDescription,
    required List<String> communityAffiliations,
    required String? generationalIdentity,
    required List<String> culturalPractices,
    required List<String> culturalInterests,
    required String? regionalInfluence,
    required LocationContext? locationContext,
  }) async {
    // Combine cultural inputs with location data
    final combinedText = _combineInputsWithLocation(
      heritageDescription: heritageDescription,
      communityAffiliations: communityAffiliations,
      generationalIdentity: generationalIdentity,
      culturalPractices: culturalPractices,
      culturalInterests: culturalInterests,
      regionalInfluence: regionalInfluence,
      locationContext: locationContext,
    );

    // Generate embedding
    return await generateEmbedding(combinedText);
  }

  String _combineInputsWithLocation({
    required String? heritageDescription,
    required List<String> communityAffiliations,
    required String? generationalIdentity,
    required List<String> culturalPractices,
    required List<String> culturalInterests,
    required String? regionalInfluence,
    required LocationContext? locationContext,
  }) {
    final parts = <String>[];

    // Cultural inputs
    if (heritageDescription?.isNotEmpty ?? false) {
      parts.add('Heritage: $heritageDescription');
    }
    if (communityAffiliations.isNotEmpty) {
      parts.add('Communities: ${communityAffiliations.join(", ")}');
    }
    if (generationalIdentity?.isNotEmpty ?? false) {
      parts.add('Generation: $generationalIdentity');
    }
    if (culturalPractices.isNotEmpty) {
      parts.add('Practices: ${culturalPractices.join(", ")}');
    }
    if (culturalInterests.isNotEmpty) {
      parts.add('Interests: ${culturalInterests.join(", ")}');
    }
    if (regionalInfluence?.isNotEmpty ?? false) {
      parts.add('Regional influence: $regionalInfluence');
    }

    // Add location context
    if (locationContext != null) {
      parts.add('Location: ${locationContext.locationDescription}');
      if (locationContext.locationKeywords.isNotEmpty) {
        parts.add(
            'Regional context: ${locationContext.locationKeywords.join(", ")}');
      }
    }

    return parts.join('. ');
  }

  /// Dispose of resources
  void dispose() {
    _httpClient.close();
  }
}

/// Document with vector embedding
class VectorDocument {
  final String id;
  final List<double> vector;
  final Map<String, dynamic>? metadata;

  VectorDocument({
    required this.id,
    required this.vector,
    this.metadata,
  });
}

/// Result of similarity search
class SimilarityResult {
  final String documentId;
  final double similarity;
  final Map<String, dynamic>? metadata;

  SimilarityResult({
    required this.documentId,
    required this.similarity,
    this.metadata,
  });
}
