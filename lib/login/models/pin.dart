import 'package:formz/formz.dart';
import 'package:komodo_dex/utils/utils.dart';

enum PinValidationError { empty, length, invalid }

class Pin extends FormzInput<String, PinValidationError> {
  const Pin.pure() : super.pure('');
  const Pin.dirty([String value = '']) : super.dirty(value);

  @override
  PinValidationError? validator(String value) {
    if (value.isEmpty) return PinValidationError.empty;
    if (value.length < 6) return PinValidationError.length;
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

// Would be useful to use if there are multiple inputs in a form
// class PinForm with FormzMixin {
//   final Pin pin;

//   PinForm({
//     this.pin = const Pin.pure(),
//   });

//   @override
//   List<FormzInput> get inputs => [pin];

//   @override
// }

enum PinType { pin, camoPin }
