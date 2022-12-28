import 'package:flutter/material.dart';
import '../../localizations.dart';
import '../../app_config/app_config.dart';

class EULAContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        // First paragraph heading moved to
        // dialog's title.
        // TextSpan(
        //     text:
        //         AppLocalizations.of(context)
        //             .eulaTitle1(
        //                 appConfig.appName),
        //     style: Theme.of(context)
        //         .textTheme
        //         .headline6),
        TextSpan(
            text: AppLocalizations.of(context)
                .eulaParagraphe1(appConfig.appName, appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),

        // 2 Empty paragraph breaks
        // to ensure the last
        //paragraph is visible
        TextSpan(text: '\n\n'),
      ]),
    );
  }
}
