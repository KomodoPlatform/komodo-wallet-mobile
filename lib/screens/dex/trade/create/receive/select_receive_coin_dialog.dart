import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/dex/trade/create/receive/in_progress_popup.dart';
import 'package:komodo_dex/screens/dex/trade/create/receive/matching_orderbooks.dart';

void openSelectReceiveCoinDialog({
  BuildContext context,
  double amountSell,
  Function(Ask) onSelect,
  Function(String) onCreate,
}) {
  dialogBloc.dialog = showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return InProgressPopup(
          onDone: () {
            Navigator.of(context).pop();

            dialogBloc.dialog = showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return MatchingOrderbooks(
                    sellAmount: amountSell,
                    onCreatePressed: (String coin) => onCreate(coin),
                    onBidSelected: (Ask bid) => onSelect(bid),
                  );
                }).then((_) => dialogBloc.dialog = null);
          },
        );
      }).then((dynamic _) => dialogBloc.dialog = null);
}
