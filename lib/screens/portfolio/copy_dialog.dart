import 'package:flutter/material.dart';
import '../../../widgets/custom_simple_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../localizations.dart';
import '../../../blocs/dialog_bloc.dart';
import '../../../model/coin.dart';
import '../../../utils/utils.dart';

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
                            maxLines: 3,
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
