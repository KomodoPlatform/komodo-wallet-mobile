import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../blocs/dialog_bloc.dart';
import '../../../localizations.dart';
import '../../../model/coin.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_simple_dialog.dart';

void showCopyDialog(BuildContext mContext, String address, Coin coin) {
  dialogBloc.dialog = showDialog<dynamic>(
    context: mContext,
    builder: (BuildContext context) {
      // return object of type Dialog
      return CustomSimpleDialog(
        key: Key('receive-dialog'),
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () => copyToClipBoard(mContext, address),
                    child: QrImage(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      data: address,
                    ),
                  ),
                ),
                InkWell(
                  key: Key('copy-address'),
                  onTap: () => copyToClipBoard(mContext, address),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 16),
                          child: AutoSizeText(
                            address,
                            textKey: const Key('coin-details-address'),
                            style: Theme.of(context).textTheme.bodyText1,
                            maxLines: 2,
                          ),
                        )),
                      ),
                      SizedBox(width: 8),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Icon(Icons.copy),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      key: Key('close-dialog'),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context).close),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    },
  ).then((dynamic data) {
    dialogBloc.dialog = null;
  });
}

void showReceivingCopyDialog(
  BuildContext mContext,
  Coin coin,
  String address,
  double amount,
  CexProvider cexProvider,
) {
  final themeData = Theme.of(mContext);

  final usdPrice = cexProvider.getUsdPrice(coin.abbr) ?? 0.0;
  final fiatPrice = cexProvider.getUsdPrice(cexProvider.selectedFiat) ?? 0.0;
  final fiatAmount = usdPrice * amount / fiatPrice;

  dialogBloc.dialog = showDialog<dynamic>(
    context: mContext,
    builder: (BuildContext context) {
      return CustomSimpleDialog(
        key: Key('receiving-dialog'),
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: <Widget>[
                Text(
                  '$amount ${coin.abbr}',
                  style: themeData.textTheme.headline5,
                ),
                if (fiatAmount > 0.0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${fiatAmount.toStringAsFixed(2)} ${cexProvider.selectedFiatSymbol}',
                    style: themeData.textTheme.subtitle2,
                  ),
                ],
                const SizedBox(height: 24),
                Expanded(
                  child: QrImage(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    data: '$address?$amount',
                  ),
                ),
                InkWell(
                  key: Key('copy-address'),
                  onTap: () => copyToClipBoard(mContext, address),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 16),
                          child: AutoSizeText(
                            address,
                            textKey: const Key('coin-details-address'),
                            style: Theme.of(context).textTheme.bodyText1,
                            maxLines: 2,
                          ),
                        )),
                      ),
                      SizedBox(width: 8),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Icon(Icons.copy),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      key: Key('close-dialog'),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context).close),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    },
  ).then((dynamic data) {
    dialogBloc.dialog = null;
  });
}
