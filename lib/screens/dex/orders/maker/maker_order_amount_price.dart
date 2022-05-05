import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/app_config/theme_data.dart';
import 'package:komodo_dex/screens/dex/orders/maker/order_fill.dart';
import 'package:provider/provider.dart';

class MakerOrderAmtAndPrice extends StatefulWidget {
  const MakerOrderAmtAndPrice(this.order);

  final Order order;

  @override
  _MakerOrderAmtAndPriceState createState() => _MakerOrderAmtAndPriceState();
}

class _MakerOrderAmtAndPriceState extends State<MakerOrderAmtAndPrice> {
  CexProvider cexProvider;

  @override
  Widget build(BuildContext context) {
    cexProvider ??= Provider.of<CexProvider>(context);

    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(1.0),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        ..._buildBase(),
        ..._buildRel(),
        ..._buildPrice(),
      ],
    );
  }

  List<TableRow> _buildBase() {
    final double filled =
        getFill(widget.order) * double.parse(widget.order.baseAmount);

    return [
      TableRow(children: [
        Container(
          height: 40,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(right: 6),
          child: Text(
            AppLocalizations.of(context).makerDetailsSell + ':',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 6),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.transparent,
                    backgroundImage:
                        AssetImage(getCoinIconPath(widget.order.base)),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.order.base,
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(formatPrice(double.parse(widget.order.baseAmount)),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      if (filled > 0)
                        Text(
                            formatPrice(
                                double.parse(widget.order.baseAmount) - filled),
                            style: TextStyle(
                              fontSize: 10,
                            )),
                    ],
                  ),
                ],
              ),
              _buildMinVolume(),
            ],
          ),
        )
      ])
    ];
  }

  Widget _buildMinVolume() {
    if (widget.order.minVolume == null) return SizedBox();
    if (widget.order.minVolume <= 0.00777) return SizedBox();

    return Row(
      children: <Widget>[
        SizedBox(width: 26),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
          ),
          padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
          child: Row(
            children: [
              Text(
                '${AppLocalizations.of(context).orderDetailsMin} '
                '${widget.order.base} '
                '${cutTrailingZeros(formatPrice(widget.order.minVolume))}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<TableRow> _buildRel() {
    final double filled =
        getFill(widget.order) * double.parse(widget.order.relAmount);

    return [
      TableRow(children: [
        Container(
          height: 40,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(right: 6),
          child: Text(
            AppLocalizations.of(context).makerDetailsFor + ':',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 6),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage(getCoinIconPath(widget.order.rel)),
              ),
              const SizedBox(width: 4),
              Text(
                widget.order.rel,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    formatPrice(double.parse(widget.order.relAmount)),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (filled > 0)
                    Text(
                        formatPrice(
                            double.parse(widget.order.relAmount) - filled),
                        style: TextStyle(
                          fontSize: 10,
                        )),
                ],
              ),
            ],
          ),
        )
      ])
    ];
  }

  List<TableRow> _buildPrice() {
    return [
      TableRow(
        children: [
          Container(
            height: 30,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: 6),
            child: Text(AppLocalizations.of(context).makerDetailsPrice + ':',
                style: Theme.of(context).textTheme.bodyText1),
          ),
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: <Widget>[
                Text(
                  formatPrice(double.parse(widget.order.relAmount) /
                      double.parse(widget.order.baseAmount)),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.order.rel} / 1${widget.order.base}',
                ),
              ],
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          SizedBox(),
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: <Widget>[
                Text(
                  formatPrice(double.parse(widget.order.baseAmount) /
                      double.parse(widget.order.relAmount)),
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Text('${widget.order.base} / 1${widget.order.rel}',
                    style: const TextStyle(
                      fontSize: 13,
                    )),
              ],
            ),
          ),
        ],
      ),
      ..._buildCexchangeRate(),
    ];
  }

  List<TableRow> _buildCexchangeRate() {
    final double cexPrice = cexProvider.getCexRate(CoinsPair(
          sell: Coin(abbr: widget.order.base),
          buy: Coin(abbr: widget.order.rel),
        )) ??
        0.0;
    if (cexPrice == 0) return [];

    final double price = double.parse(widget.order.relAmount) /
        double.parse(widget.order.baseAmount);
    double delta = (price - cexPrice) * 100 / cexPrice;
    if (delta < -99.99) delta = -99.99;
    if (delta > 99.99) delta = 99.99;
    final num sign = delta.sign;

    String message;
    Color color;

    switch (sign) {
      case 1:
        {
          message = AppLocalizations.of(context)
              .orderDetailsExpedient(formatPrice(delta, 2));
          color = Colors.green;
          break;
        }
      case -1:
        {
          message = AppLocalizations.of(context)
              .orderDetailsExpensive(formatPrice(delta, 2));
          color = Colors.orange;
          break;
        }
      default:
        {
          message = AppLocalizations.of(context).orderDetailsIdentical;
          color = Theme.of(context).brightness == Brightness.light
              ? cexColorLight.withAlpha(150)
              : cexColor.withAlpha(150);
        }
    }

    return [
      TableRow(
        children: [
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                CexMarker(
                  context,
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context).cex,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 6),
            height: 40,
            alignment: Alignment.centerLeft,
            child: Text(
              message,
              style: TextStyle(color: color),
            ),
          ),
        ],
      )
    ];
  }
}
