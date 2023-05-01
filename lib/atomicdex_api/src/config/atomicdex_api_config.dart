import 'package:flutter/foundation.dart';

/// Placeholder for the AtomicDexApiConfig class. Currently startup is handled
/// outside of the new AtomicDex API package. Will be used in the future when
/// startup is handled by the new AtomicDex API package.
///
/// See lib/model/config_mm2.dart for the current startup configuration class.
@immutable
class AtomicDexApiConfig {
  // If concerns are not properly separated, refactor into a client config and
  // a server config.
  const AtomicDexApiConfig({
    required this.port,
  });

  final int port;

  // TODO: Other fields

  Uri get baseUrl => Uri.parse('http://localhost:$port');
}
