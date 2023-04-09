import 'package:flutter/material.dart';
import 'package:komodo_dex/widgets/shake.dart';

part 'pin_input_key.dart';
part 'pin_input_keypad.dart';

@immutable
class PinInput extends StatelessWidget {
  final String value;
  final String? errorMessage;

  final bool errorState;
  final bool readOnly;
  final bool obscureText;

  final int length;

  final void Function(String)? onChanged;
  final void Function(String)? onPinComplete;

  const PinInput({
    Key? key,
    required this.value,
    this.errorMessage,
    this.errorState = false,
    this.readOnly = false,
    this.obscureText = false,
    this.length = 4,
    this.onChanged,
    this.onPinComplete,
  }) : super(key: key);

  Color _circleColor(int index) {
    if (errorState) {
      return !_isCharacterFilled(0) || _isCharacterFilled(index)
          ? Colors.red
          : Colors.red.shade200;
    }

    if (_isCharacterFilled(index)) {
      return obscureText ? Color(0xFF8EBEFF) : Colors.transparent;
    }
    return Color(0xFF1A3664);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              errorMessage ?? '',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.red),
            ),
          ),
          ShakeWidget(
            shake: errorState,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(
                length,
                (index) => Container(
                  color: Colors.transparent,
                  key: Key('pin-input-container-$index'),
                  padding: const EdgeInsets.all(8.0),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    // #8EBEFF
                    backgroundColor: _circleColor(index),
                    radius: 12,
                    key: Key('pin-input-circle-$index'),
                    child: (obscureText || !_isCharacterFilled(index))
                        ? null
                        : Text(
                            value[index],
                            key: Key('pin-input-empty-$index'),
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _KeyPad(
              readOnly: readOnly,
              onChanged: _onChangedHandler,
              value: value,
              canPressBackspace: canPressBackspace),
        ],
      ),
    );
  }

  /// Used to control when an updated value is reported.
  void _onChangedHandler(String newValue) {
    // Ignore any changes if the field is already complete.
    if (newValue.length >= length && value.length >= length) return;

    // The user cannot make any changes in read-only mode
    if (readOnly) return;

    // If the field did not change, do not report the change.
    if (newValue == value) return;

    // Report the change.
    onChanged!(newValue);

    // If the field is complete, report the that the pin is complete.
    if (newValue.length == length && onPinComplete != null)
      onPinComplete!(newValue);
  }

  bool get canPressBackspace => value.isNotEmpty && !readOnly;

  bool _isCharacterFilled(int index) =>
      value != '' &&
      value.length > index &&
      (value[index]?.isNotEmpty ?? false);

  // false;
}
