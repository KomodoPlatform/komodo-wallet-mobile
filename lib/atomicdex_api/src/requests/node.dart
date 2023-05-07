import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';
import 'package:komodo_dex/services/mm_service.dart';

abstract class ApiRequestsNode {
  ApiRequestsNode(
    this.client,
    this.config,
  );

  final AtomicDexApiClient client;
  final RequestConfig config;
}

class CallableApiRequestsNode<T extends AtomicDexRequest,
    Q extends AtomicDexResponse> extends ApiRequestsNode {
  CallableApiRequestsNode(
    AtomicDexApiClient client,
    RequestConfig config,
  ) : super(client, config);

  Future<Q> _call(T request) async {
    final response = await client.call(request: request);
    return response as Q;
  }

  Future<Q> execute({required T request}) => _call(request);
}
