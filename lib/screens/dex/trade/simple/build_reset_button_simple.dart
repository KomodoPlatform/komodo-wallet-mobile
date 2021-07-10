import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:provider/provider.dart';

class BuildResetButtonSimple extends StatefulWidget {
  @override
  _BuildResetButtonSimpleState createState() => _BuildResetButtonSimpleState();
}

class _BuildResetButtonSimpleState extends State<BuildResetButtonSimple> {
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    if (_constrProvider.matchingOrder == null) return SizedBox();

    return Container(
      padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
      child: FlatButton(
        onPressed: _isEnabled() ? _constrProvider.reset : null,
        child: Text(AppLocalizations.of(context).reset),
      ),
    );
  }

  bool _isEnabled() =>
      _constrProvider.sellCoin != null || _constrProvider.buyCoin != null;
}
