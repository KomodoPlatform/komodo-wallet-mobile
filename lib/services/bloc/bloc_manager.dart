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

  late final WalletsRepository _walletRepository;

  late final AccountRepository _accountRepository;

  late final ActiveAccountRepository _activeAccountRepository;

  final AtomicDexApi _atomicDexApi = AtomicDexApi(
    config: AtomicDexApiConfig(port: appConfig.rpcPort),
  );

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
      // await Db.init();
      final sqlDB = await Db.db;

      // Initialize async repositories which cannot be initialized in parallel
      _prefs = await SharedPreferences.getInstance();

      final walletStorageApi = await WalletStorageApi.create();

      _authenticationRepository = await AuthenticationRepository.instantiate(
        sqlDB: sqlDB,
        marketMakerService: MarketMakerService.instance,
        walletStorageApi: walletStorageApi,
        atomicDexApi: _atomicDexApi,
      );

      // Initialize async repositories which can be initialized in parallel
      final futures = <Future<void>>[
        Future(() async {
          _accountRepository = AccountRepository(
            authenticationRepository: _authenticationRepository!,
          );
        }),
        CexPrices.init(),
        Future(
          () async => _walletRepository = await WalletsRepository.create(
            walletStorageApi: walletStorageApi,
          ),
        ),
      ];

      await Future.wait(futures);

      _activeAccountRepository = ActiveAccountRepository(
        accountRepository: _accountRepository,
        authenticationRepository: _authenticationRepository!,
        atomicDexApi: _atomicDexApi,
      );

      // Initialize repositories which depend on other repositories

      // Acts as a bridge between the legact code and new storage. Legacy code
      // does not need to be concerned with the multi-wallet support because
      // we will handle it as if the accounts are separate wallets.
      await LegacyDatabaseAdapter.init(
        activeAccountRepository: _activeAccountRepository,
        walletsRepository: _walletRepository,
        authenticationRepository: _authenticationRepository!,
      );
    } catch (e) {
      print('Fatal error: Error initializing repositories. App should exit.');
      print(e);
      rethrow;
    }
  }
}
