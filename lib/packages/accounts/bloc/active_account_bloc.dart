import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:komodo_dex/packages/accounts/events/active_account_event.dart';
import 'package:komodo_dex/packages/accounts/repository/account_repository.dart';
import 'package:komodo_dex/packages/accounts/repository/active_account_repository.dart';
import 'package:komodo_dex/packages/accounts/state/active_account_state.dart';

export 'package:komodo_dex/packages/accounts/events/active_account_event.dart';
export 'package:komodo_dex/packages/accounts/state/active_account_state.dart';

/// [ActiveAccountBloc] is responsible for managing the active account state in the application.
///
/// It handles events related to retrieving, switching and clearing the active account.
class ActiveAccountBloc
    extends HydratedBloc<ActiveAccountEvent, ActiveAccountState> {
  final ActiveAccountRepository _activeAccountRepository;
  final AccountRepository _accountRepository;

  ActiveAccountBloc({
    required ActiveAccountRepository activeAccountRepository,
    required AccountRepository accountRepository,
  })  : _activeAccountRepository = activeAccountRepository,
        _accountRepository = accountRepository,
        super(ActiveAccountInitial()) {
    on<ActiveAccountStarted>(_onActiveAccountStarted);
    on<ActiveAccountSwitchRequested>(_onActiveAccountSwitchRequested);
    on<ActiveAccountClearRequested>(_onActiveAccountClearRequested);
  }

  Future<void> _onActiveAccountStarted(
      ActiveAccountStarted event, Emitter<ActiveAccountState> emit) async {
    emit(ActiveAccountInProgress());
    // Perform the initial loading of the active account
    try {
      final account = await _activeAccountRepository.tryGetActiveAccount();
      if (account != null) {
        emit(ActiveAccountSuccess(account: account));
      } else {
        emit(ActiveAccountInitial());
      }
    } catch (e) {
      emit(ActiveAccountFailure(error: e.toString()));
    }
  }

  Future<void> _onActiveAccountSwitchRequested(
      ActiveAccountSwitchRequested event,
      Emitter<ActiveAccountState> emit) async {
    emit(ActiveAccountInProgress());
    try {
      await _activeAccountRepository.setActiveAccount(event.requestedAccountId);
      final newAccount = await _accountRepository.getAccount(
          accountId: event.requestedAccountId);
      if (newAccount != null) {
        emit(ActiveAccountSuccess(account: newAccount));
      } else {
        emit(
          ActiveAccountFailure(error: 'Failed to switch the active account.'),
        );
      }
    } catch (e) {
      emit(ActiveAccountFailure(error: e.toString()));
    }
  }

  Future<void> _onActiveAccountClearRequested(ActiveAccountClearRequested event,
      Emitter<ActiveAccountState> emit) async {
    emit(ActiveAccountInProgress());
    // Perform the clearing of the active account
    try {
      await _activeAccountRepository.clearActiveAccount();
      emit(ActiveAccountInitial());
    } catch (e) {
      emit(ActiveAccountFailure(error: e.toString()));
    }
  }

  @override
  ActiveAccountState fromJson(Map<String, dynamic> json) {
    return ActiveAccountState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(ActiveAccountState state) {
    return state.toJson();
  }
}
