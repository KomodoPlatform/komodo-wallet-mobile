import 'package:komodo_dex/atomicdex_api/src/config/atomicdex_api_config.dart';
import 'package:komodo_dex/atomicdex_api/src/exceptions.dart';
import 'package:komodo_dex/atomicdex_api/src/requests/gui_storage/gui_storage.dart';
import 'package:komodo_dex/atomicdex_api/src/requests/node.dart';

import 'src/models/account/account.dart';
import 'src/models/account/account_id.dart';
import 'src/client.dart';
import 'package:komodo_dex/services/mm_service.dart';

export 'src/models/account/account.dart';
export 'src/models/account/account_id.dart';
export 'src/client.dart';

/// The AtomicDex API
///
/// NB: Not a singleton. Running multiple instances of the API on the same
/// port will cause issues. Running multiple instances in general is not
/// recommended.
///
/// TODO: Future refactor to not rely on MMService singleton.
class AtomicDexApi {
  AtomicDexApi({
    required AtomicDexApiConfig config,
  })  
  // TODO: consider if we need to change the client to be a constructor
  // parameter if we need multiple API instances to share the same client.
  // In theory, the API client should be stateless, so it won't matter if
  // multiple instances share the same client.
  : _client = AtomicDexApiClient(baseUrl: config.baseUrl),
        _rpcPassword = MarketMakerService.instance.generateRpcPassword();

  /// Start up and log in to the AtomicDex API.
  ///
  /// Must be called before using the API.
  Future<void> login({
    required String passphrase,
    required AccountId accountId,
  }) async {
    // TODO: Replace marketmaker service with atomicdex api methods to handle
    // initialising and managing the marketmaker (Atomicdex API) process.
    final apiInstance = MarketMakerService.instance;
    _rpcPassword = apiInstance.generateRpcPassword();

    await MarketMakerService.instance.init(
      passphrase: passphrase,
      rpcPassword: _rpcPassword,
      hdAccountId: accountId is HDAccountId ? accountId.hdId : null,
    );
  }

  String _rpcPassword;

  final AtomicDexApiClient _client;

  // TODO: Check that user has been initialised before calling API
  AtomicDexApiClient get client => _client;

  final AtomicDexApiException _notReadyException =
      AtomicDexApiException('API not ready. Login first.');

  bool get _isApiCallable => MarketMakerService.instance.running;

  RequestConfig get _defaultConfig => RequestConfig(
        rpcPassword: _rpcPassword,
      );

  T _canApiCall<T extends ApiRequestsNode>(T node) {
    return _isApiCallable ? node : throw _notReadyException;
  }

  AtomicDexApiV2Methods get v2 => _canApiCall(
        AtomicDexApiV2Methods(_client, _defaultConfig),
      );

  // ignore: deprecated_member_use_from_same_package
  AtomicDexApiLegacyMethods get legacy => _canApiCall(
        // ignore: deprecated_member_use_from_same_package
        AtomicDexApiLegacyMethods(_client, _defaultConfig),
      );
}

class AtomicDexApiV2Methods extends ApiRequestsNode {
  AtomicDexApiV2Methods(AtomicDexApiClient client, RequestConfig config)
      : super(client, config);

  GuiStorageApiRequestNode get guiStorage =>
      GuiStorageApiRequestNode(client, config);
}

@Deprecated('Use AtomicDexApi2Methods instead')
class AtomicDexApiLegacyMethods extends ApiRequestsNode {
  AtomicDexApiLegacyMethods(AtomicDexApiClient client, RequestConfig config)
      : super(client, config);

  GuiStorageApiRequestNode get guiStorage =>
      GuiStorageApiRequestNode(client, config);
}
