import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/warning_transaction_list_item.dart';
import 'package:provider/provider.dart';

import '../../../../blocs/settings_bloc.dart';
import '../../../../model/cex_provider.dart';
import '../../../../model/coin_balance.dart';
import '../../../../model/transaction_data.dart';
import '../../../../services/db/database.dart';
import '../../../../utils/utils.dart';
import '../transaction_detail.dart';

class TransactionListItem extends StatefulWidget {
  const TransactionListItem({
    this.transaction,
    this.currentCoinBalance,
    Key key,
  }) : super(key: key);

  final Transaction transaction;
  final CoinBalance currentCoinBalance;

  @override
  _TransactionListItemState createState() => _TransactionListItemState();
}

class _TransactionListItemState extends State<TransactionListItem> {
  CexProvider cexProvider;
  bool isNoteExpanded = false;

  String note;

  double get transactionValue =>
      double.parse(widget.transaction.myBalanceChange);

  bool get isWarningTransaction =>
      transactionValue == 0 && isErcType(widget.currentCoinBalance.coin);

  bool get isConfirmed => widget.transaction.confirmations > 0;

  bool get isReceived => double.parse(widget.transaction.myBalanceChange) > 0;

  /// Shows the shortened address of either the `to` field if the transaction is
  /// a send (our balance decreased), or otherwise, show the `from` field if
  /// it is a receive (our balance increased).
  String get formattedAddress {
    final addresses = isReceived
        ? widget.transaction.from
        : widget.transaction.getToAddress();

    String formatted = addresses.map((e) => formatAddressShort(e)).join(',');

    if (formatted.isEmpty) formatted = '**********';

    return formatted;
  }

  @override
  void initState() {
    super.initState();
    Db.getNote(widget.transaction.txHash).then((value) {
      if (mounted) setState(() => note = flattenParagraphs(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    cexProvider ??= Provider.of<CexProvider>(context);

    if (isWarningTransaction) {
      return WarningTransactionListItem(
        address: widget.transaction.from.join(', '),
      );
    }

    final hasNote = note?.isNotEmpty ?? false;

    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => TransactionDetail(
              transaction: widget.transaction,
              coinBalance: widget.currentCoinBalance,
            ),
          ),
        ),
        // Show date
        title: Text(widget.transaction.getTimeFormat()),
        isThreeLine: hasNote,
        dense: false,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 6),
            Text(
              formattedAddress,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            if (note != null) ...[
              SizedBox(height: 4),
              Text(
                note,
                maxLines: isNoteExpanded ? null : 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ],
        ),
        leading: Icon(
          isReceived ? Icons.arrow_downward : Icons.arrow_upward,
          size: 32,
          color: isReceived ? Colors.green : Colors.redAccent,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<bool>(
              initialData: settingsBloc.showBalance,
              stream: settingsBloc.outShowBalance,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                final amount = deci(widget.transaction.myBalanceChange);
                String amountString = deci2s(amount);
                if (snapshot.hasData && snapshot.data == false) {
                  amountString = (amount.toDouble() < 0 ? '-' : '') + '**.**';
                }
                return Text(
                  '${amount.toDouble() > 0 ? '+' : ''}$amountString',
                );
              },
            ),
            SizedBox(width: 8),
            Icon(
              isConfirmed ? Icons.check_circle : Icons.hourglass_bottom,
              color: isConfirmed
                  ? Theme.of(context).colorScheme.secondaryVariant
                  : Colors.amber,
            ),
          ],
        ),
      ),
    );
  }
}
