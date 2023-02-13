part of 'login_bloc.dart';

// ========================= Abstract state class =========================

///Abstract cookie-cutter state class.
abstract class _LoginState {
  const _LoginState({
    // this.pinStatus,
    this.pin,
    this.status,
    this.error,
  });

  final FormzStatus? status;

  final String? error;

  final Pin? pin;

  // Let's avoid storing the correct pin in state. Rather, let's call the
  // repository to check the pin when submitted.
  // final String correctPin;
}

// ========================= General use state =========================

/// General use login state. Where possible, create a new state class for each
/// event. This is a nice to have but not required.
class LoginState extends _LoginState {
  LoginState({
    // PinStatus pinStatus,
    Pin? pin,
    FormzStatus? status,
    String? error,
  }) : super(
          pin: pin,
          status: status,
          error: error,
          // correctPin: correctPin,
        );

  LoginState copyWith({
    // PinStatus pinStatus,
    Pin? pin,
    FormzStatus? status,
    String? error,
    String? correctPin,
  }) {
    return LoginState(
      // pinStatus: pinStatus ?? this.pinStatus,
      pin: pin ?? this.pin,
      status: status ?? this.status,
      error: error ?? this.error,
      // correctPin: correctPin ?? this.correctPin,
    );
  }
}

// ========================= Event-specific states =========================

class LoginStateInitial extends LoginState {
  LoginStateInitial()
      : super(
          // pinStatus: PinStatus.NORMAL_PIN,
          pin: const Pin.pure(),
          error: null,
          // correctPin: '',
          status: FormzStatus.pure,
        );
}

class LoginStatePinSubmitted extends LoginState {
  LoginStatePinSubmitted({
    Pin? pin,
  }) : super(
          pin: pin,
          // correctPin: correctPin,
          status: FormzStatus.submissionInProgress,
        );
}

class LoginStatePinSubmittedSuccess extends LoginState {
  LoginStatePinSubmittedSuccess({
    Pin? pin,
  }) : super(
          pin: pin,
          status: FormzStatus.submissionSuccess,
        );
}

class LoginStatePinSubmittedFailure extends LoginState {
  LoginStatePinSubmittedFailure({
    Pin? pin,
    String? error,
  }) : super(
          pin: pin,
          status: FormzStatus.submissionFailure,
          error: error,
        );
}

class LoginStateSetPin extends LoginState {
  LoginStateSetPin({
    Pin? pin,
  }) : super(
          pin: pin,
          status: FormzStatus.submissionInProgress,
        );

  Pin? pinConfirmation;
}
