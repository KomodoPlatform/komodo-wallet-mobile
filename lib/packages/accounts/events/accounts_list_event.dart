import 'package:equatable/equatable.dart';

abstract class AccountsListEvent extends Equatable {
  const AccountsListEvent();

  @override
  List<Object?> get props => [];
}

class AccountsListLoadRequested extends AccountsListEvent {}

class AccountsListSubscriptionRequested extends AccountsListEvent {}
