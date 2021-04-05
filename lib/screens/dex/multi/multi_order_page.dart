import 'package:flutter/material.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:komodo_dex/screens/dex/multi/multi_order_confirm.dart';
import 'package:komodo_dex/screens/dex/multi/multi_order_create.dart';
import 'package:provider/provider.dart';

class MultiOrderPage extends StatefulWidget {
  @override
  _MultiOrderPageState createState() => _MultiOrderPageState();
}

class _MultiOrderPageState extends State<MultiOrderPage> {
  MultiOrderProvider multiOrderProvider;

  @override
  Widget build(BuildContext context) {
    multiOrderProvider ??= Provider.of<MultiOrderProvider>(context);

    return multiOrderProvider.validated
        ? MultiOrderConfirm()
        : MultiOrderCreate();
  }
}
