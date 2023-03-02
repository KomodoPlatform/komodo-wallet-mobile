part of 'login_bloc.dart';

abstract class LoginEvent {
  const LoginEvent();
}

class LoginPinInputChanged extends LoginEvent {
  const LoginPinInputChanged(this.pin);

  final String pin;
}

class LoginPinSubmitted extends LoginEvent {
  const LoginPinSubmitted(this.password, this.code, this.isFromChangingPin,
      this.onSuccess, this.pinStatus, this.postSuccess, this.postFailed);
  final PinStatus? pinStatus;
  final String? code;
  final bool isFromChangingPin;
  final String? password;
  final VoidCallback? onSuccess;
  final Function() postSuccess;
  final Function() postFailed;
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

class LoginPinFailure extends LoginEvent {
  const LoginPinFailure(this.error);

  final String error;
}

// /// Event for setting the user's login pin.
// class LoginSetPin extends LoginEvent {
//   const LoginSetPin(this.newPin);

//   final String newPin;
// }
