import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:komodo_dex/login/exceptions/auth_exceptions.dart';
import 'package:komodo_dex/login/models/password.dart';
import 'package:komodo_dex/login/models/pin.dart';
import 'package:komodo_dex/login/models/pin_type.dart';
import 'package:komodo_dex/packages/authentication/repository/authentication_repository.dart';
import 'package:komodo_dex/packages/pin_reset/events/index.dart';
import 'package:komodo_dex/packages/pin_reset/events/pin_setup_started.dart';
import 'package:komodo_dex/packages/pin_reset/state/pin_reset_state.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: Localize auth-related exceptions. Check if an existing localization key
// can be used or if a new one needs to be added. Only necessary to localize
// user-facing exceptions.
// TODO: An ideal solution for setting/resetting pins would be something along the lines of the following flow:
// 1. Verify password in bloc
// 2. Auth repo issues a short-lived password-action token
// 3. User provides token to set/reset pin regardless of whether it is currently set
// 4. Auth repo/API invalidates token after certain time or when it has been used.
// This would be implemented in a new AuthenticationBloc so that it can be used for any sensitive actions
// which require the password to be confirmed. The current implementation poses a security risk if the user
// has set a password and then another user gets access to the device before the user can set the pin without
// knowing the password.
class PinResetBloc extends Bloc<PinResetEvent, PinResetState> {
  PinResetBloc(
      {required AuthenticationRepository authenticationRepository,
      required SharedPreferences prefs})
      : _authenticationRepository = authenticationRepository,
        _prefs = prefs,
        super(const PinResetState.initial()) {
    on<PinSetupStarted>(_onPinSetupStarted);
    on<PinResetStarted>(_onPinResetStarted);
    on<PinResetPinChanged>(_onPinResetPinChanged);
    on<PinResetSubmitted>(_onPinResetSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  final SharedPreferences _prefs;

  void _onPinSetupStarted(
      PinSetupStarted event, Emitter<PinResetState> emit) async {
    // Try get password from encrypted storage. This is a temporary solution
    // until we implement a more secure authentication flow for
    // setting/resetting pins.

    final password = await EncryptionTool().read('password');

    // Verify the password as if it was entered by user
    // await _authenticationRepository.verifyPassword(password!);

    const currentStep = PinResetStep.enterNewPin;

    // Pass the password to the state
    emit(
      PinResetState.initial().copyWith(
        pinType: event.pinType,
        currentStep: currentStep,
        password: Password.dirty('password'),
      ),
    );
  }

  void _onPinResetStarted(
      PinResetStarted event, Emitter<PinResetState> emit) async {
    final isPinTypeSet = await checkIfPinTypeSet(event.pinType);
    final currentStep =
        isPinTypeSet ? PinResetStep.confirmOldPin : PinResetStep.enterNewPin;

    // TODO: Consider implementing a more secure authentication flow for setting/resetting pins.
    // See the initial comment for a suggested flow using a short-lived password-action token.
    emit(PinResetState.initial()
        .copyWith(pinType: event.pinType, currentStep: currentStep));
  }

  void _onPinResetPinChanged(
      PinResetPinChanged event, Emitter<PinResetState> emit) {
    if (state.isLoading) throw Exception('Cannot change PIN while loading.');

    final pin = Pin.dirty(event.pin);
    final newState = state
        .copyWith(
            clearCurrentError: true,
            submissionStatus: FormzSubmissionStatus.initial)
        .copyWithCurrentStepPin(pin);

    emit(newState);
  }

  void _onPinResetSubmitted(
      PinResetSubmitted event, Emitter<PinResetState> emit) async {
    // Validate the inputs
    if (!state.getCurrentStepPin.isValid) {
      _updateStateInvalidCurrentStepPin(emit);
      return;
    }

    emit(
      state.copyWith(
        submissionStatus: FormzSubmissionStatus.inProgress,
        clearCurrentError: true,
      ),
    );

    try {
      switch (state.currentStep) {
        case PinResetStep.confirmOldPin:
          return await _handleStepConfirmOldPinSubmitted(emit);

        case PinResetStep.enterNewPin:
          return await _handleStepEnterNewPinSubmitted(emit);

        case PinResetStep.confirmNewPin:
          if (state.newPin.value != state.getCurrentStepPin.value) {
            _updateStateInvalidCurrentStepPin(
                emit, 'New PIN and confirmed PIN do not match.');
            return;
          }

          // Everything is valid, so let's go ahead and call API to reset PIN
          // await _authenticationRepository.setPin(
          //   newPin: state.newPin.value,
          //   type: state.pinType,
          //   currentPin:
          //       state.password.value.isEmpty ? null : state.oldPin.value,
          //   password: state.password.value,
          // );

          // Reset PIN was successful, update the state accordingly
          emit(
            state.copyWith(
              submissionStatus: FormzSubmissionStatus.success,
              errorMessage: null,
            ),
          );

          return;
      }
    } on PinAlreadySetForAnotherTypeException catch (e) {
      // TODO: Localize this exception
      rethrow;
    } catch (error) {
      // Handle any other errors here
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _updateStateInvalidCurrentStepPin(Emitter<PinResetState> emit,
      [String errorMessage = 'Invalid PIN.']) {
    emit(
      state
          .copyWith(
            submissionStatus: FormzSubmissionStatus.failure,
            errorMessage: errorMessage,
          )
          .copyWithCurrentStepPin(const Pin.pure()),
    );
  }

  void _updateStateNewStep(Emitter<PinResetState> emit,
      {required PinResetStep newStep}) {
    emit(state.copyWith(
      currentStep: newStep,
      submissionStatus: FormzSubmissionStatus.initial,
      errorMessage: null,
      clearCurrentError: true,
    ));
  }

  Future<void> _handleStepEnterNewPinSubmitted(
      Emitter<PinResetState> emit) async {
    emit(state.copyWith(
      currentStep: PinResetStep.confirmNewPin,
      submissionStatus: FormzSubmissionStatus.initial,
      newPin: state.getCurrentStepPin,
    ));
  }

  Future<void> _handleStepConfirmOldPinSubmitted(
    Emitter<PinResetState> emit,
  ) async {
    try {
      // await _authenticationRepository.verifyPin(
      //   state.oldPin.value,
      //   state.pinType,
      // );

      // Move to the next step after successful PIN verification
      _updateStateNewStep(
        emit,
        newStep: PinResetStep.enterNewPin,
      );
    } on IncorrectPinException {
      // TODO: Replace with localized string
      _updateStateInvalidCurrentStepPin(emit, 'Invalid current PIN.');
    } catch (error) {
      // Handle any other errors here
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  /// Checks if the user has a pin set for the specified [pinType].
  ///
  /// This is a temp-fix for legacy UI code reading data directly from
  /// encrypted storage. This should be removed once the UI code is updated.
  Future<bool> checkIfPinTypeSet(PinTypeName pinType) async {
    try {
      // await _authenticationRepository.verifyPin(
      //   '',
      //   pinType,
      // );
    } on IncorrectPinException {
      return true;
    } catch (error) {
      return false;
    }

    return false;
  }
}
