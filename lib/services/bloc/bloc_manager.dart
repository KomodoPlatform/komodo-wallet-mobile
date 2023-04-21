part of 'bloc_manager_widget.dart';

class BlocManager {
  static final BlocManager _blocManager = BlocManager._internal();

  static BlocManager get instance => (!_blocManager._isInitialized)
      ? throw Exception('BlocManager is not initialized. Call init() first.')
      : _blocManager;

  // Singleton initialization
  BlocManager._internal();

  static Future<void> init() async {
    if (_blocManager._isInitialized)
      throw Exception('BlocManager is already initialized');

    // Initialize persistance
    await _blocManager._initPersistance();

    await _blocManager._initRepositories();

    // Set initialized
    _blocManager._isInitialized = true;
  }

  //===========================  Repositories  ===========================
  late final SharedPreferences _prefs;

  late final AuthenticationRepository? _authenticationRepository;

  //=====================================================================

  // Is initialized
  bool _isInitialized = false;

  // Initialize HydratedBloc
  Future<void> _initPersistance() async {
    final baseStorageDirectory = await getCachedAppDocumentsDirectory();

    // Initialize HydratedBloc with its own directory.
    final hydratedBlocDirectory =
        Directory('${baseStorageDirectory.path}/hydrated_bloc_data');
    final storage =
        await HydratedStorage.build(storageDirectory: hydratedBlocDirectory);

    // Initialize Hive with its own directory.
    final hivePath = '${baseStorageDirectory.path}/hive_data';
    Hive.init(hivePath);

    HydratedBloc.storage = storage;
  }

  // TODO: After bloc migration is stable, experiement with which init methods
  // are safe to be run in parallel in order to speed up app startup time.
  Future<void> _initRepositories() async {
    try {
      // Initialize sync constructor repositories
      await Db.init();
      final sqlDB = Db.sqlDbInstance;

      // Initialize async repositories which cannot be initialized in parallel
      _prefs = await SharedPreferences.getInstance();

      // Initialize async repositories which can be initialized in parallel
      final futures = <Future<void>>[
        Future(() async {
          _authenticationRepository = AuthenticationRepository(
            prefs: _prefs,
            sqlDB: sqlDB,
            marketMakerService: MarketMakerService.instance,
          );

          CexPrices();

          await _authenticationRepository!.init();
        }),
      ];

      await Future.wait(futures);

      // Initialize repositories which depend on other repositories
    } catch (e) {
      print('Fatal error: Error initializing repositories. App should exit.');
      print(e);
      rethrow;
    }
  }

  final _blocMap = <String, Bloc>{};

  void registerBloc(String key, Bloc bloc) {
    _blocMap[key] = bloc;
  }

  void disposeBloc(String key) {
    _blocMap[key]?.close();
    _blocMap.remove(key);
  }

  void disposeAll() {
    _blocMap.forEach((key, bloc) {
      // Dispose bloc
      bloc.close();

      // Remove bloc from map
      _blocMap.remove(key);
    });

    _blocMap.clear();
  }
}
