import 'package:flutter/material.dart';
import '../../../../../../generic_blocs/dialog_bloc.dart';
import '../../../../../../model/orderbook.dart';
import '../../../../../dex/trade/pro/create/receive/in_progress_popup.dart';
import '../../../../../dex/trade/pro/create/receive/matching_orderbooks.dart';

void openSelectReceiveCoinDialog({
  required BuildContext context,
  double? amountSell,
  Function(Ask)? onSelect,
  Function(String)? onCreate,
}) {
  dialogBloc.dialog = showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return InProgressPopup(
          key: const Key('buy-coin-dialog'),
          onDone: () {
            Navigator.of(context).pop();

            dialogBloc.dialog = showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return MatchingOrderbooks(
                    key: const Key('buy-coin-dialog'),
                    sellAmount: amountSell,
                    onCreatePressed: (String coin) => onCreate!(coin),
                    onBidSelected: (Ask bid) => onSelect!(bid),
                  );
                }).then((_) => dialogBloc.dialog = null);
          },
        );
      }).then((dynamic _) => dialogBloc.dialog = null);
}
