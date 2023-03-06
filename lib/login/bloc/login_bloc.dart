import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
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

class LoginBloc extends HydratedBloc<LoginEvent, LoginState> {
  LoginBloc({
    required this.prefs,
    required this.loginRepository,
  }) : super(LoginStateInitial()) {
    on<LoginPinInputChanged>(_onPinInputChanged);

    on<LoginPinSubmitted>(_onPinLoginSubmitted);

    on<LoginPinSuccess>(_onPinLoginSuccess);

    on<LoginPinFailure>(_onPinLoginFailure);
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
        pin: pin,
      ),
    );
  }

  void _onPinLoginSuccess(LoginPinSuccess event, Emitter<LoginState> emit) {}

  void _onPinLoginFailure(
    LoginPinFailure event,
    Emitter<LoginState> emit,
  ) {
    // TODO(@ologunB): Implement this method.
  }

  void _onPinLoginSubmitted(
    LoginPinSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    // Emit state to indicate that the pin is being checked.
    emit(LoginStatePinSubmitted(pin: state.pin));

    await loginRepository.initParameters(
        event.password,
        event.code,
        event.onSuccess,
        event.postSuccess,
        event.postFailed,
        event.pinStatus,
        event.isFromChangingPin);
    try {
       emit(
        state.copyWith(
          status: FormzStatus.submissionInProgress,
        ),
      );
      await loginRepository.validatePin();

      emit(
        state.copyWith(status: FormzStatus.submissionSuccess),
      );
    } catch (e) {

      emit(
        state.copyWith(
          status: FormzStatus.submissionFailure,
          error: e.toString(),
        ),
      );
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
      'status': state.status?.name,
      'pin': state.pin?.toJson(),
    };
  }

  @override
  LoginState fromJson(JsonMap json) {
    return LoginState(
      status: FormzStatus.values
          .firstWhereOrNull((e) => e.name == json['status']) as FormzStatus,
      pin: json['pin'] == null ? null : Pin.fromJson(json['pin'] as JsonMap),
    );
  }
}
