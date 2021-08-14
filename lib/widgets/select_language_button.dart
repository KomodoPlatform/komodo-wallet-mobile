import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/language_flag_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectLanguageButton extends StatefulWidget {
  const SelectLanguageButton({Key key}) : super(key: key);

  @override
  _SelectLanguageButtonState createState() => _SelectLanguageButtonState();
}

class _SelectLanguageButtonState extends State<SelectLanguageButton> {
  @override
  Widget build(BuildContext context) {
    Locale _currentLoc = Localizations.localeOf(context);
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).highlightColor)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LanguageFlagIcon(
                loc: _currentLoc,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(getLocaleFullName(_currentLoc).toUpperCase()),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
              )
            ],
          ),
        ),
      ),
      onTap: () {
        dialogBloc.dialog = showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text('Select language'),
              children: [
                ...mainBloc.supportedLocales
                    .map((Locale loc) => BuildLanguageDialogOption(
                          locale: loc,
                          currentLoc: _currentLoc,
                          onChange: (Locale loc) {
                            setState(() {
                              _currentLoc = loc;
                            });

                            mainBloc.setNewLanguage(loc);
                            SharedPreferences.getInstance()
                                .then((SharedPreferences prefs) {
                              prefs.setString(
                                  'current_languages', loc.languageCode);
                            });
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ],
            );
          },
        ).then((dynamic data) {
          dialogBloc.dialog = null;
        });
      },
    );
  }
}

class BuildLanguageDialogOption extends StatefulWidget {
  const BuildLanguageDialogOption(
      {Key key, this.locale, this.currentLoc, this.onChange})
      : super(key: key);

  final Locale locale;
  final Locale currentLoc;
  final Function(Locale) onChange;

  @override
  _BuildLanguageDialogOptionState createState() =>
      _BuildLanguageDialogOptionState();
}

class _BuildLanguageDialogOptionState extends State<BuildLanguageDialogOption> {
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
    return SimpleDialogOption(
      padding: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 24),
      onPressed: () {
        widget.onChange(widget.locale);
      },
      child: Row(
        children: [
          Radio<Locale>(
            value: widget.locale,
            groupValue: widget.currentLoc,
            onChanged: (Locale value) {
              widget.onChange(value);
            },
          ),
          LanguageFlagIcon(
            loc: widget.locale,
            size: 32,
          ),
          SizedBox(width: 8),
          Text(settingsBloc.getNameLanguage(
                  context, widget.locale.languageCode) +
              getGenericScript(scripCode) +
              getGenericLocale(localeCode))
        ],
      ),
    );
  }
}
