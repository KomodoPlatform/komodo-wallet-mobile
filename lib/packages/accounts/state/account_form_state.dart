import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:formz/formz.dart';
import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';
import 'package:komodo_dex/packages/accounts/models/account_description.dart';
import 'package:komodo_dex/packages/accounts/models/account_name.dart';

class AccountFormState extends Equatable with FormzMixin {
  const AccountFormState({
    required this.accountId,
    required this.name,
    required this.description,
    required this.themeColor,
    required this.avatar,
    required this.submissionStatus,
    String? error,
  }) : _error = error;

  // const AccountFormState.update({required this.accountId})
  //     : name = const AccountName.pure(),
  //       description = const AccountDescription.pure(),
  //       submissionStatus = FormzSubmissionStatus.initial;

  const AccountFormState.initial()
      : accountId = null,
        name = const AccountName.pure(),
        description = const AccountDescription.pure(),
        themeColor = null,
        avatar = null,
        submissionStatus = FormzSubmissionStatus.initial,
        _error = null;

  /// The [accountId] is null when creating a new account.
  final AccountId? accountId;
  final AccountName name;
  final AccountDescription description;
// TODO: create custom FormzInput classes for the themeColor and avatar fields,
// like the existing AccountName and AccountDescription classes, to handle
// validation and other logic specific to these fields.
  final Color? themeColor;
  final Uint8List? avatar;
  final FormzSubmissionStatus submissionStatus;
  final String? _error;

  String? get error => submissionStatus.isFailure ? _error : null;

  AccountFormState copyWith({
    // Be weary of passing a null accountId if the current state has a non-null
    // accountId - this will be ignored because of how Dart works.
    AccountId? accountId,
    AccountName? name,
    AccountDescription? description,
    Color? themeColor,
    Uint8List? avatar,
    FormzSubmissionStatus? submissionStatus,
    String? error,
  }) {
    return AccountFormState(
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      description: description ?? this.description,
      themeColor: themeColor ?? this.themeColor,
      avatar: avatar ?? this.avatar,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      error: error ?? _error,
    );
  }

  @override
  List<FormzInput> get inputs => [name, description];

  @override
  List<Object?> get props => [
        accountId,
        name,
        description,
        themeColor,
        avatar,
        submissionStatus,
      ];
}
