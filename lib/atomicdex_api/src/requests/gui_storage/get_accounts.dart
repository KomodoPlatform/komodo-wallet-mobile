import 'package:flutter/foundation.dart';
import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';
import 'package:komodo_dex/atomicdex_api/src/requests/node.dart';

class GetAccountsApiRequestNode
    extends CallableApiRequestsNode<GetAccountsRequest, AtomicDexResponse> {
  GetAccountsApiRequestNode(AtomicDexApiClient client, RequestConfig config)
      : super(client, config);
}

@immutable
class GetAccountsRequest extends AtomicDexRequest {
  GetAccountsRequest({
    required String rpcPassword,
  }) : super(
          rpcPassword: rpcPassword,
          rpcMethod: 'gui_storage::get_accounts',
          version: AtomicDexApiVersion.v2,
          methodParams: null,
          id: null,
        );
}
