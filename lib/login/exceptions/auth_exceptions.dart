// List of exceptions that can be thrown by the repository.
import 'package:komodo_dex/login/models/pin_type.dart';

/// Used for exceptions related to incorrect usage of the repository. Likely
/// only thrown during development.
class AuthenticationRepositoryException implements Exception {
  final String message;

  AuthenticationRepositoryException(this.message);
}

/// Used for exceptions related to authentication.
class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);
}

class PinNotFoundException extends AuthenticationException {
  PinNotFoundException({this.types, String? message})
      : super(
          message ??
              'Pin not found for types: '
                  '${types != null ? _formatPinTypeNames(types) : 'Type unspecified'}'
                  '. Try setting a pin first.',
        );

  List<PinTypeName>? types;
}

class IncorrectPinException extends AuthenticationException {
  IncorrectPinException({required this.types, String? message})
      : assert(types.isNotEmpty),
        super(
            message ?? 'Incorrect pin for types: $_formatPinTypeNames(types)');

  List<PinTypeName> types;
}

class PinAlreadySetException extends AuthenticationException {
  PinAlreadySetException({required this.type, String? message})
      : super(
          message ??
              '${type.toString()}) Pin already set. Try resetting it first.',
        );

  PinTypeName type;
}

class PinAlreadySetForAnotherTypeException extends AuthenticationException {
  PinAlreadySetForAnotherTypeException(this.type)
      : super(
            'Pin already set for type: ${type.toString()}. Cannot set the same pin for multiple types.');

  final PinTypeName type;
}

/// Used for exceptions when the trying to perform an action that requires
/// authentication, but the user is not authenticated.
class NotAuthenticatedException extends AuthenticationException {
  NotAuthenticatedException([String? message])
      : super(message ?? 'Not authenticated.');
}

String _formatPinTypeNames(List<PinTypeName> types) {
  return types.map((t) => t.toString()).join(', ');
}
