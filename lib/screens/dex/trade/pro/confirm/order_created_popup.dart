import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';

void showOrderCreatedDialog(BuildContext context) {
  dialogBloc.dialog = showDialog<dynamic>(
          builder: (BuildContext context) {
            return CustomSimpleDialog(
              title: Text(AppLocalizations.of(context).orderCreated),
              children: <Widget>[
                Text(AppLocalizations.of(context).orderCreatedInfo),
                SizedBox(height: 16),
              ],
              verticalButtons: [
                ElevatedButton(
                  onPressed: () {
                    swapBloc.setIndexTabDex(1);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context).showMyOrders),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context).close),
                )
              ],
            );
          },
          context: context)
      .then((dynamic _) {
    dialogBloc.dialog = null;
  });
}
