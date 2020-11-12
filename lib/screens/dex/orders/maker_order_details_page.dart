import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order.dart';

class MakerOrderDetailsPage extends StatefulWidget {
  const MakerOrderDetailsPage(this.order);

  final Order order;

  @override
  _MakerOrderDetailsPageState createState() => _MakerOrderDetailsPageState();
}

class _MakerOrderDetailsPageState extends State<MakerOrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).makerDetailsTitle),
      ),
    );
  }
}
