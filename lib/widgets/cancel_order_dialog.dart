import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';

void showCancelOrderDialog({
  BuildContext context,
  Key key,
  Function onConfirm,
}) {
  if (!settingsBloc.showCancelOrderDialog) {
    onConfirm();
    return;
  }

  dialogBloc.dialog = showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CustomSimpleDialog(
          title: Row(
            children: <Widget>[
              Icon(
                Icons.warning,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).cancelOrder),
            ],
          ),
          children: <Widget>[
            Text(AppLocalizations.of(context).confirmCancel),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => dialogBloc.closeDialog(context),
                  child: Text(
                    AppLocalizations.of(context).no,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  key: key ?? const Key('confirm-button-key'),
                  onPressed: () {
                    dialogBloc.closeDialog(context);
                    try {
                      onConfirm();
                    } catch (e) {
                      showMessage(context, 'Order has been matched');
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context).yes,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, top: 6.0),
              child: Text(AppLocalizations.of(context).noteOnOrder),
            ),
            Row(
              children: [
                StreamBuilder<bool>(
                    initialData: settingsBloc.showCancelOrderDialog,
                    stream: settingsBloc.outShowCancelOrderDialog,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return SizedBox();
                      return SizedBox(
                        height: 24.0,
                        width: 24.0,
                        child: Checkbox(
                            value: !snapshot.data,
                            onChanged: (val) {
                              settingsBloc.setShowCancelOrderDialog(!val);
                            }),
                      );
                    }),
                const SizedBox(width: 12),
                GestureDetector(
                    onTap: () {
                      settingsBloc.setShowCancelOrderDialog(
                          !settingsBloc.showCancelOrderDialog);
                    },
                    child: Text(AppLocalizations.of(context).dontAskAgain)),
              ],
            )
          ],
        );
      }).then((dynamic _) => dialogBloc.dialog = null);
}
