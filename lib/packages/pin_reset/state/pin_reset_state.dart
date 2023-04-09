import 'package:flutter/foundation.dart';
import 'package:formz/formz.dart';
import 'package:komodo_dex/login/models/password.dart';
import 'package:komodo_dex/login/models/pin.dart';
import 'package:komodo_dex/login/models/pin_type.dart';
import 'package:komodo_dex/packages/pin_setup/state/pin_setup_state.dart';

enum PinResetStep { confirmOldPin, enterNewPin, confirmNewPin }

// See bloc state naming convention here:
// https://bloclibrary.dev/#/blocnamingconventions?id=subclasses
// The decision to use a single state class for all states was made to
// simplify the state classes because there would be a lot of possible
// combinations since there are 3 pages, and it would not make sense to
// create a seprate bloc for each step since thie logic is simple.

@immutable
class PinResetState with FormzMixin {
  const PinResetState({
    required this.submissionStatus,
    required this.pinType,
    required this.currentStep,
    required this.oldPin,
    required this.newPin,
    required this.confirmPin,
    required this.password,
    this.errorMessage,
  });

  final FormzSubmissionStatus submissionStatus;

  final PinTypeName pinType;

  final PinResetStep currentStep;

  final Pin oldPin;

  final Pin newPin;

  final Pin confirmPin;

  // See [AuthenticationRepository] for more info on future plans for
  // implementing a more secure authentication flow for setting/resetting pins.
  final Password password;

  final String? errorMessage;

  bool get isLoading => submissionStatus.isInProgress;

  bool get isError => submissionStatus.isFailure;

  bool get isSuccess => submissionStatus.isSuccess;

  bool get isPinSetupComplete =>
      submissionStatus.isSuccess && currentStep == PinResetStep.confirmNewPin;

  @override
  List<FormzInput> get inputs => [newPin, confirmPin, oldPin];

  Pin get getCurrentStepPin {
    switch (currentStep) {
      case PinResetStep.confirmOldPin:
        return oldPin;
      case PinResetStep.enterNewPin:
        return newPin;
      case PinResetStep.confirmNewPin:
        return confirmPin;
    }
  }

  const PinResetState.initial()
      : submissionStatus = FormzSubmissionStatus.initial,
        pinType = PinTypeName.normal,
        currentStep = PinResetStep.confirmOldPin,
        oldPin = const Pin.pure(),
        newPin = const Pin.pure(),
        confirmPin = const Pin.pure(),
        password = const Password.pure(),
        errorMessage = null;

  PinResetState copyWith({
    FormzSubmissionStatus? submissionStatus,
    PinTypeName? pinType,
    PinResetStep? currentStep,
    Pin? oldPin,
    Pin? newPin,
    Pin? confirmPin,
    Password? password,
    String? errorMessage,
    bool clearCurrentError = false,
  }) {
    return PinResetState(
      submissionStatus: submissionStatus ?? this.submissionStatus,
      pinType: pinType ?? this.pinType,
      currentStep: currentStep ?? this.currentStep,
      oldPin: oldPin ?? this.oldPin,
      newPin: newPin ?? this.newPin,
      confirmPin: confirmPin ?? this.confirmPin,
      password: password ?? this.password,
      errorMessage:
          clearCurrentError ? null : errorMessage ?? this.errorMessage,
    );
  }

  PinResetState copyWithCurrentStepPin(Pin pin) {
    switch (currentStep) {
      case PinResetStep.confirmOldPin:
        return copyWith(oldPin: pin);
      case PinResetStep.enterNewPin:
        return copyWith(newPin: pin);
      case PinResetStep.confirmNewPin:
        return copyWith(confirmPin: pin);
    }
  }

  PinResetState fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}
