import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:komodo_dex/packages/accounts/events/accounts_list_event.dart';
import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'package:komodo_dex/packages/accounts/repository/account_repository.dart';
import 'package:komodo_dex/packages/accounts/state/accounts_list_state.dart';

class AccountsListBloc extends Bloc<AccountsListEvent, AccountsListState> {
  final AccountRepository _accountRepository;

  AccountsListBloc({required AccountRepository accountRepository})
      : _accountRepository = accountRepository,
        super(AccountsListInitial()) {
    // on<AccountsListLoadRequested>(_onLoadAccountsRequested);
    on<AccountsListSubscriptionRequested>(_onSubscriptionRequested);
  }

  void _onSubscriptionRequested(
    AccountsListSubscriptionRequested event,
    Emitter<AccountsListState> emit,
  ) async {
    // If we already have accounts loaded, don't emit the load in progress.
    // Only emit the updated accounts list.
    final isLoadedWithAccounts = state is AccountsListLoadSuccess &&
        (state as AccountsListLoadSuccess).accounts.isNotEmpty;

    if (!isLoadedWithAccounts) {
      emit(AccountsListLoadInProgress());
    }

    try {
      await emit.forEach<List<Account>>(_accountRepository.accountsStream(),
          onData: (accounts) {
        return AccountsListLoadSuccess(accounts);
      }, onError: (e, s) {
        return AccountsListError(e.toString());
      });
      debugPrint('AccountsListBloc: Subscription closed.');
    } catch (e) {
      debugPrint('AccountsListBloc: Subscription error: $e');
      // TODO: Localize error message and handle any specific errors.
      emit(AccountsListError(e.toString()));
    }
  }
}
