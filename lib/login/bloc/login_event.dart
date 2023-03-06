part of 'login_bloc.dart';

abstract class LoginEvent {
  const LoginEvent();
}

class LoginPinInputChanged extends LoginEvent {
  const LoginPinInputChanged(this.pin);

  final String pin;
}

class LoginPinSubmitted extends LoginEvent {
  const LoginPinSubmitted(this.code);
  final String? code;
}

class LoginPinReset extends LoginEvent {
  const LoginPinReset();
}

class LoginPinSuccess extends LoginEvent {
  const LoginPinSuccess(this.password, this.code, this.isFromChangingPin,
      this.onSuccess, this.pinStatus);
  final PinStatus? pinStatus;
  final String? code;
  final bool isFromChangingPin;
  final String? password;
  final VoidCallback? onSuccess;
}

class _LoginPinFailure extends LoginEvent {
  const _LoginPinFailure(this.error);

  final String error;
}

// /// Event for setting the user's login pin.
// class LoginSetPin extends LoginEvent {
//   const LoginSetPin(this.newPin);

//   final String newPin;
// }
