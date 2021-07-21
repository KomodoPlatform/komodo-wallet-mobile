import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/utils/utils.dart';

void openNotEnoughVolumeDialog(BuildContext context, Ask ask) {
  final String baseCoin = swapBloc.sellCoinBalance.coin.abbr;

  dialogBloc.dialog = showDialog<void>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            AppLocalizations.of(context).insufficientTitle,
            maxLines: 1,
            style: TextStyle(fontSize: 22),
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          children: [
            Text('${AppLocalizations.of(context).insufficientText}:'),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(200),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 7,
                        backgroundImage: AssetImage('assets/'
                            '${ask.coin.toLowerCase()}.png'),
                      ),
                      SizedBox(width: 4),
                      Text(
                          '${ask.coin} ' +
                              cutTrailingZeros(formatPrice(ask.minVolume)),
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.w400,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
            Row(
              children: [
                CircleAvatar(
                  radius: 5,
                  backgroundImage: AssetImage('assets/'
                      '${baseCoin.toLowerCase()}.png'),
                ),
                SizedBox(width: 3),
                Text(baseCoin,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).disabledColor,
                    )),
                SizedBox(width: 2),
                Text(
                    cutTrailingZeros(formatPrice(
                        ask.minVolume.toDouble() * double.parse(ask.price))),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).disabledColor,
                    )),
              ],
            ),
            SizedBox(height: 20),
            RaisedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).close),
            ),
          ],
        );
      }).then((dynamic _) => dialogBloc.dialog = null);
}
