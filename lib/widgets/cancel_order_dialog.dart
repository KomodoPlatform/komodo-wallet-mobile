import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
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
  bool askCancelOrderAgain = true;
  dialogBloc.dialog = showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
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
                children: [
                  SizedBox(
                    height: 24.0,
                    width: 24.0,
                    child: Checkbox(
                        key: const Key('cancel-order-ask-again'),
                        value: !askCancelOrderAgain,
                        onChanged: (val) {
                          setState(() {
                            askCancelOrderAgain = !askCancelOrderAgain;
                          });
                        }),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          askCancelOrderAgain = !askCancelOrderAgain;
                        });
                      },
                      child: Text(AppLocalizations.of(context).dontAskAgain)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    key: const Key('settings-cancel-order-no'),
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
                      settingsBloc
                          .setShowCancelOrderDialog(askCancelOrderAgain);
                      dialogBloc.closeDialog(context);
                      onConfirm();
                    },
                    child: Text(
                      AppLocalizations.of(context).yes,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      }).then((dynamic _) => dialogBloc.dialog = null);
}
