import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';

void showLogoutConfirmation(BuildContext context) {
  dialogBloc.dialog = showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(20),
          title: Row(
            children: <Widget>[
              Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).logout),
            ],
          ),
          children: <Widget>[
            const Text(
                'Are you sure you want to logout now?'), // TODO(yurii): localization
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                    child: RaisedButton(
                  color: Theme.of(context).dialogBackgroundColor,
                  elevation: 0,
                  key: const Key('settings-logout-yes'),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Theme.of(context).textTheme.caption.color),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () async {
                    dialogBloc.closeDialog(context);
                    await authBloc.logout();
                  },
                  child: Text(
                    AppLocalizations.of(context).logout.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: RaisedButton(
                  color: Theme.of(context).dialogBackgroundColor,
                  elevation: 0,
                  key: const Key('settings-logout-cancel'),
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
