import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

class AtomicDexApiClient {
  AtomicDexApiClient({
    required this.baseUrl,
  });

  final String baseUrl;
  final http.Client _httpClient = http.Client();

  Future<AtomicDexResponse> call({
    required AtomicDexRequest request,
  }) async {
    final url = Uri.parse(baseUrl);
    final body = jsonEncode(request.body);
    final headers = {'Content-Type': 'application/json'};

    final response = await _httpClient.post(url, body: body, headers: headers);

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
  AtomicDexResponse._({required this.data});

  static AtomicDexResponse fromJson(Map<String, dynamic> json) =>
      AtomicDexResponse._(data: ApiResponseData.parse(json));

  final ApiResponseData data;

  // TODO: Other fields
}

class ApiResponseData {
  final Map<String, dynamic> raw;

  ApiResponseData._({required this.raw});

  static ApiResponseData parse(Map<String, dynamic> json) {
    return ApiResponseData._(raw: json);
  }
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
