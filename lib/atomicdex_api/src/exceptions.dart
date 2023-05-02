class AtomicDexApiException implements Exception {
  AtomicDexApiException(this.message);

  final String message;

  @override
  String toString() => 'AtomicDexApiException: $message';
}

class NoSuchAccountException extends AtomicDexApiException {
  NoSuchAccountException(message) : super(message);
}

class AccountExistsAlreadyException extends AtomicDexApiException {
  AccountExistsAlreadyException(message) : super(message);
}

class NameTooLongException extends AtomicDexApiException {
  NameTooLongException(message) : super(message);
}

class DescriptionTooLongException extends AtomicDexApiException {
  DescriptionTooLongException(message) : super(message);
}

// Add more specific exception classes as needed
