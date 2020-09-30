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
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            MultiOrderBase(),
            const SizedBox(height: 10),
            MultiOrderRelList(),
            const SizedBox(height: 10),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    return RaisedButton(
      onPressed: () {},
      child: const Text('Create'),
    );
  }
}
