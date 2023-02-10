part of 'login_bloc.dart';

abstract class LoginEvent {
  const LoginEvent();
}

class LoginPinInputChanged extends LoginEvent {
  const LoginPinInputChanged(this.pin);

  final String pin;
}

class LoginPinSubmitted extends LoginEvent {
  const LoginPinSubmitted();
}

class LoginPinReset extends LoginEvent {
  const LoginPinReset();
}

class LoginPinSuccess extends LoginEvent {
  const LoginPinSuccess();
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
