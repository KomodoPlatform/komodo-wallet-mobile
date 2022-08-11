import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:komodo_dex/screens/dex/trade/multi/multi_order_base.dart';
import 'package:komodo_dex/screens/dex/trade/multi/multi_order_rel_list.dart';
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

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildProgressBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            children: <Widget>[
              MultiOrderBase(),
              const SizedBox(height: 8),
              MultiOrderRelList(),
              const SizedBox(height: 16),
              _buildButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return SizedBox(
      height: 1,
      child: multiOrderProvider.processing()
          ? LinearProgressIndicator()
          : SizedBox(),
    );
  }

  Widget _buildButton() {
    bool allowCreate = true;
    if (multiOrderProvider.baseCoin == null) allowCreate = false;
    if (multiOrderProvider.relCoins.isEmpty) allowCreate = false;
    if (multiOrderProvider.processing()) allowCreate = false;

    final int qtt = multiOrderProvider.relCoins.length;

    return ElevatedButton(
      key: const Key('create-multi-order'),
      onPressed: allowCreate
          ? () async {
              if (await multiOrderProvider.validate()) {
                multiOrderProvider.validated = true;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                  AppLocalizations.of(context).multiFixErrors,
                  style: TextStyle(
                    color: Theme.of(context).errorColor,
                  ),
                )));
              }
            }
          : null,
      child: Text(qtt > 0
          ? (AppLocalizations.of(context).multiCreate +
              ' $qtt ' +
              (qtt > 1
                  ? AppLocalizations.of(context).multiCreateOrders
                  : AppLocalizations.of(context).multiCreateOrder))
          : AppLocalizations.of(context).multiCreate),
    );
  }
}
