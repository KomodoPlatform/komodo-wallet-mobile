import 'package:flutter/material.dart';
import '../../../../model/multi_order_provider.dart';
import '../../../dex/trade/multi/multi_order_confirm.dart';
import '../../../dex/trade/multi/multi_order_create.dart';
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
