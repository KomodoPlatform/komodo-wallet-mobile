import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keccak/keccak.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/disable_coin.dart';
import 'package:komodo_dex/model/error_disable_coin_active_swap.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../localizations.dart';

void copyToClipBoard(BuildContext context, String str) {
  Scaffold.of(context).showSnackBar( SnackBar(
    duration: const Duration(milliseconds: 300),
    content:  Text(AppLocalizations.of(context).clipboard),
  ));
  Clipboard.setData( ClipboardData(text: str));
}

bool isAddress(String address) {
  if (RegExp('!/^(0x)?[0-9a-f]{40}\$/i').hasMatch(address)) {
    return false;
  } else if (RegExp('/^(0x)?[0-9a-f]{40}\$/').hasMatch(address) ||
      RegExp('/^(0x)?[0-9A-F]{40}\$/').hasMatch(address)) {
    return true;
  } else {
    return isChecksumAddress(address);
  }
}

bool isChecksumAddress(String address) {
  // Check each case
  address = address.replaceFirst('0x', '');
  final Uint8List inputData = Uint8List.fromList(address.toLowerCase().codeUnits);
  final Uint8List addressHash = keccak(inputData);
  final String output = hex.encode(addressHash);
  for (int i = 0; i < 40; i++) {
    // the nth letter should be uppercase if the nth digit of casemap is 1
    // int.parse(addressHash[i].toString(), radix: 16)
    if ((int.parse(output[i].toString(), radix: 16) > 7 &&
            address[i].toUpperCase() != address[i]) ||
        (int.parse(output[i].toString(), radix: 16) <= 7 &&
            address[i].toLowerCase() != address[i])) {
      return false;
    }
  }
  return true;
}

String replaceAllTrainlingZero(String data) {
  for (int i = 0; i < 8; i++) {
    data = data.replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
  }
  return data;
}

String replaceAllTrainlingZeroERC(String data) {
  for (int i = 0; i < 16; i++) {
    data = data.replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
  }
  return data;
}

bool isNumeric(String s) {
  if(s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

void showAddressDialog(BuildContext mContext, String address) {
  dialogBloc.dialog = showDialog<dynamic>(
    context: mContext,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        contentPadding: const EdgeInsets.all(16),
        titlePadding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(6.0)),
        content: InkWell(
          onTap: () {
            copyToClipBoard(mContext, address);
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: QrImage(
                    foregroundColor: Colors.white,
                    data: address,
                  ),
                ),
                Container(
                  child: Center(
                      child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                    child: AutoSizeText(
                      address,
                      style: Theme.of(context).textTheme.body1,
                      maxLines: 2,
                    ),
                  )),
                )
              ],
            ),
          ),
        ),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          FlatButton(
            child: Text(AppLocalizations.of(context).close.toUpperCase()),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  ).then((dynamic data) {
    dialogBloc.dialog = null;
  });
}

  void showMessage(BuildContext mContext, String error) {
    Scaffold.of(mContext).showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(mContext).primaryColor,
      content: Text(
        error,
        style: Theme.of(mContext).textTheme.body1,
      ),
    ));
  }

  Future<void> showConfirmationRemoveCoin(BuildContext mContext, Coin coin) async {
    return dialogBloc.dialog = showDialog<void>(
        context: mContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).deleteConfirm),
            content: RichText(
                text: TextSpan(
                    style: Theme.of(context).textTheme.body1,
                    children: <TextSpan>[
                  TextSpan(text: AppLocalizations.of(context).deleteSpan1),
                  TextSpan(
                      text: '${coin.name}',
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(fontWeight: FontWeight.bold)),
                  TextSpan(text: AppLocalizations.of(context).deleteSpan2),
                ])),
            actions: <Widget>[
              FlatButton(
                child: Text(AppLocalizations.of(context).cancel),
                onPressed: () {
                  Navigator.of(mContext).pop();
                },
              ),
              RaisedButton(
                color: Theme.of(context).errorColor,
                child: Text(AppLocalizations.of(context).confirm),
                onPressed: () {
                  coinsBloc.removeCoin(coin).then((dynamic value) {
                    if (value is ErrorDisableCoinActiveSwap) {
                      showMessage(mContext, value.error);
                    }
                    if (value is DisableCoin) {
                      if (value.result.cancelledOrders.isNotEmpty) {
                        showMessage(mContext, AppLocalizations.of(context)
                            .orderCancel(value.result.coin));
                      }
                    }
                  });
                  Navigator.of(mContext).pop();
                },
              )
            ],
          );
        }).then((_) {
      dialogBloc.dialog = null;
    });
  }