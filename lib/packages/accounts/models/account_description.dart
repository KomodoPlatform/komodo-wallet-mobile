import 'package:formz/formz.dart';

enum AccountDescriptionValidationError { invalid }

class AccountDescription
    extends FormzInput<String, AccountDescriptionValidationError> {
  const AccountDescription.pure() : super.pure('');
  const AccountDescription.dirty([String value = '']) : super.dirty(value);

  @override
  AccountDescriptionValidationError? validator(String value) {
    return value.isNotEmpty ? null : AccountDescriptionValidationError.invalid;
  }
}
