import 'package:flutter/material.dart';
import '../localizations.dart';
import '../app_config/app_config.dart';

class EULAContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
            text: AppLocalizations.of(context)!
                .eulaParagraphe1(appConfig.appName, appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(text: '\n\n'),
      ]),
    );
  }
}
