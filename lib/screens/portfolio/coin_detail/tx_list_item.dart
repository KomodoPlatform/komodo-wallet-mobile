import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/warning_transaction_list_item.dart';
import '../../../../blocs/settings_bloc.dart';
import '../../../../model/cex_provider.dart';
import '../../../../model/coin_balance.dart';
import '../../../../model/transaction_data.dart';
import '../../../../services/db/database.dart';
import '../../../../utils/utils.dart';
import 'package:provider/provider.dart';

import '../transaction_detail.dart';

class TransactionListItem extends StatefulWidget {
  const TransactionListItem(
      {this.transaction, this.currentCoinBalance, Key key})
      : super(key: key);

  final Transaction transaction;
  final CoinBalance currentCoinBalance;

  @override
  _TransactionListItemState createState() => _TransactionListItemState();
}

class _TransactionListItemState extends State<TransactionListItem> {
  CexProvider cexProvider;
  bool isNoteExpanded = false;

  double get transactionValue =>
      double.parse(widget.transaction.myBalanceChange);

  bool get isWarningTransaction => transactionValue == 0;

  @override
  Widget build(BuildContext context) {
    cexProvider ??= Provider.of<CexProvider>(context);

    final TextStyle subtitle = Theme.of(context)
        .textTheme
        .subtitle1
        .copyWith(fontWeight: FontWeight.bold);

    if (isWarningTransaction) {
      return WarningTransactionListItem(
        address: widget.transaction.from.join(', '),
      );
    }

    return Card(
        child: InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      onTap: () => Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => TransactionDetail(
              transaction: widget.transaction,
              coinBalance: widget.currentCoinBalance),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: double.parse(
                                        widget.transaction.myBalanceChange) >
                                    0
                                ? Colors.green
                                : Colors.redAccent,
                            width: 2)),
                    child: double.parse(widget.transaction.myBalanceChange) > 0
                        ? Icon(Icons.arrow_downward)
                        : Icon(Icons.arrow_upward)),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 8),
                      child: StreamBuilder<bool>(
                          initialData: settingsBloc.showBalance,
                          stream: settingsBloc.outShowBalance,
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            final amount =
                                deci(widget.transaction.myBalanceChange);
                            String amountString = deci2s(amount);
                            if (snapshot.hasData && snapshot.data == false) {
                              amountString =
                                  (amount.toDouble() < 0 ? '-' : '') + '**.**';
                            }
                            return AutoSizeText(
                              '${amount.toDouble() > 0 ? '+' : ''}$amountString ${widget.currentCoinBalance.coin.abbr}',
                              maxLines: 1,
                              style: subtitle,
                              textAlign: TextAlign.end,
                            );
                          }),
                    ),
                    StreamBuilder<bool>(
                        initialData: settingsBloc.showBalance,
                        stream: settingsBloc.outShowBalance,
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          if (widget.currentCoinBalance.priceForOne == null) {
                            return const Padding(
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, bottom: 16, top: 8),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                ));
                          } else {
                            final usdAmount =
                                deci(widget.currentCoinBalance.priceForOne) *
                                    deci(widget.transaction.myBalanceChange);
                            if (usdAmount != deci(0)) {
                              bool hidden = false;
                              if (snapshot.hasData && snapshot.data == false) {
                                hidden = true;
                              }
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 16, top: 8),
                                child: Text(
                                  cexProvider.convert(
                                    usdAmount.toDouble(),
                                    hidden: hidden,
                                  ),
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              );
                            }
                            return SizedBox();
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
          FutureBuilder<String>(
              future: Db.getNote(widget.transaction.txHash),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                }
                return InkWell(
                  onTap: () {
                    setState(() {
                      isNoteExpanded = !isNoteExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      snapshot.data,
                      maxLines: isNoteExpanded ? null : 1,
                      overflow: isNoteExpanded ? null : TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                );
              }),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            height: 1,
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    widget.transaction.getTimeFormat(),
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
                Expanded(child: SizedBox()),
                Builder(
                  builder: (BuildContext context) {
                    return widget.transaction.confirmations > 0
                        ? Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(16)),
                                color: Colors.green),
                          )
                        : Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(16)),
                                color: Colors.red),
                          );
                  },
                )
              ],
            ),
          )
        ],
      ),
    ));
  }
}
