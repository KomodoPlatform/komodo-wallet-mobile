import 'package:equatable/equatable.dart';
import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';

/// [ActiveAccountEvent] is the base class for all the events related to the ActiveAccount bloc.
abstract class ActiveAccountEvent extends Equatable {
  const ActiveAccountEvent();

  @override
  List<Object?> get props => [];
}

/// [ActiveAccountStarted] is an event representing the initial loading of the active account.
///
/// This event should be dispatched when the ActiveAccount bloc is created or when the
/// application needs to refresh the active account information.
class ActiveAccountStarted extends ActiveAccountEvent {}

/// [ActiveAccountSwitchRequested] is an event representing a user's request to switch
/// to a new active account.
///
/// This event should be dispatched when the user requests to change the active account.
/// It contains the [requestedAccountId] which should be switched to.
class ActiveAccountSwitchRequested extends ActiveAccountEvent {
  final AccountId requestedAccountId;

  const ActiveAccountSwitchRequested({required this.requestedAccountId});

  @override
  List<Object?> get props => [requestedAccountId];
}

/// [ActiveAccountClearRequested] is an event representing a user's request to clear
/// the active account.
///
/// This event should be dispatched when the user requests to clear the active account
/// or when the application needs to reset the active account information.
class ActiveAccountClearRequested extends ActiveAccountEvent {}
