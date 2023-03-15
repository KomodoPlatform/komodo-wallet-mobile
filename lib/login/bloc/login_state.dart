part of 'login_bloc.dart';

// ========================= Abstract state class =========================

// This abstract class defines the common properties for all LoginState variations.
abstract class LoginStateAbstract with FormzMixin {
  const LoginStateAbstract({
    required this.pin,
    required this.submissionStatus,
    this.error,
  });

  @override
  List<FormzInput> get inputs => [pin];

  final FormzSubmissionStatus
      submissionStatus; // The submission status of the form
  final String? error; // A string representing any error that occurred
  final Pin pin; // The pin entered by the user
}

// ========================= General use state =========================

//TODO: Refactor this class into an abstract class to be in line with the
// naming conventions. The convention suggests using either a single state
// or multiple segmented states. This class is a hybrid of both.
class LoginState extends LoginStateAbstract {
  LoginState({
    required Pin pin,
    required FormzSubmissionStatus submissionStatus,
    String? error,
  }) : super(
          pin: pin,
          submissionStatus: submissionStatus,
          error: error,
        );

  // Check if the form submission is in progress
  bool get isLoading => submissionStatus.isInProgress;

  // Check if the form submission has failed
  bool get isError => submissionStatus.isFailure;

  // Returns a new instance of LoginState with the updated properties
  LoginState copyWith({
    Pin? pin,
    FormzSubmissionStatus? submissionStatus,
    String? error,
  }) {
    return LoginState(
      pin: pin ?? this.pin,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      error: error ?? this.error,
    );
  }
}

// ========================= Event-specific states =========================

// The initial state of the form when it is first rendered
class LoginStateInitial extends LoginState {
  LoginStateInitial()
      : super(
          pin: const Pin.pure(),
          error: null,
          submissionStatus: FormzSubmissionStatus.initial,
        );
}

// The state when the pin is submitted
class LoginStatePinSubmitted extends LoginState {
  LoginStatePinSubmitted({
    required Pin pin,
  }) : super(
          pin: pin,
          submissionStatus: FormzSubmissionStatus.inProgress,
        );
}

// The state when the pin submission is successful
class LoginStatePinSubmittedSuccess extends LoginState {
  LoginStatePinSubmittedSuccess()
      : super(
          pin: Pin.pure(),
          submissionStatus: FormzSubmissionStatus.success,
        );
}

// The state when the pin submission has failed
class LoginStatePinSubmittedFailure extends LoginState {
  LoginStatePinSubmittedFailure({
    required Pin pin,
    required String error,
  }) : super(
          pin: pin,
          submissionStatus: FormzSubmissionStatus.failure,
          error: error,
        );
}

// The state when the pin input is updated by the user
class LoginStateUpdateInput extends LoginState {
  LoginStateUpdateInput({
    required Pin pin,
  }) : super(
          pin: pin,
          submissionStatus: FormzSubmissionStatus.inProgress,
        );

  Pin? pinConfirmation;
}
