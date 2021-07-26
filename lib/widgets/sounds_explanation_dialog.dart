import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/settings/sound_settings_page.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';

Future<void> showSoundsDialog(BuildContext context) async {
  if (!settingsBloc.showSoundsExplanationDialog) return;

  dialogBloc.dialog = Future<void>(() {});
  await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CustomSimpleDialog(
          title: Row(
            children: <Widget>[
              Icon(
                Icons.audiotrack,
                color: Theme.of(context).accentColor,
              ),
              SizedBox(width: 4),
              Text(AppLocalizations.of(context).soundsDialogTitle),
            ],
          ),
          children: <Widget>[
            Text(
              AppLocalizations.of(context).soundsExplanation,
              textAlign: TextAlign.justify,
            ),
            Text(
              AppLocalizations.of(context).soundsNote,
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 12),
            Row(
              children: <Widget>[
                StreamBuilder<bool>(
                    initialData: settingsBloc.showSoundsExplanationDialog,
                    stream: settingsBloc.outShowSoundsDialog,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();

                      return Checkbox(
                          value: !snapshot.data,
                          onChanged: (val) {
                            settingsBloc.setShowSoundsDialog(!val);
                          });
                    }),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      settingsBloc.setShowSoundsDialog(
                          !settingsBloc.showSoundsExplanationDialog);
                    },
                    child: Text(
                      AppLocalizations.of(context).soundsDoNotShowAgain,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                    child: FlatButton(
                  onPressed: () {
                    dialogBloc.dialog = null;
                    Navigator.of(context).pop();
                    Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) =>
                              SoundSettingsPage()),
                    );
                  },
                  child: Text(AppLocalizations.of(context).settings),
                )),
                SizedBox(width: 12),
                Expanded(
                  child: RaisedButton(
                    onPressed: () {
                      dialogBloc.dialog = null;
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context).close,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      });
  dialogBloc.dialog = null;
}
