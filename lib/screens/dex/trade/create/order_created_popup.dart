import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';
import 'package:komodo_dex/widgets/sounds_explanation_dialog.dart';

void showOrderCreatedDialog(BuildContext context) {
  dialogBloc.dialog = showDialog<dynamic>(
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text(AppLocalizations.of(context).orderCreated),
              contentPadding: const EdgeInsets.all(24),
              children: <Widget>[
                Text(AppLocalizations.of(context).orderCreatedInfo),
                const SizedBox(
                  height: 16,
                ),
                PrimaryButton(
                  text: AppLocalizations.of(context).showMyOrders,
                  onPressed: () {
                    swapBloc.setIndexTabDex(1);
                    Navigator.of(context).pop();
                    showSoundsDialog(context);
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                SecondaryButton(
                  text: AppLocalizations.of(context).close,
                  onPressed: () {
                    Navigator.of(context).pop();
                    showSoundsDialog(context);
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
