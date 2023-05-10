class AccountRoutes {
  String list() => accountsPattern;

  String createAccount() => createAccountPattern;

  String editAccount(String accountId) =>
      editAccountPattern.replaceAll(':accountId', accountId);

  final String accountsPattern = '/accounts';
  final String createAccountPattern = '/accounts/create';
  final String editAccountPattern = '/accounts/edit/:accountId';
}
