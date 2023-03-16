part of 'pin_input.dart';

class _KeyPad extends StatelessWidget {
  const _KeyPad({
    Key? key,
    required this.readOnly,
    required this.onChanged,
    required this.value,
    required this.canPressBackspace,
  }) : super(key: key);

  final bool readOnly;
  final void Function(String) onChanged;
  final String value;
  final bool canPressBackspace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      constraints: BoxConstraints(maxWidth: 380),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 32,
        children: [
          _PinInputKey(
            key: Key('pin-input-key-1'),
            value: '1',
            onPressed: readOnly ? null : () => onChanged(value + '1'),
          ),

          _PinInputKey(
            key: Key('pin-input-key-2'),
            value: '2',
            text: 'ABC',
            onPressed: readOnly ? null : () => onChanged(value + '2'),
          ),

          _PinInputKey(
            key: Key('pin-input-key-3'),
            value: '3',
            text: 'DEF',
            onPressed: readOnly ? null : () => onChanged(value + '3'),
          ),

          _PinInputKey(
            key: Key('pin-input-key-4'),
            value: '4',
            text: 'GHI',
            onPressed: readOnly ? null : () => onChanged(value + '4'),
          ),

          _PinInputKey(
            key: Key('pin-input-key-5'),
            value: '5',
            text: 'JKL',
            onPressed: readOnly ? null : () => onChanged(value + '5'),
          ),

          _PinInputKey(
            key: Key('pin-input-key-6'),
            value: '6',
            text: 'MNO',
            onPressed: readOnly ? null : () => onChanged(value + '6'),
          ),

          _PinInputKey(
            key: Key('pin-input-key-7'),
            value: '7',
            text: 'PQRS',
            onPressed: readOnly ? null : () => onChanged(value + '7'),
          ),

          _PinInputKey(
            key: Key('pin-input-key-8'),
            value: '8',
            text: 'TUV',
            onPressed: readOnly ? null : () => onChanged(value + '8'),
          ),

          _PinInputKey(
            key: Key('pin-input-key-9'),
            value: '9',
            text: 'WXYZ',
            onPressed: readOnly ? null : () => onChanged(value + '9'),
          ),

          Container(),

          _PinInputKey(
            key: Key('pin-input-key-0'),
            value: '0',
            onPressed: readOnly ? null : () => onChanged(value + '0'),
          ),

          // Backspace key
          IconButton(
            onPressed: !canPressBackspace
                ? null
                : () => onChanged(value.substring(0, value.length - 1)),
            icon: Icon(
              Icons.backspace_outlined,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
