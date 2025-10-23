// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riverpod_codegen_example.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$helloWorldHash() => r'ea721097ce01b1f980f0840bc365b8a66e7468bb';

/// Riverpod Code Generation Examples
///
/// This file demonstrates how to use Riverpod code generation to reduce boilerplate.
/// Instead of manually creating providers, we use annotations to generate them automatically.
///
/// Benefits of Code Generation:
/// 1. **Less Boilerplate:** No need to manually create provider instances
/// 2. **Type Safety:** Compile-time type checking for all providers
/// 3. **Auto-Dispose:** Automatic resource cleanup when providers are no longer needed
/// 4. **Family Providers:** Simplified syntax for parameterized providers
/// 5. **Better IDE Support:** Auto-completion and refactoring support
///
/// ## Setup
///
/// 1. Add dependencies to pubspec.yaml:
/// ```yaml
/// dependencies:
///   flutter_riverpod: ^2.4.9
///   riverpod_annotation: ^2.3.3
///
/// dev_dependencies:
///   build_runner: ^2.4.7
///   riverpod_generator: ^2.3.9
///   riverpod_lint: ^2.3.7
/// ```
///
/// 2. Generate code:
/// ```bash
/// # One-time generation
/// flutter pub run build_runner build --delete-conflicting-outputs
///
/// # Watch mode (auto-regenerate on file changes)
/// flutter pub run build_runner watch --delete-conflicting-outputs
/// ```
///
/// ## Examples
/// Simple provider that returns a constant value.
///
/// Before (manual):
/// ```dart
/// final helloWorldProvider = Provider<String>((ref) => 'Hello World');
/// ```
///
/// After (code generation):
///
/// Copied from [helloWorld].
@ProviderFor(helloWorld)
final helloWorldProvider = AutoDisposeProvider<String>.internal(
  helloWorld,
  name: r'helloWorldProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$helloWorldHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HelloWorldRef = AutoDisposeProviderRef<String>;
String _$fetchDataHash() => r'11466a60e52518f35202856bb4c0474636ff1d71';

/// Future provider that fetches data asynchronously.
///
/// Before (manual):
/// ```dart
/// final fetchDataProvider = FutureProvider<String>((ref) async {
///   await Future.delayed(Duration(seconds: 2));
///   return 'Data loaded';
/// });
/// ```
///
/// After (code generation):
///
/// Copied from [fetchData].
@ProviderFor(fetchData)
final fetchDataProvider = AutoDisposeFutureProvider<String>.internal(
  fetchData,
  name: r'fetchDataProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fetchDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FetchDataRef = AutoDisposeFutureProviderRef<String>;
String _$counterStreamHash() => r'79aa2a95f1b45f543edca143ded0a255b049eb1e';

/// Stream provider that emits values over time.
///
/// Before (manual):
/// ```dart
/// final counterStreamProvider = StreamProvider<int>((ref) {
///   return Stream.periodic(Duration(seconds: 1), (count) => count);
/// });
/// ```
///
/// After (code generation):
///
/// Copied from [counterStream].
@ProviderFor(counterStream)
final counterStreamProvider = AutoDisposeStreamProvider<int>.internal(
  counterStream,
  name: r'counterStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$counterStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CounterStreamRef = AutoDisposeStreamProviderRef<int>;
String _$userByIdHash() => r'41247508e554703aebb6c5a4a6d74a88935f49bf';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Family provider that accepts parameters.
///
/// Before (manual):
/// ```dart
/// final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
///   return await fetchUser(userId);
/// });
/// ```
///
/// After (code generation):
///
/// Copied from [userById].
@ProviderFor(userById)
const userByIdProvider = UserByIdFamily();

/// Family provider that accepts parameters.
///
/// Before (manual):
/// ```dart
/// final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
///   return await fetchUser(userId);
/// });
/// ```
///
/// After (code generation):
///
/// Copied from [userById].
class UserByIdFamily extends Family<AsyncValue<User>> {
  /// Family provider that accepts parameters.
  ///
  /// Before (manual):
  /// ```dart
  /// final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
  ///   return await fetchUser(userId);
  /// });
  /// ```
  ///
  /// After (code generation):
  ///
  /// Copied from [userById].
  const UserByIdFamily();

  /// Family provider that accepts parameters.
  ///
  /// Before (manual):
  /// ```dart
  /// final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
  ///   return await fetchUser(userId);
  /// });
  /// ```
  ///
  /// After (code generation):
  ///
  /// Copied from [userById].
  UserByIdProvider call(
    String userId,
  ) {
    return UserByIdProvider(
      userId,
    );
  }

  @override
  UserByIdProvider getProviderOverride(
    covariant UserByIdProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userByIdProvider';
}

/// Family provider that accepts parameters.
///
/// Before (manual):
/// ```dart
/// final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
///   return await fetchUser(userId);
/// });
/// ```
///
/// After (code generation):
///
/// Copied from [userById].
class UserByIdProvider extends AutoDisposeFutureProvider<User> {
  /// Family provider that accepts parameters.
  ///
  /// Before (manual):
  /// ```dart
  /// final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
  ///   return await fetchUser(userId);
  /// });
  /// ```
  ///
  /// After (code generation):
  ///
  /// Copied from [userById].
  UserByIdProvider(
    String userId,
  ) : this._internal(
          (ref) => userById(
            ref as UserByIdRef,
            userId,
          ),
          from: userByIdProvider,
          name: r'userByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userByIdHash,
          dependencies: UserByIdFamily._dependencies,
          allTransitiveDependencies: UserByIdFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<User> Function(UserByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserByIdProvider._internal(
        (ref) => create(ref as UserByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<User> createElement() {
    return _UserByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserByIdProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UserByIdRef on AutoDisposeFutureProviderRef<User> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserByIdProviderElement extends AutoDisposeFutureProviderElement<User>
    with UserByIdRef {
  _UserByIdProviderElement(super.provider);

  @override
  String get userId => (origin as UserByIdProvider).userId;
}

String _$searchResultsHash() => r'b03e14261dc35f01b023d1bd45f038e184dcfd0e';

/// Auto-dispose provider that cleans up when no longer used.
///
/// Before (manual):
/// ```dart
/// final searchResultsProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
///   return await search(query);
/// });
/// ```
///
/// After (code generation):
/// Note: All @riverpod providers are auto-dispose by default!
///
/// Copied from [searchResults].
@ProviderFor(searchResults)
const searchResultsProvider = SearchResultsFamily();

/// Auto-dispose provider that cleans up when no longer used.
///
/// Before (manual):
/// ```dart
/// final searchResultsProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
///   return await search(query);
/// });
/// ```
///
/// After (code generation):
/// Note: All @riverpod providers are auto-dispose by default!
///
/// Copied from [searchResults].
class SearchResultsFamily extends Family<AsyncValue<List<String>>> {
  /// Auto-dispose provider that cleans up when no longer used.
  ///
  /// Before (manual):
  /// ```dart
  /// final searchResultsProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
  ///   return await search(query);
  /// });
  /// ```
  ///
  /// After (code generation):
  /// Note: All @riverpod providers are auto-dispose by default!
  ///
  /// Copied from [searchResults].
  const SearchResultsFamily();

  /// Auto-dispose provider that cleans up when no longer used.
  ///
  /// Before (manual):
  /// ```dart
  /// final searchResultsProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
  ///   return await search(query);
  /// });
  /// ```
  ///
  /// After (code generation):
  /// Note: All @riverpod providers are auto-dispose by default!
  ///
  /// Copied from [searchResults].
  SearchResultsProvider call(
    String query,
  ) {
    return SearchResultsProvider(
      query,
    );
  }

  @override
  SearchResultsProvider getProviderOverride(
    covariant SearchResultsProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchResultsProvider';
}

/// Auto-dispose provider that cleans up when no longer used.
///
/// Before (manual):
/// ```dart
/// final searchResultsProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
///   return await search(query);
/// });
/// ```
///
/// After (code generation):
/// Note: All @riverpod providers are auto-dispose by default!
///
/// Copied from [searchResults].
class SearchResultsProvider extends AutoDisposeFutureProvider<List<String>> {
  /// Auto-dispose provider that cleans up when no longer used.
  ///
  /// Before (manual):
  /// ```dart
  /// final searchResultsProvider = FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
  ///   return await search(query);
  /// });
  /// ```
  ///
  /// After (code generation):
  /// Note: All @riverpod providers are auto-dispose by default!
  ///
  /// Copied from [searchResults].
  SearchResultsProvider(
    String query,
  ) : this._internal(
          (ref) => searchResults(
            ref as SearchResultsRef,
            query,
          ),
          from: searchResultsProvider,
          name: r'searchResultsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchResultsHash,
          dependencies: SearchResultsFamily._dependencies,
          allTransitiveDependencies:
              SearchResultsFamily._allTransitiveDependencies,
          query: query,
        );

  SearchResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<String>> Function(SearchResultsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchResultsProvider._internal(
        (ref) => create(ref as SearchResultsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<String>> createElement() {
    return _SearchResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SearchResultsRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchResultsProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with SearchResultsRef {
  _SearchResultsProviderElement(super.provider);

  @override
  String get query => (origin as SearchResultsProvider).query;
}

String _$appConfigHash() => r'5adf359025e98939b15c25ceaa3b5ee6d39194ff';

/// Keep-alive provider that persists even when not watched.
///
/// Use @Riverpod(keepAlive: true) to disable auto-dispose.
///
/// Copied from [appConfig].
@ProviderFor(appConfig)
final appConfigProvider = FutureProvider<AppConfig>.internal(
  appConfig,
  name: r'appConfigProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppConfigRef = FutureProviderRef<AppConfig>;
String _$userProfileHash() => r'cba046e26dd5c1d59d1e99b777fb9d4aa09d865e';

/// Provider that depends on other providers.
///
/// Copied from [userProfile].
@ProviderFor(userProfile)
const userProfileProvider = UserProfileFamily();

/// Provider that depends on other providers.
///
/// Copied from [userProfile].
class UserProfileFamily extends Family<AsyncValue<UserProfile>> {
  /// Provider that depends on other providers.
  ///
  /// Copied from [userProfile].
  const UserProfileFamily();

  /// Provider that depends on other providers.
  ///
  /// Copied from [userProfile].
  UserProfileProvider call(
    String userId,
  ) {
    return UserProfileProvider(
      userId,
    );
  }

  @override
  UserProfileProvider getProviderOverride(
    covariant UserProfileProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userProfileProvider';
}

/// Provider that depends on other providers.
///
/// Copied from [userProfile].
class UserProfileProvider extends AutoDisposeFutureProvider<UserProfile> {
  /// Provider that depends on other providers.
  ///
  /// Copied from [userProfile].
  UserProfileProvider(
    String userId,
  ) : this._internal(
          (ref) => userProfile(
            ref as UserProfileRef,
            userId,
          ),
          from: userProfileProvider,
          name: r'userProfileProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userProfileHash,
          dependencies: UserProfileFamily._dependencies,
          allTransitiveDependencies:
              UserProfileFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<UserProfile> Function(UserProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserProfileProvider._internal(
        (ref) => create(ref as UserProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserProfile> createElement() {
    return _UserProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UserProfileRef on AutoDisposeFutureProviderRef<UserProfile> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserProfileProviderElement
    extends AutoDisposeFutureProviderElement<UserProfile> with UserProfileRef {
  _UserProfileProviderElement(super.provider);

  @override
  String get userId => (origin as UserProfileProvider).userId;
}

String _$timerWithCleanupHash() => r'd3d4292018680fd0067b81d1c365fadb0e0e1cdc';

/// Provider with lifecycle management.
///
/// Copied from [timerWithCleanup].
@ProviderFor(timerWithCleanup)
final timerWithCleanupProvider = AutoDisposeStreamProvider<int>.internal(
  timerWithCleanup,
  name: r'timerWithCleanupProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timerWithCleanupHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TimerWithCleanupRef = AutoDisposeStreamProviderRef<int>;
String _$fetchDataWithErrorHash() =>
    r'3cd01b1cd50d21e8e1d40738a1afd1116031b612';

/// Provider with built-in error handling.
///
/// Copied from [fetchDataWithError].
@ProviderFor(fetchDataWithError)
final fetchDataWithErrorProvider = AutoDisposeFutureProvider<String>.internal(
  fetchDataWithError,
  name: r'fetchDataWithErrorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fetchDataWithErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FetchDataWithErrorRef = AutoDisposeFutureProviderRef<String>;
String _$cachedPostsHash() => r'c796f7066947530d51bd1f28498a045cc7bba1bc';

/// Provider with manual cache control.
///
/// Copied from [cachedPosts].
@ProviderFor(cachedPosts)
final cachedPostsProvider = AutoDisposeFutureProvider<List<Post>>.internal(
  cachedPosts,
  name: r'cachedPostsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cachedPostsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CachedPostsRef = AutoDisposeFutureProviderRef<List<Post>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
