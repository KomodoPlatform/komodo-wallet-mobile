import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/send_raw_transaction_response.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/custom_textfield.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class CoinDetail extends StatefulWidget {
  CoinBalance coinBalance;

  CoinDetail(this.coinBalance);

  @override
  _CoinDetailState createState() => _CoinDetailState();
}

class _CoinDetailState extends State<CoinDetail> {
  String barcode = "";
  TextEditingController _amountController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  bool _validate = false;
  bool _onWithdrawPost = false;
  NumberFormat f = new NumberFormat("###,###.0#");

  @override
  void dispose() {
    coinsBloc.updateBalanceForEachCoin(true);
    _amountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {
        _validate = false;
      });
    });
    _addressController.addListener((){
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(
                  AppLocalizations.of(context).shareAddress(
                      widget.coinBalance.coin.name, widget
                      .coinBalance.balance.address));
            },
          )
        ],
        title: Row(
          children: <Widget>[
            PhotoHero(
              tag:
              "assets/${widget.coinBalance.balance.coin.toLowerCase()}.png",
              radius: 16,
            ),
            SizedBox(
              width: 8,
            ),
            Text(widget.coinBalance.coin.name.toUpperCase()),
          ],
        ),
        centerTitle: false,
        backgroundColor: Color(int.parse(widget.coinBalance.coin.colorCoin)),
      ),
      body: Builder(
          builder: (context) {
            return ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                SizedBox(
                  height: 25,
                ),
                StreamBuilder<List<CoinBalance>>(
                    initialData: coinsBloc.coinBalance,
                    stream: coinsBloc.outCoins,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        snapshot.data.forEach((coinBalance) {
                          if (coinBalance.coin.abbr ==
                              widget.coinBalance.coin.abbr) {
                            widget.coinBalance = coinBalance;
                          }
                        });
                        return Text(
                          widget.coinBalance.balance.balance.toString(),
                          style: Theme
                              .of(context)
                              .textTheme
                              .title,
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return Container();
                      }
                    }
                ),
                SizedBox(
                  height: 25,
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      _copyToClipBoard(
                          context, widget.coinBalance.balance.address);
                    },
                    child: QrImage(
                      foregroundColor: Theme
                          .of(context)
                          .textSelectionColor,
                      data: widget.coinBalance.balance.address,
                      size: 200.0,
                    ),
                  ),
                ),
                InkWell(
                    onTap: () {
                      _copyToClipBoard(
                          context, widget.coinBalance.balance.address);
                    },
                    child: Center(
                        child: Text(widget.coinBalance.balance.address))),
                SizedBox(
                  height: 50,
                ),
                Text(
                  AppLocalizations
                .of(context)
                .withdraw,
                  style: Theme
                      .of(context)
                      .textTheme
                      .title,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  errorText:
                  _validate ? AppLocalizations
                .of(context)
                .errorValueEmpty : null,
                  labelText: AppLocalizations
                .of(context)
                .amount,
                  textInputType: TextInputType.numberWithOptions(decimal: true),
                  controller: _amountController,
                ),
                SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomTextField(
                        labelText: AppLocalizations
                      .of(context)
                      .addressSend,
                        textInputType: TextInputType.text,
                        controller: _addressController,
                      ),
                    ),
                    InkWell(
                      onTap: scan,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                _buildWithdrawButton(context)
              ],
            );
          }
      ),
    );
  }

  _buildWithdrawButton(BuildContext context) {
    if (_onWithdrawPost) {
      return Center(
        child: Container(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(strokeWidth: 2,)),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 50,
        child: Builder(
          builder: (context) {
            return RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)),
              color: Theme
                  .of(context)
                  .buttonColor,
              disabledColor: Theme
                  .of(context)
                  .disabledColor,
              child: Text(
                _amountController.text.isNotEmpty
                    ?
                AppLocalizations.of(context).withdrawValue(
                    _amountController.text, widget.coinBalance
                    .coin.abbr)
                    : AppLocalizations
                    .of(context)
                    .withdraw
                    .toUpperCase(),
                style: Theme
                    .of(context)
                    .textTheme
                    .button,
              ),
               onPressed: _amountController.text.isNotEmpty && _addressController.text.isNotEmpty ? _buildDialogConfirmation : null,
            );
          },
        ),
      );
    }
  }

  _buildDialogConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SimpleDialog(
          contentPadding: EdgeInsets.all(16),
          children: <Widget>[
            Text(AppLocalizations.of(context).youAreSending, style: Theme.of(context).textTheme.title,),
            SizedBox(height: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(_amountController.text, style: Theme.of(context).textTheme.title,),
                SizedBox(width: 4,),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(widget.coinBalance.coin.abbr, style: Theme.of(context).textTheme.subtitle,),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(widget.coinBalance.coin.getTxFeeSatoshi(), style: Theme.of(context).textTheme.body2,),
                SizedBox(width: 4,),
                Text(AppLocalizations.of(context).networkFee, style: Theme.of(context).textTheme.body2,),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text('1.0 USD', style: Theme.of(context).textTheme.body2,),
                SizedBox(width: 4,),
                Text(AppLocalizations.of(context).commissionFee, style: Theme.of(context).textTheme.body2,),
              ],
            ),
            SizedBox(height: 16,),
            Text(AppLocalizations.of(context).youAreSending, style: Theme.of(context).textTheme.title,),
            SizedBox(height: 24,),
            Text(_addressController.text, style: Theme.of(context).textTheme.body1,),
            SizedBox(height: 24,),
            RaisedButton(
              color: Theme.of(context).accentColor,
              child: new Text(AppLocalizations
                  .of(context)
                  .confirm.toUpperCase(), style: Theme.of(context).textTheme.button,),
              onPressed: () {
                _onPressedConfirmWithdraw();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _onPressedConfirmWithdraw() {
    setState(() {
      _validate = false;
    });
    mm2
        .postWithdraw(
        widget.coinBalance.coin,
        _addressController.text.toString(),
        double.parse(_amountController.text.toString()))
        .then((data) {
      print(data is WithdrawResponse);
      setState(() {
        _onWithdrawPost = false;
      });
      if (data is WithdrawResponse) {
        mm2.postRawTransaction(
            widget.coinBalance.coin, data.txHex).then((
            dataRawTx) {
          if (dataRawTx is SendRawTransactionResponse) {
            _showDialogConfirmWithdraw(dataRawTx);
          }
        });
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(AppLocalizations
              .of(context)
              .errorTryLater),
        ));
      }
    });
  }

  /// Open a activity for scan QRCode example usage:
  /// MaterialButton(onPressed: scan, child: new Text("SEND"))
  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        _addressController.text = barcode;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
      'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  void _showDialogConfirmWithdraw(SendRawTransactionResponse data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(AppLocalizations
              .of(context)
              .withdrawConfirm),
          content: GestureDetector(
              onTap: () {
                Clipboard.setData(new ClipboardData(text: data.txHash));
              },
              child: Container(
                  child: new Text('TXID: \n${data.txHash}', style: Theme
                      .of(context)
                      .textTheme
                      .body1,))),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(AppLocalizations
                  .of(context)
                  .close),
              onPressed: () {
                coinsBloc.updateOneCoin(widget.coinBalance);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _copyToClipBoard(BuildContext context, String str) {
    print(str);
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text("Copied to the clipboard"),
    ));
    Clipboard.setData(new ClipboardData(text: str));
  }
}