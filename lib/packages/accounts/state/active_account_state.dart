import 'package:equatable/equatable.dart';
import 'package:komodo_dex/packages/accounts/models/account.dart';

/// [ActiveAccountState] is the base abstract class for all ActiveAccount states.
///
/// This class is used as a base for all other states to extend.
abstract class ActiveAccountState extends Equatable {
  const ActiveAccountState();

  Account? get activeOrPendingAccount => this is ActiveAccountSuccess
      ? (this as ActiveAccountSuccess).account
      : this is ActiveAccountSwitchInProgress
          ? (this as ActiveAccountSwitchInProgress).account
          : null;

  Account? get activeAccount => this is ActiveAccountSuccess
      ? (this as ActiveAccountSuccess).account
      : null;

  @override
  List<Object?> get props;

  Map<String, dynamic> toJson() => throw UnimplementedError();

  static ActiveAccountState fromJson(Map<String, dynamic> json) {
    switch (json['stateName'] as String) {
      case 'ActiveAccountInProgress':
        return ActiveAccountInProgress();
      case 'ActiveAccountSuccess':
        return ActiveAccountSuccess(account: Account.fromJson(json['account']));
      case 'ActiveAccountFailure':
        return ActiveAccountFailure(error: json['error']);
      case 'ActiveAccountSwitchInProgress':
        return ActiveAccountSwitchInProgress(
          account: Account.fromJson(json['account']),
          requestedAccount: Account.fromJson(json['requestedAccount']),
        );
      default:
        return ActiveAccountInitial();
    }
  }

  static String typeName(Type type) => stateNames[type]!;

  static Map<Type, String> get stateNames => {
        ActiveAccountInitial: 'ActiveAccountInitial',
        ActiveAccountInProgress: 'ActiveAccountInProgress',
        ActiveAccountSuccess: 'ActiveAccountSuccess',
        ActiveAccountFailure: 'ActiveAccountFailure',
        ActiveAccountSwitchInProgress: 'ActiveAccountSwitchInProgress',
      };
}

/// [ActiveAccountInitial] represents the initial state of the ActiveAccount bloc.
///
/// This state indicates that no action has been performed yet, and the active account status
/// is unknown or not yet loaded. The UI should show a loading indicator or a neutral state.
class ActiveAccountInitial extends ActiveAccountState {
  @override
  Map<String, dynamic> toJson() =>
      {'stateName': ActiveAccountState.typeName(runtimeType)};

  @override
  List<Object?> get props => [];
}

/// [ActiveAccountInProgress] represents the state when the ActiveAccount bloc is in progress
/// of loading or performing an action.
///
/// In this state, the UI should show a loading indicator or disable the relevant UI components
/// to prevent user interaction until the action is complete.
class ActiveAccountInProgress extends ActiveAccountState {
  @override
  Map<String, dynamic> toJson() => {
        'stateName': ActiveAccountState.typeName(runtimeType),
      };

  @override
  List<Object?> get props => [];
}

/// [ActiveAccountSuccess] represents the state when the ActiveAccount bloc has successfully
/// retrieved or changed the active account.
///
/// This state includes the current active [Account]. The UI should update to display
/// the active account information and allow the user to interact with it.
class ActiveAccountSuccess extends ActiveAccountState {
  final Account account;

  const ActiveAccountSuccess({required this.account});

  @override
  List<Object?> get props => [account];

  @override
  Map<String, dynamic> toJson() => {
        'stateName': ActiveAccountState.typeName(runtimeType),
        'account': account.toJson(),
      };
}

/// [ActiveAccountFailure] represents the state when the ActiveAccount bloc has encountered
/// an error while retrieving or changing the active account.
///
/// In this state, the UI should display an error message or provide a way for the user to
/// retry the action.
class ActiveAccountFailure extends ActiveAccountState {
  final String error;

  final Exception? exception;

  const ActiveAccountFailure({required this.error, this.exception});

  @override
  List<Object?> get props => [error, exception];

  @override
  Map<String, dynamic> toJson() => {
        'stateName': ActiveAccountState.typeName(runtimeType),
        'error': error,
      };
}

/// [ActiveAccountSwitchInProgress] represents the state when the ActiveAccount bloc is in progress
/// of changing the active account to a new one.
///
/// This state includes the current active [Account] and the requested [Account] to switch to.
/// The UI should show a loading indicator or disable the relevant UI components to prevent
/// user interaction until the switch is complete.
class ActiveAccountSwitchInProgress extends ActiveAccountState {
  final Account account;
  final Account requestedAccount;

  const ActiveAccountSwitchInProgress({
    required this.account,
    required this.requestedAccount,
  });

  @override
  List<Object?> get props => [account, requestedAccount];

  @override
  Map<String, dynamic> toJson() => {
        'stateName': ActiveAccountState.typeName(runtimeType),
        'account': account.toJson(),
        'requestedAccount': requestedAccount.toJson(),
      };
}
