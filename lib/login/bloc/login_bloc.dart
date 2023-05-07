import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:komodo_dex/login/exceptions/auth_exceptions.dart';
import 'package:komodo_dex/login/models/pin_type.dart';
import 'package:komodo_dex/utils/iterable_utils.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pin.dart';
import '../../packages/authentication/repository/authentication_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Duration to throttle pin form submissions
const throttleDuration = Duration(milliseconds: 5000);
final loginLockoutTimer = Stopwatch();

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    this.prefs,
    required this.authenticationRepository,
  }) : super(LoginStateInitial()) {
    on<LoginPinInputChanged>(_onPinInputChanged);
    on<LoginPinSubmitted>(_onPinLoginSubmitted);
    on<_LoginPinSuccess>(_onPinLoginSuccess);
    on<_LoginPinFailure>(_onPinLoginFailure);
    on<LoginClear>(_clear);
  }

  final SharedPreferences? prefs;
  final AuthenticationRepository authenticationRepository;

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
    _LoginPinSuccess event,
    Emitter<LoginState> emit,
  ) async {
    loginLockoutTimer
      ..reset()
      ..stop();

    // TODO: Any other actions to take on successful login not already handled
    // by the authentication repository?
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
    emit(LoginStatePinSubmitted(pin: Pin.dirty(event.code)));

    try {
      await awaitLoginLockout();

      final successPinType = PinTypeName.normal;
      // await authenticationRepository.loginWithPinAnyType(event.code);

      add(_LoginPinSuccess(successPinType));
    } on IncorrectPinException catch (_) {
      add(_LoginPinFailure('Incorrect PIN. Please try again.'));
    } catch (e) {
      add(_LoginPinFailure(e.toString()));
      debugPrint('[ERROR] LoginBloc: _onPinLoginSubmitted: $e');
    }
  }

  // toJson and fromJson methods are critical to restore state after
  // the app restarts as it's used by the HydratedBloc library.
  JsonMap toJson(LoginState state) {
    return {
      'status': state.submissionStatus.toString(),
      'pin': state.pin.toJson(),
    };
  }

  LoginState fromJson(JsonMap json) {
    return LoginState(
      submissionStatus: FormzSubmissionStatus.values
              .firstWhereOrNull((e) => e.toString() == json['status'])
          as FormzSubmissionStatus,
      pin: Pin.fromJson(json['pin'] as JsonMap),
    );
  }

  void _clear(LoginClear event, Emitter<LoginState> emit) {
    emit(LoginStateInitial());
  }
}
