import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';

class EnableAccountRequest extends AtomicDexRequest {
  EnableAccountRequest({
    required String rpcPassword,
    required String policy,
    required AccountId accountId,
    String? name,
    String? description,
    double? balanceUsd,
  }) : super(
          rpcPassword: rpcPassword,
          rpcMethod: 'gui_storage::enable_account',
          version: AtomicDexApiVersion.v2,
          methodParams: {
            'policy': policy,
            'account_id': accountId.toJson(),
            if (name != null) 'name': name,
            if (description != null) 'description': description,
            if (balanceUsd != null) 'balance_usd': balanceUsd,
          },
          id: null,
        );
}
