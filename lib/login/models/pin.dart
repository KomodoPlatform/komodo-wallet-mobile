import 'package:flutter/foundation.dart';
import 'package:formz/formz.dart';
import 'package:komodo_dex/utils/utils.dart';

enum PinValidationError { empty, length, invalid }

@immutable
class Pin extends FormzInput<String, PinValidationError> {
  const Pin.pure() : super.pure('');
  const Pin.dirty([String value = '']) : super.dirty(value);

  final int requiredLength = 6;

  @override
  PinValidationError? validator(String value) {
    if (value.isEmpty) return PinValidationError.empty;
    if (value.length < requiredLength) return PinValidationError.length;
    return null;
  }

  static Pin fromJson(JsonMap json) {
    final pinValue = json['pin'] as String?;
    if (pinValue == null) {
      return const Pin.pure();
    }

    return Pin.dirty(pinValue);
  }

  JsonMap toJson() {
    return {
      'pin': value,
    };
  }
}
