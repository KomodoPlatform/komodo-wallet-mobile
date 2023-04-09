import 'package:flutter/foundation.dart';
import 'package:formz/formz.dart';
import 'package:komodo_dex/utils/utils.dart';

enum PasswordValidationError { empty, length, invalid }

@immutable
class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([String value = '']) : super.dirty(value);

  final int requiredLength = 8; // Adjust the required password length

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    if (value.length < requiredLength) return PasswordValidationError.length;
    return null;
  }

  static Password fromJson(JsonMap json) {
    final passwordValue = json['password'] as String?;
    if (passwordValue == null) {
      return const Password.pure();
    }

    return Password.dirty(passwordValue);
  }

  JsonMap toJson() {
    return {
      'password': value,
    };
  }
}
