import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/screens/dex/orders/maker_order_amount_price.dart';
import 'package:komodo_dex/utils/utils.dart';

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
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).makerDetailsTitle),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 12,
                  top: 12,
                  bottom: 16,
                ),
                child: MakerOrderAmtAndPrice(widget.order),
              ),
            ),
            if (widget.order.cancelable) _buildCancelButton(),
            _buildId(),
            _buildDate(),
          ],
        ),
      ),
    );
  }

  Widget _buildDate() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Text(
              AppLocalizations.of(context).makerDetailsCreated + ':',
              style: Theme.of(context).textTheme.body2,
            ),
          ),
          Builder(builder: (context) {
            return Container(
                padding: const EdgeInsets.all(8),
                child: Text(DateFormat().format(
                    DateTime.fromMillisecondsSinceEpoch(
                        widget.order.createdAt * 1000))));
          }),
        ],
      ),
    );
  }

  Widget _buildId() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Text(
              AppLocalizations.of(context).makerDetailsId + ':',
              style: Theme.of(context).textTheme.body2,
            ),
          ),
          Builder(builder: (context) {
            return InkWell(
                onTap: () {
                  copyToClipBoard(context, widget.order.uuid);
                },
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(widget.order.uuid)));
          }),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
      child: SizedBox(
        height: 30,
        child: OutlineButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          borderSide: const BorderSide(color: Colors.white),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              color: Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                    AppLocalizations.of(context)
                        .makerDetailsCancel
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.body2.copyWith(
                          color: Colors.white,
                        ))
              ],
            ),
          ),
          onPressed: () {
            ordersBloc.cancelOrder(widget.order.uuid);
          },
        ),
      ),
    );
  }
}
