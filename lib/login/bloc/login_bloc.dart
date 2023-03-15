import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:komodo_dex/utils/iterable_utils.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pin.dart';
import 'login_repo.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Duration to throttle pin form submissions
const throttleDuration = Duration(milliseconds: 5000);
final loginLockoutTimer = Stopwatch();

class LoginBloc extends HydratedBloc<LoginEvent, LoginState> {
  LoginBloc({
    this.prefs,
    this.loginRepository,
  }) : super(LoginStateInitial()) {
    on<LoginPinInputChanged>(_onPinInputChanged);
    on<LoginPinSubmitted>(_onPinLoginSubmitted);
    on<LoginPinSuccess>(_onPinLoginSuccess);
    on<_LoginPinFailure>(_onPinLoginFailure);
  }

  final SharedPreferences? prefs;
  final LoginRepository? loginRepository;

  void _onPinInputChanged(
    LoginPinInputChanged event,
    Emitter<LoginState> emit,
  ) {
    final pin = Pin.dirty(event.pin);
    emit(
      state.copyWith(
        submissionStatus: FormzSubmissionStatus.initial,
        pin: pin,
      ),
    );
  }

  void _onPinLoginSuccess(
    LoginPinSuccess event,
    Emitter<LoginState> emit,
  ) async {
    loginLockoutTimer
      ..reset()
      ..stop();

    await loginRepository!.onPinLoginSuccess();
  }

  void _onPinLoginFailure(
    _LoginPinFailure event,
    Emitter<LoginState> emit,
  ) {
    if (!loginLockoutTimer.isRunning) {
      loginLockoutTimer
        ..reset()
        ..start();
    }

    emit(LoginStatePinSubmittedFailure(
      pin: Pin.pure(),
      error: event.error,
    ));
  }

  /// This awaits a timeout from the time of last incorrect pin. This throttles
  /// pin submissions to prevent brute force attacks. The optimal UX approach
  /// is to only make the user wait if, after entering an incorrect pin, we
  /// allow the user to start entering a new pin immediately. We only want to
  /// force the user to wait if they have submitted a new pin attempt before
  /// the timeout duration from the last incorrect pin has elapsed.
  Future<void> awaitLoginLockout() async {
    if (loginLockoutTimer.isRunning) {
      await awaitDurationDifference(
          loginLockoutTimer.elapsed, throttleDuration);
    }

    loginLockoutTimer
      ..stop()
      ..reset();
  }

  void _onPinLoginSubmitted(
    LoginPinSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginStatePinSubmitted(pin: state.pin));

    try {
      await awaitLoginLockout();

      await loginRepository!.verifyPin(state.pin.value);

      add(LoginPinSuccess());
    } on IncorrectPinException catch (_) {
      add(_LoginPinFailure('Incorrect PIN. Please try again.'));
    } catch (e) {
      add(_LoginPinFailure(e.toString()));
      debugPrint('[ERROR] LoginBloc: _onPinLoginSubmitted: $e');
    }
  }

  // toJson and fromJson methods are critical to restore state after
  // the app restarts as it's used by the HydratedBloc library.
  @override
  JsonMap toJson(LoginState state) {
    return {
      'status': state.submissionStatus.toString(),
      'pin': state.pin.toJson(),
    };
  }

  @override
  LoginState fromJson(JsonMap json) {
    return LoginState(
      submissionStatus: FormzSubmissionStatus.values
              .firstWhereOrNull((e) => e.toString() == json['status'])
          as FormzSubmissionStatus,
      pin: Pin.fromJson(json['pin'] as JsonMap),
    );
  }
}
