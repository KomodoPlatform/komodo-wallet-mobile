import 'package:flutter/material.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:provider/provider.dart';

class BuildSwapButton extends StatefulWidget {
  const BuildSwapButton();

  @override
  _BuildSwapButtonState createState() => _BuildSwapButtonState();
}

class _BuildSwapButtonState extends State<BuildSwapButton> {
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    if (_constrProvider.matchingOrder == null) return SizedBox();

    return RaisedButton(
      onPressed: () {},
      child: Text('Swap'),
    );
  }
}
