import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';

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
              return AlertDialog(
                  contentPadding: const EdgeInsets.all(16),
                  titlePadding: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(6.0)),
                  content: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SizedBox(height: 20),
                            snapshot.hasData
                                ? _buildFaucetResponse(
                                    context: context,
                                    response: snapshot.data,
                                  )
                                : _buildFaucetProgress(
                                    context: context,
                                    coin: coin,
                                  ),
                            Container(
                              padding: const EdgeInsets.only(top: 15),
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  AppLocalizations.of(context)
                                      .close
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ])));
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
        const SizedBox(height: 35),
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
          const SizedBox(height: 30),
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
          const SizedBox(height: 30),
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
          const SizedBox(height: 30),
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
