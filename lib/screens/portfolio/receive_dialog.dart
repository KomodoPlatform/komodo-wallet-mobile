import 'package:flutter/material.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/utils/utils.dart';

void showReceiveDialog(BuildContext mContext, String address, Coin coin) {
  dialogBloc.dialog = showDialog<dynamic>(
    context: mContext,
    builder: (BuildContext context) {
      // return object of type Dialog
      return CustomSimpleDialog(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      copyToClipBoard(mContext, address);
                    },
                    child: QrImage(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      data: address,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    copyToClipBoard(mContext, address);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 16),
                            child: AutoSizeText(
                              address,
                              textKey: const Key('coin-details-address'),
                              style: Theme.of(context).textTheme.bodyText2,
                              maxLines: 2,
                            ),
                          )),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Icon(Icons.copy),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RaisedButton(
                      child: Text(
                        AppLocalizations.of(context).close.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
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
