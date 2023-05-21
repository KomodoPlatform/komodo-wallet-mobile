class AuthenticationRepositoryHelper {}

class AuthenticationRepositoryException implements Exception {
  final String message;
  AuthenticationRepositoryException(this.message);
}

// An exception thrown if the user's device supports biometrics but the user
// has not enrolled any biometrics.
class BiometricsNotEnrolledException implements Exception {
  final String message;
  BiometricsNotEnrolledException(this.message);
}

class WalletNotFoundException implements Exception {
  final String message;
  WalletNotFoundException([this.message = 'Wallet not found']);
}

class WalletAlreadyExistsException implements Exception {
  final String message;
  WalletAlreadyExistsException([this.message = 'Wallet already exists']);
}

class InvalidPassphraseException implements Exception {
  final String message;
  InvalidPassphraseException(this.message);
}
