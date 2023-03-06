import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:komodo_dex/packages/authentication_repository/authentication_repository.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generic_blocs/authenticate_bloc.dart';
import '../models/pin.dart';
import 'login_repo.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Duration to throttle pin form submissions
// This could possibly also be done by using bloc's event transformers.
// See: https://bloclibrary.dev/#/coreconcepts?id=advanced-event-transformations
const throttleDuration = Duration(milliseconds: 5000);
final loginLockoutTimer = Stopwatch();

class LoginBloc extends HydratedBloc<LoginEvent, LoginState> {
  LoginBloc({
    required this.prefs,
    required this.loginRepository,
  }) : super(LoginStateInitial()) {
    on<LoginPinInputChanged>(_onPinInputChanged);
    on<LoginPinSubmitted>(_onPinLoginSubmitted);
    on<LoginPinSuccess>(_onPinLoginSuccess);
    on<_LoginPinFailure>(_onPinLoginFailure);
    // on<SetPinSubmitted>(_onSetPinSubmitted);
    // on<SetPinSuccess>(_onSetPinSuccess);
    // on<ResetPinSubmitted>(_onResetPinSubmitted);
    // on<ResetPinSuccess>(_onResetPinSuccess);
  }

  final SharedPreferences prefs;
  final LoginRepository loginRepository;

  void _onPinInputChanged(
    LoginPinInputChanged event,
    Emitter<LoginState> emit,
  ) {
    final pin = Pin.dirty(event.pin);
    emit(
      state.copyWith(
        status: Formz.validate([pin]),
        pin: pin,
      ),
    );
  }

  void _onPinLoginSuccess(
    LoginPinSuccess event,
    Emitter<LoginState> emit,
  ) async {
    return await loginRepository.onPinLoginSuccess();

    loginLockoutTimer
      ..reset()
      ..stop();
  }

  void _onPinLoginFailure(
    _LoginPinFailure event,
    Emitter<LoginState> emit,
  ) {
    // Start the timer if it's not already running. This is to prevent the user
    // from brute-forcing the pin.
    if (!loginLockoutTimer.isRunning) {
      loginLockoutTimer
        ..reset()
        ..start();
    }
  }

  Future<void> awaitLoginLockout() async {
    // If the timer is running, wait for it to be done.
    // Wait for the difference between the current time and the throttle
    // duration.
    if (loginLockoutTimer.isRunning) {
      await waitFor(loginLockoutTimer, throttleDuration);
    }

    // Stop the timer and reset it.
    loginLockoutTimer
      ..stop()
      ..reset();
  }

  void _onPinLoginSubmitted(
    LoginPinSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    // Emit state to indicate that the pin is being checked.
    emit(LoginStatePinSubmitted(pin: state.pin));

    try {
      await awaitLoginLockout();

      await loginRepository.verifyPin(state.pin.value);

      // TODO(@CharlVS): Check camo pin

      emit(LoginStatePinSubmittedSuccess());
    } on IncorrectPinException catch (e) {
      emit(LoginStatePinSubmittedFailure(
        pin: Pin.pure(),
        error: 'Incorrect PIN. Please try again.',
      ));

      loginLockoutTimer.start();
    } catch (e) {
      emit(
        state.copyWith(
          status: FormzStatus.submissionFailure,
          error: e.toString(),
        ),
      );

      debugPrint('[ERROR] LoginBloc: _onPinLoginSubmitted: $e');
    } finally {
      // Clear pin from state as a security measure after user logs in.
    }

    // TODO(@ologunB): Reference applicable repository methods + state changes here.
    // E.g. (Suggestions, not complete):
    // - Check if pin matches the camo pin.
    // - If it does, emit LoginPinSuccess and call the authenticationRepository
    // method to authenticate the user.
    // - If it doesn't, check if it matches the normal pin.
    // - If it does, emit LoginPinSuccess and call the authenticationRepository
    // method to authenticate the user.
    // - If it doesn't, emit LoginPinFailure.
  }

  // TODO(@ologunB): Implement other bloc methods. For now, let's first focus
  // on the login screen, then we can move on to the other screens for setting
  // the pin, etc.

  // NB: toJson and fromJson methods are critical to restore state after
  // the app restarts as it's used by the HydratedBloc library.
  @override
  JsonMap toJson(LoginState state) {
    // TODO: implement toJson
    return {
      'status': state.status.name,
      'pin': state.pin.toJson(),
    };
  }

  @override
  LoginState fromJson(JsonMap json) {
    return LoginState(
      status: FormzStatus.values
          .firstWhereOrNull((e) => e.name == json['status']) as FormzStatus,
      pin: Pin.fromJson(json['pin'] as JsonMap),
    );
  }
}
