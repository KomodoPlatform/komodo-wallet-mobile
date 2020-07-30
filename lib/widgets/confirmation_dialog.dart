import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';

void showConfirmationDialog({
  BuildContext context,
  String title = 'Confirm',
  IconData icon = Icons.warning,
  Color iconColor = Colors.red,
  String message = 'Are you sure?',
  Function onConfirm,
  String confirmButtonText = 'Confirm',
}) {
  dialogBloc.dialog = showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(20),
          title: Row(
            children: <Widget>[
              Icon(
                icon,
                color: iconColor,
              ),
              const SizedBox(width: 12),
              Text(title),
            ],
          ),
          children: <Widget>[
            Text(message),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                    child: RaisedButton(
                  color: Theme.of(context).dialogBackgroundColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Theme.of(context).textTheme.caption.color),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () {
                    dialogBloc.closeDialog(context);
                    if (onConfirm != null) onConfirm();
                  },
                  child: Text(
                    confirmButtonText.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: RaisedButton(
                  color: Theme.of(context).dialogBackgroundColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Theme.of(context).textTheme.caption.color),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () {
                    dialogBloc.closeDialog(context);
                  },
                  child: Text(
                    AppLocalizations.of(context).cancel.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                )),
              ],
            ),
          ],
        );
      });
}
