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
  final String code;
}

class LoginPinReset extends LoginEvent {
  const LoginPinReset();
}

class _LoginPinSuccess extends LoginEvent {
  const _LoginPinSuccess(PinTypeName type);
}

class _LoginPinFailure extends LoginEvent {
  const _LoginPinFailure(this.error);

  final String error;
}

class LoginClear extends LoginEvent {
  const LoginClear();
}
