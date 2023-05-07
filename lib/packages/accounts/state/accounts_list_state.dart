import 'package:komodo_dex/packages/accounts/models/account.dart';

abstract class AccountsListState {}

class AccountsListInitial extends AccountsListState {}

class AccountsListLoadInProgress extends AccountsListState {}

class AccountsListLoadSuccess extends AccountsListState {
  final List<Account> accounts;

  AccountsListLoadSuccess(this.accounts);
}

// TODO: Separate error for load error vs delete error
class AccountsListError extends AccountsListState {
  final String message;

  AccountsListError(this.message);
}
