import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';
import 'package:komodo_dex/navigation/app_routes.dart';
import 'package:komodo_dex/packages/accounts/pages/account_form_page.dart';
import 'package:komodo_dex/packages/accounts/pages/accounts_list_page.dart';
import 'package:komodo_dex/packages/authentication/navigation/authentication_guard.dart';
import 'account_routes.dart';

class AccountsManagementLocation extends BeamLocation<BeamState> {
  final AccountRoutes accountRoutes = AppRoutes.accounts;

  @override
  List<String> get pathPatterns => [
        accountRoutes.accountsPattern,
        accountRoutes.createAccountPattern,
        accountRoutes.editAccountPattern,
      ];

  @override
  List<BeamGuard> get guards => [AuthenticationGuard.authenticated()];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        key: ValueKey('accounts'),
        child: AccountsListPage(),
      ),
      if (state.pathPatternSegments.contains('create'))
        BeamPage(
          key: ValueKey('accounts-create'),
          child: AccountFormPage(),
        ),
      if (state.pathPatternSegments.contains('edit'))
        BeamPage(
          key: ValueKey('accounts-edit-${state.pathParameters['accountId']}'),
          child: AccountFormPage(),
        ),
    ];
  }
}
