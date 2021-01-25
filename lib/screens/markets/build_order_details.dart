import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/addressbook/addressbook_page.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class BuildOrderDetails extends StatefulWidget {
  const BuildOrderDetails(this.order, {this.sellAmount});

  final Ask order;
  final double sellAmount;

  @override
  _BuildOrderDetailsState createState() => _BuildOrderDetailsState();
}

class _BuildOrderDetailsState extends State<BuildOrderDetails> {
  OrderBookProvider _orderBookProvider;
  AddressBookProvider _addressBookProvider;
  CexProvider _cexProvider;
  bool _isAsk;
  CoinsPair _activePair;
  Contact _contact;

  @override
  Widget build(BuildContext context) {
    _orderBookProvider ??= Provider.of<OrderBookProvider>(context);
    _addressBookProvider ??= Provider.of<AddressBookProvider>(context);
    _cexProvider ??= Provider.of<CexProvider>(context);
    _contact = _addressBookProvider.contactByAddress(widget.order.address);
    _activePair = _orderBookProvider.activePair;
    _isAsk = _activePair.sell.abbr == widget.order.coin;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 16,
        right: 12,
        top: 12,
        bottom: 24,
      ),
      child: Column(
        children: <Widget>[
          _buildOwnerWarning(),
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(1.0),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              ..._buildSellDetails(),
              ..._buildAddress(),
              ..._buildOrderDetails(),
              const TableRow(children: [
                SizedBox(height: 15),
                SizedBox(height: 15),
              ]),
              ..._buildPrice(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerWarning() {
    final String orderAdress = widget.order.address;
    final String myAddress =
        coinsBloc.getBalanceByAbbr(widget.order.coin)?.balance?.address;

    if (orderAdress.toLowerCase() != myAddress.toLowerCase())
      return Container();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(children: [
          WidgetSpan(
              alignment: PlaceholderAlignment.top,
              child: Icon(
                Icons.brightness_1,
                size: 13,
                color: _isAsk ? Colors.red : Colors.green,
              )),
          TextSpan(
            text: AppLocalizations.of(context).ownOrder,
            style: TextStyle(
                color: _isAsk ? Colors.red : Colors.green, fontSize: 20),
          ),
        ]),
      ),
    );
  }

  List<TableRow> _buildPrice() {
    return [
      TableRow(
        children: [
          Container(
            height: 30,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: 6),
            child: Text(AppLocalizations.of(context).orderDetailsPrice,
                style: Theme.of(context).textTheme.bodyText1),
          ),
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: <Widget>[
                Text(
                  formatPrice(
                      '${_isAsk ? widget.order.price : (1 / double.parse(widget.order.price)).toString()}'),
                  style: TextStyle(color: _isAsk ? Colors.red : Colors.green),
                ),
                const SizedBox(width: 6),
                Text(
                  '${_activePair.buy.abbr} / 1${_activePair.sell.abbr}',
                ),
              ],
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          Container(),
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: <Widget>[
                Text(
                  formatPrice(
                      '${!_isAsk ? widget.order.price : (1 / double.parse(widget.order.price)).toString()}'),
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Text('${_activePair.sell.abbr} / 1${_activePair.buy.abbr}',
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
    final double cexPrice = _cexProvider.getCexRate() ?? 0.0;
    if (cexPrice == 0 || widget.sellAmount == null) return [];

    final double orderPrice = 1 / double.parse(widget.order.price);
    final double delta = (cexPrice - orderPrice) * 100 / orderPrice;
    final num sign = delta.sign;

    String message;
    switch (sign) {
      case -1:
        {
          message = AppLocalizations.of(context)
              .orderDetailsExpedient(formatPrice(delta, 2));
          break;
        }
      case 1:
        {
          message = AppLocalizations.of(context)
              .orderDetailsExpensive(formatPrice(delta, 2));
          break;
        }
      default:
        {
          message = AppLocalizations.of(context).orderDetailsIdentical;
        }
    }

    return [
      TableRow(
        children: [
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            child: CexMarker(context),
          ),
          Container(
            padding: const EdgeInsets.only(left: 6),
            height: 40,
            alignment: Alignment.centerLeft,
            child: Text(
              message,
              style: const TextStyle(color: cexColor),
            ),
          ),
        ],
      )
    ];
  }

  List<TableRow> _buildOrderDetails() {
    if (widget.sellAmount != null) return [];

    return [
      TableRow(
        children: [
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: 6),
            child: Text(AppLocalizations.of(context).orderDetailsSells,
                style: Theme.of(context).textTheme.bodyText1),
          ),
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 7,
                      backgroundImage: _isAsk
                          ? AssetImage('assets/'
                              '${_activePair.sell.abbr.toLowerCase()}.png')
                          : AssetImage('assets/'
                              '${_activePair.buy.abbr.toLowerCase()}.png'),
                    ),
                    const SizedBox(width: 4),
                    Text(_isAsk ? _activePair.sell.abbr : _activePair.buy.abbr),
                    const SizedBox(width: 12),
                    Text(
                      formatPrice(widget.order.maxvolume.toString()),
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ],
                ),
                _buildMinVolume(),
              ],
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: 6),
            child: Text(AppLocalizations.of(context).orderDetailsFor,
                style: Theme.of(context).textTheme.bodyText1),
          ),
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 7,
                  backgroundImage: _isAsk
                      ? AssetImage(
                          'assets/${_activePair.buy.abbr.toLowerCase()}.png')
                      : AssetImage(
                          'assets/${_activePair.sell.abbr.toLowerCase()}.png'),
                ),
                const SizedBox(width: 4),
                Text(_isAsk ? _activePair.buy.abbr : _activePair.sell.abbr),
                const SizedBox(width: 12),
                Text(
                  formatPrice(
                      '${widget.order.maxvolume.toDouble() * double.parse(widget.order.price)}'),
                  style: Theme.of(context).textTheme.subtitle2.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  bool _isEnoughVolume() {
    if (widget.order.minvolume == null) return true;
    if (widget.sellAmount == null) return true;

    final double myVolume =
        widget.order.getReceiveAmount(deci(widget.sellAmount)).toDouble();

    return myVolume >= widget.order.minvolume;
  }

  Widget _buildMinVolume() {
    if (widget.order.minvolume == null) return SizedBox();
    if (widget.order.minvolume <= 0.00777) return SizedBox();

    return Row(
      children: <Widget>[
        Text(
          '${AppLocalizations.of(context).orderDetailsMin} ${widget.order.coin} ',
          style: TextStyle(fontSize: 12),
        ),
        Text(
          cutTrailingZeros(formatPrice(widget.order.minvolume)),
          style: Theme.of(context).textTheme.subtitle2.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: !_isEnoughVolume() ? Colors.orange : null,
              ),
        ),
        if (!_isEnoughVolume()) ...{
          SizedBox(width: 2),
          Icon(Icons.warning, color: Colors.orange, size: 10)
        },
      ],
    );
  }

  List<TableRow> _buildSellDetails() {
    if (widget.sellAmount == null) return [];

    return [
      TableRow(
        children: [
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: 6),
            child: Text(AppLocalizations.of(context).orderDetailsReceive,
                style: Theme.of(context).textTheme.bodyText1),
          ),
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 7,
                      backgroundImage: _isAsk
                          ? AssetImage('assets/'
                              '${_activePair.sell.abbr.toLowerCase()}.png')
                          : AssetImage('assets/'
                              '${_activePair.buy.abbr.toLowerCase()}.png'),
                    ),
                    const SizedBox(width: 4),
                    Text(_isAsk ? _activePair.sell.abbr : _activePair.buy.abbr),
                    const SizedBox(width: 12),
                    Text(
                      formatPrice(widget.order
                          .getReceiveAmount(deci(widget.sellAmount))
                          .toDouble()),
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ],
                ),
                _buildMinVolume(),
              ],
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: 6),
            child: Text(AppLocalizations.of(context).orderDetailsSpend,
                style: Theme.of(context).textTheme.bodyText1),
          ),
          Container(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 7,
                  backgroundImage: _isAsk
                      ? AssetImage('assets/'
                          '${_activePair.buy.abbr.toLowerCase()}.png')
                      : AssetImage('assets/'
                          '${_activePair.sell.abbr.toLowerCase()}.png'),
                ),
                const SizedBox(width: 4),
                Text(_isAsk ? _activePair.buy.abbr : _activePair.sell.abbr),
                const SizedBox(width: 12),
                Text(
                  formatPrice(widget.order
                          .getReceiveAmount(deci(widget.sellAmount))
                          .toDouble() *
                      double.parse(widget.order.price)),
                  style: Theme.of(context).textTheme.subtitle2.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<TableRow> _buildAddress() {
    return [
      TableRow(
        children: [
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: 6),
            child: Text(AppLocalizations.of(context).orderDetailsAddress,
                style: Theme.of(context).textTheme.bodyText1),
          ),
          _contact == null ? _buildAddressButton() : _buildContactButton(),
        ],
      ),
    ];
  }

  Widget _buildAddressButton() {
    return InkWell(
      onTap: () {
        copyToClipBoard(context, widget.order.address);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 6, right: 12),
        height: 40,
        child: truncateMiddle(widget.order.address),
      ),
    );
  }

  Widget _buildContactButton() {
    return InkWell(
      onTap: () {
        Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => AddressBookPage(
                contact: _contact,
              ),
            ));
      },
      child: Container(
        padding: const EdgeInsets.only(left: 6),
        height: 40,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              _contact.name,
            )
          ],
        ),
      ),
    );
  }
}
