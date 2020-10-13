import 'package:flutter/material.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:komodo_dex/screens/dex/trade/multi_order_base.dart';
import 'package:komodo_dex/screens/dex/trade/multi_order_rel_list.dart';
import 'package:provider/provider.dart';

class MultiOrderCreate extends StatefulWidget {
  @override
  _MultiOrderCreateState createState() => _MultiOrderCreateState();
}

class _MultiOrderCreateState extends State<MultiOrderCreate> {
  MultiOrderProvider multiOrderProvider;

  @override
  Widget build(BuildContext context) {
    multiOrderProvider ??= Provider.of<MultiOrderProvider>(context);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: <Widget>[
            MultiOrderBase(),
            const SizedBox(height: 6),
            MultiOrderRelList(),
            const SizedBox(height: 10),
            _buildButton(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    bool allowCreate = true;
    if (multiOrderProvider.baseCoin == null) allowCreate = false;
    if (multiOrderProvider.relCoins.isEmpty) allowCreate = false;

    final int qtt = multiOrderProvider.relCoins.length;

    return RaisedButton(
      disabledColor: Theme.of(context).disabledColor.withAlpha(100),
      onPressed: allowCreate
          ? () async {
              if (await multiOrderProvider.validate()) {
                multiOrderProvider.validated = true;
              } else {
                Scaffold.of(context).showSnackBar(SnackBar(
                    backgroundColor: Theme.of(context).backgroundColor,
                    content: Text(
                      // TODO(yurii): localization
                      'Please fix all errors before continuing',
                      style: TextStyle(
                        color: Theme.of(context).errorColor,
                      ),
                    )));
              }
            }
          : null,
      // TODO(yurii): localization
      child:
          Text(qtt > 0 ? 'Create $qtt Order${qtt > 1 ? 's' : ''}' : 'Create'),
    );
  }
}
