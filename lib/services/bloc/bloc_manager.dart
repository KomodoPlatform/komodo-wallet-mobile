import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:komodo_dex/utils/utils.dart';

class BlocManager {
  static final BlocManager _blocManager = BlocManager._internal();

  factory BlocManager() {
    return _blocManager;
  }

  // Singleton initialization
  BlocManager._internal();

  Future<void> init() async {
    if (_isInitialized) throw Exception('BlocManager is already initialized');

    // Initialize persistance
    await _initPersistance();

    // Set initialized
    _isInitialized = true;
  }

  // Is initialized
  bool _isInitialized = false;

  // Initialize HydratedBloc
  Future<void> _initPersistance() async {
    final storage = await HydratedStorage.build(
      storageDirectory: await applicationDocumentsDirectory,
    );

    HydratedBloc.storage = storage;
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
