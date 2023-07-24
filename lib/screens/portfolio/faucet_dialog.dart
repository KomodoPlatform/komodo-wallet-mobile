import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../blocs/dialog_bloc.dart';
import '../../../localizations.dart';
import '../../../widgets/custom_simple_dialog.dart';

void showFaucetDialog({
  @required BuildContext context,
  @required String coin,
  @required String address,
}) {
  dialogBloc.dialog = showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, dynamic>>(
            future: callFaucet(coin, address),
            builder: (context, snapshot) {
              return CustomSimpleDialog(
                children: <Widget>[
                  SizedBox(
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
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(AppLocalizations.of(context).close),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            });
      }).then((dynamic _) => dialogBloc.dialog = null);
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
        SizedBox(height: 16),
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
  switch (response['status']) {
    case 'success':
      return Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context).faucetSuccess.toUpperCase(),
            style: const TextStyle(
              color: Colors.green,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 16),
          Text(
            response['result']['message'],
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      );

    case 'error':
      return Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context).faucetError.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).errorColor,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 16),
          Text(
            response['result']['message'],
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      );

    default:
      return Column(
        children: <Widget>[
          Text(
            response['status'].toUpperCase(),
            style: TextStyle(
              color: Colors.orange[300],
              fontSize: 20,
            ),
          ),
          SizedBox(height: 16),
          Text(
            response['result']['message'],
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
        .get(Uri.parse('https://faucet.komodo.earth/faucet/$coin/$address'))
        .timeout(const Duration(seconds: 30), onTimeout: () {
      throw AppLocalizations().faucetTimedOut;
    });
    body = response.body;
  } catch (e) {
    return <String, dynamic>{
      'status': 'error',
      'result': <String, String>{
        'message': e,
      },
    };
  }

  try {
    return jsonDecode(body);
  } catch (e) {
    return <String, dynamic>{
      'status': 'error',
      'result': <String, String>{
        'message': e,
      },
    };
  }
}
