import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';
import 'package:komodo_dex/atomicdex_api/src/requests/gui_storage/get_accounts.dart';
import 'package:komodo_dex/atomicdex_api/src/requests/node.dart';

class GuiStorageApiRequestNode extends ApiRequestsNode {
  GuiStorageApiRequestNode(AtomicDexApiClient client, RequestConfig config)
      : super(client, config);

  Future<AtomicDexResponse> getAccounts(int? id) =>
      CallableApiRequestsNode<GetAccountsRequest, AtomicDexResponse>(
        client,
        config,
      ).execute(
        request: GetAccountsRequest(
          rpcPassword: config.rpcPassword,
        ),
      );
}
