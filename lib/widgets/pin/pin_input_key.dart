part of 'pin_input.dart';

class _PinInputKey extends StatelessWidget {
  const _PinInputKey({
    Key key,
    this.text,
    @required this.value,
    @required this.onPressed,
  }) : super(key: key);

  final String text;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Circular button showing value at top and text below it if not empty
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).colorScheme.primaryContainer,
        // onPrimary: Colors.black,
        shape: const CircleBorder(),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18.0),
          ),
          if (text?.isNotEmpty == true)
            Text(
              text,
              style: Theme.of(context).textTheme.caption,
            ),
        ],
      ),
    );
  }
}
