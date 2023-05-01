import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:komodo_dex/atomicdex_api/src/config/atomicdex_api_config.dart';
import 'package:komodo_dex/atomicdex_api/src/requests/node.dart';

@immutable
class AtomicDexApiClient {
  AtomicDexApiClient({required this.baseUrl});

  final Uri baseUrl;
  final http.Client _httpClient = http.Client();

  Future<AtomicDexResponse> call({
    required AtomicDexRequest request,
  }) async {
    final body = jsonEncode(request.body);
    final headers = {'Content-Type': 'application/json'};

    final response = await _httpClient.post(
      baseUrl,
      body: body,
      headers: headers,
    );

    if (!response.statusCode.toString().startsWith('2')) {
      throw Exception('Failed to call API with status ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return AtomicDexResponse.fromJson(json);
  }
}

/// Default AtomicDex API response data which returns JSON.
///
/// Override this class when defining a new request class if you want a custom
/// response data class.
class AtomicDexResponse {
  AtomicDexResponse({
    required this.data,
    required this.code,
    required this.id,
  });

  static AtomicDexResponse fromJson(Map<String, dynamic> json) =>
      AtomicDexResponse(
        data: json,
        code: json['code'] as int,
        id: json['id'] as int?,
      );

  final Map<String, dynamic> data;

  final int? id;

  final int code;

  bool get isSuccess => code.toString().startsWith('2');

  // TODO: Other fields
}

@immutable
class AtomicDexRequest {
  const AtomicDexRequest({
    required this.rpcPassword,
    required this.rpcMethod,
    required this.version,
    required this.methodParams,
    required this.id,
  });

  factory AtomicDexRequest.withConfig(
    RequestConfig config, {
    required AtomicDexEndpoint endpoint,
    required Map<String, dynamic>? methodParams,
    int? id,
  }) =>
      AtomicDexRequest(
        rpcPassword: config.rpcPassword,
        rpcMethod: endpoint.method,
        version: endpoint.version,
        methodParams: methodParams,
        id: id,
      );

  final int? id;

  final String rpcPassword;
  final String rpcMethod;

  final AtomicDexApiVersion version;

  final Map<String, dynamic>? methodParams;

  static const List<String> _reservedParams = ['userpass', 'method', 'version'];

  Map<String, dynamic> get body {
    // Take a snapshot of the method params to avoid mutation.
    final methodParamsSnapshot = {...methodParams ?? {}};

    final hasReservedParams = _reservedParams.any(
      (element) => (methodParams ?? {}).containsKey(element),
    );

    if (hasReservedParams) {
      throw Exception('Reserved params are not allowed');
    }
    final _body = bodyBuilder();

    assert(methodParamsSnapshot == methodParams,
        'Do not mutate state when building the body');

    return _body;
  }

  /// Logic for merging the method params with the body. Very strong.
  ///
  /// NB! If overriding this, do not mutate state.
  Map<String, dynamic> bodyBuilder() {
    Map<String, dynamic> paramsProcessed = {};

    if (version == AtomicDexApiVersion.v2) {
      paramsProcessed = {
        'userpass': rpcPassword,
        'mmrpc': '2.0',
        'method': rpcMethod,
      };
      if (methodParams != null) paramsProcessed['params'] = methodParams;
    } else if (version == AtomicDexApiVersion.legacy) {
      paramsProcessed = {
        'userpass': rpcPassword,
        'method': rpcMethod,
        ...methodParams ?? {},
      };
    } else {
      throw Exception('Unknown AtomicDex API Version');
    }

    return paramsProcessed;
  }
}

enum AtomicDexApiVersion { legacy, v2 }

extension FutureApiResponseDataConverter on Future<AtomicDexResponse> {
  Future<T> convert<T>(T Function(Map<String, dynamic>) converter) async {
    final response = await this;
    return converter(response.data);
  }
}

extension ApiResponseDataConverter on AtomicDexResponse {
  T convert<T>(T Function(Map<String, dynamic>) converter) {
    return converter(data);
  }
}

@immutable
class RequestConfig {
  RequestConfig({
    required this.rpcPassword,
  });

  final String rpcPassword;

  // Add more configurations if needed
}

@immutable
class AtomicDexEndpoint {
  const AtomicDexEndpoint({
    required this.version,
    required this.method,
  });

  final String method;

  final AtomicDexApiVersion version;
}

// enum AtomicDexApiMethod {
//   guiStorage_getAccounts,
//   guiStorage_activateAccount,
// }

// extension ApiMethodToEndpoint on AtomicDexApiMethod {
//   AtomicDexEndpoint endpoint(AtomicDexApiVersion version) {
//     return AtomicDexEndpoint._(
//       version: version,
//       method: this,
//     );
//   }
// }
