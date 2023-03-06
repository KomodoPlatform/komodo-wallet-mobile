part of 'login_bloc.dart';

// ========================= Abstract state class =========================

///Abstract cookie-cutter state class.
abstract class LoginStateAbstract {
  const LoginStateAbstract({
    // this.pinStatus,
    required this.pin,
    required this.status,
    this.error,
  });

  final FormzStatus status;

  final String? error;

  final Pin pin;

  // Let's avoid storing the correct pin in state. Rather, let's call the
  // repository to check the pin when submitted.
  // final String correctPin;
}

// ========================= General use state =========================

/// General use login state. Where possible, create a new state class for each
/// event. This is a nice to have but not required.
class LoginState extends LoginStateAbstract {
  LoginState({
    // PinStatus pinStatus,
    required Pin pin,
    required FormzStatus status,
    String? error,
  }) : super(
          pin: pin,
          status: status,
          error: error,
          // correctPin: correctPin,
        );

  bool get isLoading => status == FormzStatus.submissionInProgress;
  bool get isError => status == FormzStatus.submissionFailure;

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

// class LoginStateSetPin extends LoginState {
//   LoginStateSetPin({
//     Pin? pin,
//     this.pinConfirmation,
//   }) : super(
//           pin: pin,
//           status: FormzStatus.pure,
//         );

//   final Pin? pinConfirmation;

//   bool get isLoading => status == FormzStatus.submissionInProgress;

//   LoginStateSetPin copyWith({
//     Pin? pin,
//     Pin? pinConfirmation,
//     FormzStatus? status,
//     String? error,
//   }) {
//     return LoginStateSetPin(
//       pin: pin ?? this.pin,
//       pinConfirmation: pinConfirmation ?? this.pinConfirmation,
//       status: status ?? this.status,
//       error: error ?? this.error,
//     );
//   }
// }

class LoginStatePinSubmitted extends LoginState {
  LoginStatePinSubmitted({
    required Pin pin,
  }) : super(
          pin: pin,
          // correctPin: correctPin,
          status: FormzStatus.submissionInProgress,
        );
}

class LoginStatePinSubmittedSuccess extends LoginState {
  LoginStatePinSubmittedSuccess()
      : super(
          pin: Pin.pure(),
          status: FormzStatus.submissionSuccess,
        );
}

class LoginStatePinSubmittedFailure extends LoginState {
  LoginStatePinSubmittedFailure({
    required Pin pin,
    required String error,
  }) : super(
          pin: pin,
          status: FormzStatus.submissionFailure,
          error: error,
        );
}

class LoginStateUpdateInput extends LoginState {
  LoginStateUpdateInput({
    required Pin pin,
  }) : super(
          pin: pin,
          status: FormzStatus.submissionInProgress,
        );

  Pin? pinConfirmation;
}
