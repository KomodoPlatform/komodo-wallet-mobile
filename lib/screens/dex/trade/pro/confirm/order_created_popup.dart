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
                RaisedButton(
                  child: Text(
                    AppLocalizations.of(context).showMyOrders.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Colors.white),
                  ),
                  onPressed: () {
                    swapBloc.setIndexTabDex(1);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                FlatButton(
                  child: Text(AppLocalizations.of(context).close.toUpperCase()),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
          context: context)
      .then((dynamic _) {
    dialogBloc.dialog = null;
  });
}
