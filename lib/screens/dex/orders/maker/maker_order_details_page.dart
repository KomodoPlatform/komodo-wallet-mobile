import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/orders/maker/maker_order_amount_price.dart';
import 'package:komodo_dex/screens/dex/orders/maker/maker_order_note.dart';
import 'package:komodo_dex/screens/dex/orders/maker/maker_order_swaps.dart';
import 'package:komodo_dex/screens/dex/orders/maker/order_fill.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/sound_volume_button.dart';

class MakerOrderDetailsPage extends StatefulWidget {
  const MakerOrderDetailsPage(this.orderId);

  final String orderId;

  @override
  _MakerOrderDetailsPageState createState() => _MakerOrderDetailsPageState();
}

class _MakerOrderDetailsPageState extends State<MakerOrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).makerDetailsTitle),
          actions: const <Widget>[
            SoundVolumeButton(),
          ],
        ),
        body: StreamBuilder<List<dynamic>>(
            initialData: ordersBloc.orderSwaps,
            stream: ordersBloc.outOrderSwaps,
            builder: (context, snapshot) {
              Order order;
              try {
                order = snapshot.data.firstWhere((dynamic item) =>
                    item is Order && item.uuid == widget.orderId);
              } catch (_) {}

              if (order == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) Navigator.of(context).pop();
                });
                return SizedBox();
              }

              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        elevation: 8,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
                          child: MakerOrderAmtAndPrice(order),
                        ),
                      ),
                      if (order.cancelable) _buildCancelButton(order),
                      _buildId(order),
                      _buildDate(order),
                      _buildNote(order),
                      _buildHistory(order),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget _buildNote(Order order) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).noteTitle + ':',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          MakerOrderNote(order),
        ],
      ),
    );
  }

  Widget _buildHistory(Order order) {
    final bool hasSwaps =
        order.startedSwaps != null && order.startedSwaps.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: OrderFill(
              order,
              size: 18,
            ),
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: !hasSwaps
                  ? Container(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                          AppLocalizations.of(context).makerDetailsNoSwaps))
                  : _buildSwaps(order)),
        ],
      ),
    );
  }

  Widget _buildSwaps(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.fromLTRB(4, 4, 0, 8),
            child: Text(AppLocalizations.of(context).makerDetailsSwaps + ':')),
        MakerOrderSwaps(order),
      ],
    );
  }

  Widget _buildDate(Order order) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Text(
              AppLocalizations.of(context).makerDetailsCreated + ':',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Container(
              padding: const EdgeInsets.all(8),
              child: Text(DateFormat('dd MMM yyyy HH:mm').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      order.createdAt * 1000)))),
        ],
      ),
    );
  }

  Widget _buildId(Order order) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Text(
              AppLocalizations.of(context).makerDetailsId + ':',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Builder(builder: (context) {
            return InkWell(
              onTap: () => copyToClipBoard(context, order.uuid),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text(order.uuid),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCancelButton(Order order) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
      child: SizedBox(
        height: 30,
        child: OutlinedButton(
          onPressed: () => ordersBloc.cancelOrder(order.uuid),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              color: Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(AppLocalizations.of(context)
                    .makerDetailsCancel
                    .toUpperCase()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
