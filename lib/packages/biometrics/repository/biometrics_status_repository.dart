import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:komodo_dex/utils/log.dart';

class BiometricsStatusRepository {
  BiometricsStatusRepository();

  final BiometricStorage _biometricStorage = BiometricStorage();

  Future<BiometricsStatus> biometricsAvailable() async {
    final response = await _biometricStorage.canAuthenticate();
    debugPrint('biometricsAvailable: $response');

    switch (response) {
      case CanAuthenticateResponse.success:
        return BiometricsStatus.available;

      case CanAuthenticateResponse.errorNoBiometricEnrolled:
        return BiometricsStatus.notEnrolled;

      case CanAuthenticateResponse.errorNoHardware:
      case CanAuthenticateResponse.errorHwUnavailable:
      case CanAuthenticateResponse.statusUnknown:
      case CanAuthenticateResponse.unsupported:
        return BiometricsStatus.notAvailable;
    }
  }

  Stream<BiometricsStatus> biometricsAvailableStream() async* {
    // Check every 2 seconds if biometrics is not available, otherwise
    // check every 10 seconds.
    final checkIntervalAvailable = Duration(seconds: 10);

    final checkIntervalNotAvailable = Duration(seconds: 2);

    while (true) {
      final response = await biometricsAvailable();
      Log('BiometricsStatusRepository:biometricsAvailableStream', response);

      yield response;

      final checkInterval = response == BiometricsStatus.notAvailable
          ? checkIntervalNotAvailable
          : checkIntervalAvailable;

      await Future.delayed(checkInterval);
    }
  }
}

// TODO: Account for the state when the user does not have biometrics enrolled
// but has other authentication methods (e.g. PIN, password) set up. The API
// still reports this as notEnrolled, so we will need do a workaround.
// E.g. Try to authenticate with biometrics and then see if it throws an error.
enum BiometricsStatus {
  notAvailable,
  available,
  notEnrolled,
  notAuthenticated,
}
