// Flutter Chekmate - Firebase + Riverpod ML Prediction Models
// Production-ready predictive analytics with Firebase Firestore integration

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod/riverpod.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

// ============= RIVERPOD PROVIDERS =============

// Firebase Providers
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});

// Data Lake Collection Providers
final bronzeLayerProvider = StreamProvider<List<BronzeRecord>>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore
      .collection('data_lake')
      .doc('bronze')
      .collection('records')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => BronzeRecord.fromFirestore(doc))
          .toList());
});

final silverLayerProvider = StreamProvider<List<SilverRecord>>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore
      .collection('data_lake')
      .doc('silver')
      .collection('snapshots')
      .orderBy('processingTimestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => SilverRecord.fromFirestore(doc))
          .toList());
});

final goldLayerProvider = StreamProvider<GoldIntelligence>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore
      .collection('data_lake')
      .doc('gold')
      .collection('intelligence')
      .orderBy('generatedAt', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) => snapshot.docs.isNotEmpty
          ? GoldIntelligence.fromFirestore(snapshot.docs.first)
          : GoldIntelligence.empty());
});

// ML Model Providers
final mlPredictionEngineProvider = StateNotifierProvider<MLPredictionEngineNotifier, MLPredictionState>((ref) {
  return MLPredictionEngineNotifier(ref);
});

final complexityPredictorProvider = FutureProvider<ComplexityPrediction>((ref) async {
  final engine = ref.watch(mlPredictionEngineProvider);
  final silverData = await ref.watch(silverLayerProvider.future);
  return engine.predictComplexityGrowth(silverData);
});

final technicalDebtProvider = FutureProvider<TechnicalDebtAnalysis>((ref) async {
  final engine = ref.watch(mlPredictionEngineProvider);
  final goldData = await ref.watch(goldLayerProvider.future);
  return engine.analyzeTechnicalDebt(goldData);
});

final refactoringRecommendationsProvider = StreamProvider<List<RefactoringRecommendation>>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore
      .collection('ml_predictions')
      .doc('refactoring')
      .collection('recommendations')
      .where('priority', isEqualTo: 'HIGH')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => RefactoringRecommendation.fromFirestore(doc))
          .toList());
});

// ============= ML MODELS WITH FIREBASE =============

class MLPredictionEngineNotifier extends StateNotifier<MLPredictionState> {
  final Ref ref;
  late final FirebaseFirestore _firestore;
  late final FirebaseAnalytics _analytics;
  
  // ML Models
  late LinearRegressor _complexityModel;
  late KnnClassifier _patternClassifier;
  late RandomForestRegressor _technicalDebtModel;
  late GradientBoostingClassifier _securityModel;
  
  MLPredictionEngineNotifier(this.ref) : super(MLPredictionState.initial()) {
    _firestore = ref.read(firebaseFirestoreProvider);
    _analytics = ref.read(firebaseAnalyticsProvider);
    _initializeModels();
  }
  
  Future<void> _initializeModels() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Load training data from Firestore
      final trainingData = await _loadTrainingData();
      
      // Train models
      await _trainComplexityModel(trainingData);
      await _trainPatternClassifier(trainingData);
      await _trainTechnicalDebtModel(trainingData);
      await _trainSecurityModel(trainingData);
      
      // Save model metrics to Firestore
      await _saveModelMetrics();
      
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        lastTrainingTime: DateTime.now(),
      );
      
      // Log to Firebase Analytics
      await _analytics.logEvent(
        name: 'ml_models_initialized',
        parameters: {
          'models_count': 4,
          'training_samples': trainingData.length,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<List<TrainingDataPoint>> _loadTrainingData() async {
    final snapshot = await _firestore
        .collection('training_data')
        .orderBy('timestamp', descending: true)
        .limit(1000)
        .get();
    
    return snapshot.docs
        .map((doc) => TrainingDataPoint.fromFirestore(doc))
        .toList();
  }
  
  Future<void> _trainComplexityModel(List<TrainingDataPoint> data) async {
    // Prepare DataFrame for ML
    final features = <String, List<num>>{
      'fileCount': data.map((d) => d.fileCount.toDouble()).toList(),
      'dependencies': data.map((d) => d.dependencyCount.toDouble()).toList(),
      'avgCyclomaticComplexity': data.map((d) => d.avgCyclomaticComplexity).toList(),
      'linesOfCode': data.map((d) => d.linesOfCode.toDouble()).toList(),
    };
    
    final targets = data.map((d) => d.futureComplexity).toList();
    
    final dataFrame = DataFrame(features);
    
    // Train Linear Regression model
    _complexityModel = LinearRegressor(
      dataFrame,
      targetName: 'complexity',
      iterationsLimit: 1000,
      learningRateType: LearningRateType.adaptive,
    );
  }
  
  Future<ComplexityPrediction> predictComplexityGrowth(List<SilverRecord> historicalData) async {
    if (!state.isInitialized) {
      await _initializeModels();
    }
    
    // Extract current metrics
    final currentMetrics = _extractMetrics(historicalData.first);
    
    // Predict using trained model
    final dataFrame = DataFrame.fromMatrix([
      [
        currentMetrics.fileCount,
        currentMetrics.dependencyCount,
        currentMetrics.avgCyclomaticComplexity,
        currentMetrics.linesOfCode,
      ]
    ]);
    
    final prediction = _complexityModel.predict(dataFrame);
    
    // Generate time series prediction
    final timeSeries = <TimeSeriesPoint>[];
    var metrics = currentMetrics;
    
    for (int day = 1; day <= 30; day++) {
      // Apply growth factors
      metrics = _applyGrowthFactors(metrics, day);
      
      final futureDataFrame = DataFrame.fromMatrix([
        [
          metrics.fileCount,
          metrics.dependencyCount,
          metrics.avgCyclomaticComplexity,
          metrics.linesOfCode,
        ]
      ]);
      
      final futurePrediction = _complexityModel.predict(futureDataFrame);
      
      timeSeries.add(TimeSeriesPoint(
        timestamp: DateTime.now().add(Duration(days: day)),
        value: futurePrediction.rows.first.first,
        confidence: _calculateConfidence(day),
      ));
    }
    
    // Save prediction to Firestore
    final predictionDoc = {
      'timestamp': FieldValue.serverTimestamp(),
      'currentComplexity': currentMetrics.avgCyclomaticComplexity,
      'predicted30Day': timeSeries.last.value,
      'growthRate': (timeSeries.last.value - currentMetrics.avgCyclomaticComplexity) / 30,
      'timeSeries': timeSeries.map((p) => p.toMap()).toList(),
    };
    
    await _firestore
        .collection('ml_predictions')
        .doc('complexity')
        .collection('predictions')
        .add(predictionDoc);
    
    return ComplexityPrediction(
      current: currentMetrics.avgCyclomaticComplexity,
      predicted30Day: timeSeries.last.value,
      timeSeries: timeSeries,
      confidence: 0.85,
    );
  }
  
  Future<TechnicalDebtAnalysis> analyzeTechnicalDebt(GoldIntelligence goldData) async {
    // Calculate technical debt using Random Forest
    final features = _extractDebtFeatures(goldData);
    
    final dataFrame = DataFrame.fromMatrix([features]);
    final debtPrediction = _technicalDebtModel.predict(dataFrame);
    
    final debtHours = debtPrediction.rows.first.first;
    
    // Identify debt hotspots
    final hotspots = await _identifyDebtHotspots();
    
    // Calculate ROI for refactoring
    final roiAnalysis = _calculateRefactoringROI(debtHours, hotspots);
    
    // Save to Firestore
    final analysisDoc = {
      'timestamp': FieldValue.serverTimestamp(),
      'totalDebtHours': debtHours,
      'debtCost': debtHours * 150, // $150/hour average
      'hotspots': hotspots.map((h) => h.toMap()).toList(),
      'recommendedActions': roiAnalysis.recommendations,
      'estimatedROI': roiAnalysis.roi,
    };
    
    await _firestore
        .collection('ml_predictions')
        .doc('technical_debt')
        .set(analysisDoc, SetOptions(merge: true));
    
    return TechnicalDebtAnalysis(
      totalHours: debtHours,
      hotspots: hotspots,
      roiAnalysis: roiAnalysis,
    );
  }
  
  Future<List<SecurityVulnerability>> predictSecurityIssues() async {
    // Query recent code patterns
    final patterns = await _firestore
        .collection('code_patterns')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();
    
    final vulnerabilities = <SecurityVulnerability>[];
    
    for (final pattern in patterns.docs) {
      final features = _extractSecurityFeatures(pattern.data());
      final dataFrame = DataFrame.fromMatrix([features]);
      
      final prediction = _securityModel.predict(dataFrame);
      final riskScore = prediction.rows.first.first;
      
      if (riskScore > 0.7) {
        vulnerabilities.add(SecurityVulnerability(
          file: pattern.data()['file'],
          type: _classifyVulnerabilityType(pattern.data()),
          severity: _calculateSeverity(riskScore),
          recommendation: _generateSecurityRecommendation(pattern.data()),
        ));
      }
    }
    
    // Store high-risk vulnerabilities in Firestore
    if (vulnerabilities.isNotEmpty) {
      await _firestore
          .collection('security_alerts')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'vulnerabilities': vulnerabilities.map((v) => v.toMap()).toList(),
        'criticalCount': vulnerabilities.where((v) => v.severity == 'CRITICAL').length,
      });
    }
    
    return vulnerabilities;
  }
}

// ============= DATA MODELS =============

class MLPredictionState {
  final bool isLoading;
  final bool isInitialized;
  final String? error;
  final DateTime? lastTrainingTime;
  final Map<String, double> modelAccuracy;
  
  MLPredictionState({
    required this.isLoading,
    required this.isInitialized,
    this.error,
    this.lastTrainingTime,
    this.modelAccuracy = const {},
  });
  
  factory MLPredictionState.initial() => MLPredictionState(
    isLoading: false,
    isInitialized: false,
  );
  
  MLPredictionState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? error,
    DateTime? lastTrainingTime,
    Map<String, double>? modelAccuracy,
  }) {
    return MLPredictionState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
      lastTrainingTime: lastTrainingTime ?? this.lastTrainingTime,
      modelAccuracy: modelAccuracy ?? this.modelAccuracy,
    );
  }
}

// ============= FIREBASE INTEGRATION HELPERS =============

extension FirestoreSync on MLPredictionEngineNotifier {
  // Real-time sync predictions to Firestore
  Stream<void> syncPredictionsToFirestore() {
    return Stream.periodic(Duration(minutes: 5), (_) async {
      final silverData = await ref.read(silverLayerProvider.future);
      
      if (silverData.isNotEmpty) {
        // Run all predictions
        final complexity = await predictComplexityGrowth(silverData);
        final goldData = await ref.read(goldLayerProvider.future);
        final debt = await analyzeTechnicalDebt(goldData);
        final security = await predictSecurityIssues();
        
        // Create aggregated prediction document
        await _firestore
            .collection('ml_predictions')
            .doc('latest')
            .set({
          'timestamp': FieldValue.serverTimestamp(),
          'complexity': complexity.toMap(),
          'technicalDebt': debt.toMap(),
          'securityIssues': security.map((s) => s.toMap()).toList(),
          'modelVersion': '2.0.0',
        });
        
        // Trigger Cloud Function for notifications if critical
        if (complexity.predicted30Day > 100 || debt.totalHours > 100) {
          await _firestore.collection('alerts').add({
            'type': 'CRITICAL_PREDICTION',
            'timestamp': FieldValue.serverTimestamp(),
            'complexity': complexity.predicted30Day,
            'debt': debt.totalHours,
            'notify': true,
          });
        }
      }
    }).listen((_) {});
  }
}