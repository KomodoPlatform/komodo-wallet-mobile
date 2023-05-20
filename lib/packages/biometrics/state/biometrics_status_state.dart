import 'package:flutter/foundation.dart';

// TODO: Json serialization
/// [BiometricsStatusState] is an abstract class representing the different
/// possible states of biometric authentication within the application.
///
/// Currently focused on the state of biometrics availability, but could
/// be expanded for other biometric states.
@immutable
sealed class BiometricsStatusState {}

/// The initial state of the [BiometricsBloc].
///
/// This is the state before any actions relating to biometric authentication
/// have taken place.
@immutable
final class BiometricsStatusInitial extends BiometricsStatusState {}

/// Represents the state where biometrics are available and ready to be used.
///
/// This state signifies that biometric authentication is fully functional and
/// ready for authentication attempts.
final class BiometricsStatusAvailable extends BiometricsStatusState {}

/// Represents the state where the device does not support biometric authentication.
///
/// This state implies that the device or system does not provide the necessary
/// hardware or software support for biometric authentication.
///
/// [message] is a string that can contain a specific message about why
/// biometric authentication is not supported.
final class BiometricsStatusNotSupported extends BiometricsStatusState {
  BiometricsStatusNotSupported({required this.message});

  final String message;
}

/// Represents the state where biometrics have not been set up on the device.
///
/// This state indicates that although the device supports biometric
/// authentication, it has not been properly configured by the user.
///
/// [message] is a string that can contain specific details about why biometric
/// authentication has not been set up.
final class BiometricsNotEnrolled extends BiometricsStatusState {
  BiometricsNotEnrolled({required this.message});

  final String message;
}

/// Represents the state where the user is not authenticated.
///
/// This state implies that the user has not successfully authenticated
/// themselves using the biometric features of the device.
///
/// [message] is a string that can contain a specific message about this, such
/// as prompting the user to lock and unlock the screen.
final class BiometricsStatusNotAuthenticated extends BiometricsStatusState {
  BiometricsStatusNotAuthenticated({required this.message});

  final String message;
}
