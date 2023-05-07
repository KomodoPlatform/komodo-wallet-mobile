// models/account_name.dart
import 'package:formz/formz.dart';

enum AccountNameValidationError { invalid }

class AccountName extends FormzInput<String, AccountNameValidationError> {
  const AccountName.pure() : super.pure('');
  const AccountName.dirty([String value = '']) : super.dirty(value);

  @override
  AccountNameValidationError? validator(String value) {
    return value.isNotEmpty ? null : AccountNameValidationError.invalid;
  }
}
