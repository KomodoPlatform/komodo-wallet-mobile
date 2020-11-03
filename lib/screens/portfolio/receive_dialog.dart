import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:http/http.dart' as http;

import 'package:qr_flutter/qr_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/utils/utils.dart';

void showReceiveDialog(BuildContext mContext, String address, Coin coin) {
  dialogBloc.dialog = showDialog<dynamic>(
    context: mContext,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        contentPadding: const EdgeInsets.all(16),
        titlePadding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(6.0)),
        content: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    copyToClipBoard(mContext, address);
                  },
                  child: QrImage(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    data: address,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  copyToClipBoard(mContext, address);
                },
                child: Container(
                  child: Center(
                      child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                    child: AutoSizeText(
                      address,
                      textKey: const Key('coin-details-address'),
                      style: Theme.of(context).textTheme.body1,
                      maxLines: 2,
                    ),
                  )),
                ),
              ),
              Row(
                children: <Widget>[
                  coin.abbr == 'RICK' || coin.abbr == 'MORTY'
                      ? RaisedButton(
                          child: Text(AppLocalizations.of(context).faucetName,
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(
                                      color: Theme.of(context).primaryColor)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          elevation: 0,
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            dialogBloc.closeDialog(context);
                            showFaucetDialog(
                              context: context,
                              coin: coin.abbr,
                              address: address,
                            );
                          },
                        )
                      : Expanded(
                          child: Container(),
                        ),
                  FlatButton(
                    child: Text(
                      AppLocalizations.of(context).close.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .button
                          .copyWith(color: Theme.of(context).accentColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ).then((dynamic data) {
    dialogBloc.dialog = null;
  });
}

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
                                : _buildProgress(
                                    context: context,
                                    coin: coin,
                                  ),
                            Container(
                              padding: const EdgeInsets.only(top: 15),
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                // TODO(yurii): localization
                                child: Text(
                                  'Close'.toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ])));
            });
      });
}

Widget _buildProgress({
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
          // TODO(yurii): localization
          'Sending request to $coin faucet...',
          style: Theme.of(context).textTheme.body2,
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
            // TODO(yurii): localization
            'Success'.toUpperCase(),
            style: TextStyle(
              color: Colors.green,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            response['Result']['Message'],
            style: Theme.of(context).textTheme.body2,
          ),
        ],
      );

    case 'Error':
      return Column(
        children: <Widget>[
          Text(
            // TODO(yurii): localization
            'Error'.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).errorColor,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            response['Result']['Message'],
            style: Theme.of(context).textTheme.body2,
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
            style: Theme.of(context).textTheme.body2,
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
        .get('https://faucet.komodo/faucet/$coin/$address')
        .timeout(const Duration(seconds: 30), onTimeout: () {
      throw 'Request timed out'; // TODO(yurii): localization
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
