import 'package:flutter/material.dart';

class BuildSwapButton extends StatefulWidget {
  const BuildSwapButton();

  @override
  _BuildSwapButtonState createState() => _BuildSwapButtonState();
}

class _BuildSwapButtonState extends State<BuildSwapButton> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {},
      child: Text('Swap'),
    );
  }
}
