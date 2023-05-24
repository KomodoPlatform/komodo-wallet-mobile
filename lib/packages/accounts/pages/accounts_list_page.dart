import 'dart:convert';
import 'dart:math';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/navigation/app_routes.dart';
import 'package:komodo_dex/packages/accounts/bloc/account_form_bloc.dart';
import 'package:komodo_dex/packages/accounts/bloc/accounts_list_bloc.dart';
import 'package:komodo_dex/packages/accounts/bloc/active_account_bloc.dart';
import 'package:komodo_dex/packages/accounts/events/account_form_event.dart';
import 'package:komodo_dex/packages/accounts/events/accounts_list_event.dart';
import 'package:komodo_dex/packages/accounts/events/active_account_event.dart';
import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'package:komodo_dex/packages/accounts/state/accounts_list_state.dart';
import 'package:komodo_dex/packages/accounts/state/active_account_state.dart';
import 'package:komodo_dex/packages/app/widgets/main_app.dart';
import 'package:komodo_dex/packages/authentication/bloc/authentication_bloc.dart';
import 'package:komodo_dex/utils/utils.dart';

class AccountsListPage extends StatefulWidget {
  @override
  State<AccountsListPage> createState() => _AccountsListPageState();
}

class _AccountsListPageState extends State<AccountsListPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccountsListBloc>().add(AccountsListSubscriptionRequested());
  }

  @override
  Widget build(BuildContext context) {
    final bool isActiveAccountLoading = context.select(
        (ActiveAccountBloc bloc) =>
            bloc.state is ActiveAccountInProgress ||
            bloc.state is ActiveAccountSwitchInProgress);
    return MultiBlocListener(
      listeners: [
        BlocListener<AccountsListBloc, AccountsListState>(
          listener: _onAccountsListStateChange,
        ),
        BlocListener<ActiveAccountBloc, ActiveAccountState>(
          listener: _onActiveAccountStateChange,
        ),
      ],
      child: BlocBuilder<AccountsListBloc, AccountsListState>(
        builder: (context, state) {
          if (_shouldShowLoadingIndicator) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AccountsListLoadSuccess) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Accounts'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: _onPressesLogOut,
                  ),
                ],
              ),
              body: ListView.builder(
                itemCount: state.accounts.length,
                itemBuilder: (BuildContext context, int index) {
                  final account = state.accounts[index];
                  return Card(
                    child: ListTile(
                      enabled: !isActiveAccountLoading,
                      leading: Hero(
                        tag: account.accountId,
                        child: CircleAvatar(
                          backgroundColor: account.themeColor,
                          foregroundImage: account.avatarImageProvider,
                          child: Text(_accountNameAbbreviation(account.name)),
                        ),
                      ),
                      title: Text(account.name),
                      isThreeLine: account.description != null,
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(account.balance.format()), // Display the balance
                          if (account.description != null)
                            Text(account.description!),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _onProfileEdit(account),
                      ),
                      onTap: () => _onTapAccount(account),
                    ),
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  context.read<AccountFormBloc>().add(
                        AccountFormStartedEvent(account: null),
                      );
                  Beamer.of(context)
                      .beamToNamed(AppRoutes.accounts.createAccount());
                },
                child: Icon(Icons.add),
              ),
            );
          } else if (state is AccountsListError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return Center(child: Text('No accounts loaded.'));
          }
        },
      ),
    );
  }

  void _onPressesLogOut() {
    context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
  }

  bool get _shouldShowLoadingIndicator {
    final state = context.read<AccountsListBloc>().state;
    return state is AccountsListLoadInProgress || state is AccountsListInitial;
  }

  void _onAccountsListStateChange(
      BuildContext context, AccountsListState state) {
    if (state is AccountsListError) {
      MainApp.rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  void _onActiveAccountStateChange(
      BuildContext context, ActiveAccountState state) {
    if (state is ActiveAccountSuccess) {
      Beamer.of(context).beamToNamed(AppRoutes.legacy.portfolio());
    } else if (state is ActiveAccountFailure) {
      MainApp.rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(state.error)),
      );
    }
  }

  void _onTapAccount(Account account) {
    context.read<ActiveAccountBloc>().add(
          ActiveAccountSwitchRequested(requestedAccountId: account.accountId),
        );
  }

  void _onProfileEdit(Account account) {
    context.read<AccountFormBloc>().add(
          AccountFormStartedEvent(account: account),
        );
    Beamer.of(context).beamToNamed(
      AppRoutes.accounts.editAccount(
        jsonEncode(account.accountId.toJson()),
      ),
    );
  }

  String _accountNameAbbreviation(String name) => name.initials(2);
}
