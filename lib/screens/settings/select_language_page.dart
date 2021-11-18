import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/widgets/language_flag_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectLanguagePage extends StatefulWidget {
  const SelectLanguagePage({Key key, this.currentLoc}) : super(key: key);

  final Locale currentLoc;

  @override
  _SelectLanguagePageState createState() => _SelectLanguagePageState();
}

class _SelectLanguagePageState extends State<SelectLanguagePage> {
  Locale _currentLoc;
  @override
  void initState() {
    super.initState();
    _currentLoc = widget.currentLoc;
  }

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).settingLanguageTitle),
        ),
        body: ListView(
          children: mainBloc.supportedLocales
              .map((Locale loc) => BuildItemLanguage(
                    locale: loc,
                    currentLoc: _currentLoc,
                    onChange: (Locale loc) {
                      setState(() {
                        _currentLoc = loc;
                        mainBloc.setNewLanguage(loc);
                        SharedPreferences.getInstance()
                            .then((SharedPreferences prefs) {
                          prefs.setString(
                              'current_languages', loc.languageCode);
                        });
                      });
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class BuildItemLanguage extends StatefulWidget {
  const BuildItemLanguage(
      {Key key, this.locale, this.currentLoc, this.onChange})
      : super(key: key);

  final Locale locale;
  final Locale currentLoc;
  final Function(Locale) onChange;

  @override
  _BuildItemLanguageState createState() => _BuildItemLanguageState();
}

class _BuildItemLanguageState extends State<BuildItemLanguage> {
  String getGenericLocale(String localeCode) {
    switch (localeCode) {
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () {
          widget.onChange(widget.locale);
        },
        leading: Radio<Locale>(
          value: widget.locale,
          groupValue: widget.currentLoc,
          onChanged: (Locale value) {
            widget.onChange(value);
          },
        ),
        title: Row(
          children: [
            LanguageFlagIcon(loc: widget.locale, size: 32),
            SizedBox(width: 16),
            Text(settingsBloc.getNameLanguage(
                context, widget.locale.languageCode)),
          ],
        ));
  }
}
