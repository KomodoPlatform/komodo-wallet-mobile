import 'package:flutter/material.dart';
import '../localizations.dart';
import '../app_config/app_config.dart';

class TACContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        // First paragraph heading moved to
        // dialog's title.
        // TextSpan(
        //     text:
        //         AppLocalizations.of(context)
        //             .eulaTitle2,
        //     style: Theme.of(context)
        //         .textTheme
        //         .subtitle2),
        TextSpan(
            text: AppLocalizations.of(context)
                .eulaParagraphe2(appConfig.appName, appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle3,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle4,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context).eulaParagraphe3,
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle5,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context).eulaParagraphe4,
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle6,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text:
                AppLocalizations.of(context).eulaParagraphe5(appConfig.appName),
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle7,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context)
                .eulaParagraphe6(appConfig.appName, appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle8,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context).eulaParagraphe7,
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle9,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context).eulaParagraphe8,
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle10,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context).eulaParagraphe9,
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle11,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context)
                .eulaParagraphe10(appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle12,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context).eulaParagraphe11(
                appConfig.appCompanyShort, appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle13,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context).eulaParagraphe12,
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle14,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context)
                .eulaParagraphe13(appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle15,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context)
                .eulaParagraphe14(appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle16,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context)
                .eulaParagraphe15(appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle17,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context).eulaParagraphe16(
                appConfig.appCompanyShort, appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle18,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context)
                .eulaParagraphe17(appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle19,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context)
                .eulaParagraphe18(appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),
        TextSpan(
            text: AppLocalizations.of(context).eulaTitle20,
            style: Theme.of(context).textTheme.subtitle2),
        TextSpan(
            text: AppLocalizations.of(context)
                .eulaParagraphe19(appConfig.appName, appConfig.appCompanyLong),
            style: Theme.of(context).textTheme.bodyText2),

        // 2 Empty paragraph breaks
        // to ensure the last
        //paragraph is visible
        TextSpan(text: '\n\n'),
      ]),
    );
  }
}
