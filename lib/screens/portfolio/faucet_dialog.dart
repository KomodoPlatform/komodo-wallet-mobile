import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/widgets/unified_dialog_config.dart';

void showFaucetDialog({
  @required BuildContext context,
  @required String coin,
  @required String address,
}) {
  dialogBloc.dialog = showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, dynamic>>(
            future: callFaucet(coin, address),
            builder: (context, snapshot) {
              return SimpleDialog(
                contentPadding: UnifiedDialogConfig.contentPadding,
                titlePadding: UnifiedDialogConfig.titlePaddingEmpty,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        snapshot.hasData
                            ? _buildFaucetResponse(
                                context: context,
                                response: snapshot.data,
                              )
                            : _buildFaucetProgress(
                                context: context,
                                coin: coin,
                              ),
                        UnifiedDialogConfig.verticalSpacing,
                        RaisedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            AppLocalizations.of(context).close.toUpperCase(),
                            style:
                                UnifiedDialogConfig.getButtonTextStyle(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            });
      });
}

Widget _buildFaucetProgress({
  @required BuildContext context,
  @required String coin,
}) {
  return Container(
    padding: const EdgeInsets.only(top: 5),
    child: Column(
      children: <Widget>[
        const Center(
          child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              )),
        ),
        UnifiedDialogConfig.verticalSpacing,
        Text(
          AppLocalizations.of(context).faucetInProgress(coin),
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    ),
  );
}

Widget _buildFaucetResponse({
  @required BuildContext context,
  @required Map<String, dynamic> response,
}) {
  switch (response['Status']) {
    case 'Success':
      return Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context).faucetSuccess.toUpperCase(),
            style: const TextStyle(
              color: Colors.green,
              fontSize: 20,
            ),
          ),
          UnifiedDialogConfig.verticalSpacing,
          Text(
            response['Result']['Message'],
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      );

    case 'Error':
      return Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context).faucetError.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).errorColor,
              fontSize: 20,
            ),
          ),
          UnifiedDialogConfig.verticalSpacing,
          Text(
            response['Result']['Message'],
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      );

    default:
      return Column(
        children: <Widget>[
          Text(
            response['Status'].toUpperCase(),
            style: TextStyle(
              color: Colors.orange[300],
              fontSize: 20,
            ),
          ),
          UnifiedDialogConfig.verticalSpacing,
          Text(
            response['Result']['Message'],
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      );
  }
}

Future<Map<String, dynamic>> callFaucet(String coin, String address) async {
  String body;
  http.Response response;
  try {
    response = await http
        .get('https://faucet.komodo.live/faucet/$coin/$address')
        .timeout(const Duration(seconds: 30), onTimeout: () {
      throw AppLocalizations().faucetTimedOut;
    });
    body = response.body;
  } catch (e) {
    return <String, dynamic>{
      'Status': 'Error',
      'Result': <String, String>{
        'Message': e,
      },
    };
  }

  try {
    return jsonDecode(body);
  } catch (e) {
    return <String, dynamic>{
      'Status': 'Error',
      'Result': <String, String>{
        'Message': e,
      },
    };
  }
}
