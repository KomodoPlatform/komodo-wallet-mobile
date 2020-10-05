import 'package:flutter/material.dart';

class MultiOrderConfirm extends StatefulWidget {
  @override
  _MultiOrderConfirmState createState() => _MultiOrderConfirmState();
}

class _MultiOrderConfirmState extends State<MultiOrderConfirm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: const Text('Confirm'),
      ),
      body: Container(
        child: const Text('Confirmation page'),
      ),
    );
  }
}
