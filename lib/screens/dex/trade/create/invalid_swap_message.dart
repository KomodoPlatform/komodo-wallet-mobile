import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/trade/create/trade_form_validator.dart';
import 'package:komodo_dex/utils/utils.dart';

class InvalidSwapMessage extends StatelessWidget {
  const InvalidSwapMessage(this.apiErrorMessage);

  final String apiErrorMessage;

  @override
  Widget build(BuildContext context) {
    final BuildContext _mainContext = context;

    return InkWell(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 14, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context).invalidSwap,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.orange),
            ),
            SizedBox(width: 2),
            Icon(
              Icons.open_in_new_rounded,
              size: 12,
              color: Colors.orange,
            )
          ],
        ),
      ),
      onTap: () async {
        final String validatorErrorMessage =
            await TradeFormValidator().errorMessage;

        showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                title: Text(AppLocalizations.of(context).invalidSwap,
                    style: TextStyle(fontSize: 18)),
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (validatorErrorMessage != null) ...{
                            Text(
                              validatorErrorMessage,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                          },
                          if (apiErrorMessage != null)
                            InkWell(
                              onTap: () {
                                copyToClipBoard(_mainContext, apiErrorMessage);
                              },
                              child: Text(
                                apiErrorMessage,
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  RaisedButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(AppLocalizations.of(context).okButton),
                  )
                ],
              );
            });
      },
    );
  }
}
