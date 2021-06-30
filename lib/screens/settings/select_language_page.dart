import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
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
        backgroundColor: Theme.of(context).backgroundColor,
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
  String getGenericScript(String scriptCode) {
    switch (scriptCode) {
      case 'Hans':
        return ' ' + AppLocalizations.of(context).simplifiedChinese;
        break;
      default:
        return '';
    }
  }

  String getGenericLocale(String localeCode) {
    switch (localeCode) {
      case 'zh_TW':
        return ' ' + AppLocalizations.of(context).simplifiedChinese;
        break;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    String scripCode = '';
    String localeCode = '';
    if (widget.locale.scriptCode != null) {
      scripCode = widget.locale.scriptCode;
    }
    if (widget.locale.countryCode != null) {
      localeCode = widget.locale.toString();
    }
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
        title: Text(
            settingsBloc.getNameLanguage(context, widget.locale.languageCode) +
                getGenericScript(scripCode) +
                getGenericLocale(localeCode)));
  }
}
