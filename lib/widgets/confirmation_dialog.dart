import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';

void showConfirmationDialog({
  BuildContext context,
  String title = 'Confirm',
  IconData icon = Icons.warning,
  Color iconColor,
  String message = 'Are you sure?',
  Function onConfirm,
  String confirmButtonText = 'Confirm',
  Key key,
}) {
  dialogBloc.dialog = showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CustomSimpleDialog(
          title: Row(
            children: <Widget>[
              Icon(
                icon,
                color: iconColor ?? Theme.of(context).textTheme.bodyText2.color,
              ),
              const SizedBox(width: 12),
              Text(title),
            ],
          ),
          children: <Widget>[
            Text(message),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    dialogBloc.closeDialog(context);
                  },
                  child: Text(
                    AppLocalizations.of(context).cancel.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.normal),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 12),
                RaisedButton(
                  key: key ?? const Key('confirm-button-key'),
                  onPressed: () {
                    dialogBloc.closeDialog(context);
                    if (onConfirm != null) onConfirm();
                  },
                  child: Text(
                    confirmButtonText.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.normal),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        );
      }).then((dynamic _) => dialogBloc.dialog = null);
}
