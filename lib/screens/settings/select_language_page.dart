import 'package:flutter/material.dart';
import '../../generic_blocs/main_bloc.dart';
import '../../generic_blocs/settings_bloc.dart';
import '../../localizations.dart';
import '../authentification/lock_screen.dart';
import '../../widgets/language_flag_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectLanguagePage extends StatefulWidget {
  SelectLanguagePage({Key? key, required this.currentLoc}) : super(key: key);

  Locale currentLoc;

  @override
  _SelectLanguagePageState createState() => _SelectLanguagePageState();
}

class _SelectLanguagePageState extends State<SelectLanguagePage> {
  late Locale _currentLoc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settingLanguageTitle),
        ),
        body: ListView(
          children: mainBloc.supportedLocales
              .map((Locale loc) => BuildItemLanguage(
                    locale: loc,
                    currentLoc: widget.currentLoc,
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
      {Key? key, required this.locale, required this.currentLoc, this.onChange})
      : super(key: key);

  final Locale locale;
  final Locale currentLoc;
  final Function(Locale)? onChange;

  @override
  _BuildItemLanguageState createState() => _BuildItemLanguageState();
}

class _BuildItemLanguageState extends State<BuildItemLanguage> {
  bool get _isEnabled => widget.onChange != null;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: !_isEnabled
            ? null
            : () {
                widget.onChange!(widget.locale);
              },
        leading: Radio<Locale?>(
          value: widget.locale,
          groupValue: widget.currentLoc,
          onChanged: !_isEnabled
              ? null
              : (Locale? value) {
                  if (value != null) {
                    widget.onChange!(value);
                  }
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
