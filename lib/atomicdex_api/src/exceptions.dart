class AtomicDexApiException implements Exception {
  AtomicDexApiException(this.message);

  final String message;

  @override
  String toString() => 'AtomicDexApiException: $message';
}

class NoSuchAccountException extends AtomicDexApiException {
  NoSuchAccountException([String? message])
      : super(message ?? 'No such account.');
}

class AccountExistsAlreadyException extends AtomicDexApiException {
  AccountExistsAlreadyException([String? message])
      : super(message ?? 'Account exists already.');
}

class NameTooLongException extends AtomicDexApiException {
  NameTooLongException(message) : super(message);
}

class DescriptionTooLongException extends AtomicDexApiException {
  DescriptionTooLongException(message) : super(message);
}

// Add more specific exception classes as needed
