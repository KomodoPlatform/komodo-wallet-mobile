import 'dart:async';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/send_raw_transaction_response.dart';
import 'package:komodo_dex/model/transaction.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
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
  bool _onWithdrawPost = false;
  NumberFormat f = new NumberFormat("###,###.0#");
  final _formKey = GlobalKey<FormState>();
  bool isExpanded = false;
  int currentIndex = 0;
  List<Widget> listSteps = List<Widget>();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    currentIndex = 0;
    coinsBloc.resetTransactions();
    coinsBloc.updateTransactions(widget.coinBalance);
    super.initState();
  }

  @override
  void dispose() {
    coinsBloc.updateBalanceForEachCoin(true);
    _amountController.dispose();
    _addressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (listSteps.isEmpty) {
      initSteps();
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(AppLocalizations.of(context).shareAddress(
                  widget.coinBalance.coin.name,
                  widget.coinBalance.balance.address));
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
      body: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            _buildForm(),
            _buildHeaderCoinDetail(context),
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: <Widget>[
                  StreamBuilder<List<Transaction>>(
                      stream: coinsBloc.outTransactions,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data.length == 0) {
                          return Center(
                              child: Text(
                            "No Transactions",
                            style: Theme.of(context).textTheme.body2,
                          ));
                        }
                        if (snapshot.hasData && snapshot.data.length > 0) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: _buildTransactions(context, snapshot.data),
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      })
                ],
              ),
            )
          ],
        );
      }),
    );
  }

  _buildTransactions(BuildContext context, List<Transaction> transactionsData) {
    List<Widget> transactions = new List<Widget>();

    transactionsData.sort((b, a) {
      if (a.date != null) {
        return a.date.compareTo(b.date);
      }
    });

    TextStyle subtitle = Theme.of(context)
        .textTheme
        .subtitle
        .copyWith(fontWeight: FontWeight.bold);

    transactionsData.forEach((transaction) {
      transactions.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Card(
            color: Theme.of(context).primaryColor,
            elevation: 8.0,
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              onTap: () {
                Scaffold.of(context).showSnackBar(new SnackBar(
                  duration: Duration(milliseconds: 1000),
                  content: new Text(AppLocalizations.of(context).commingsoon),
                ));
              },
              child: Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Builder(
                          builder: (context) {
                            return transaction.isIn
                                ? Text(
                                    "+ ",
                                    style: subtitle,
                                  )
                                : Text(
                                    "- ",
                                    style: subtitle,
                                  );
                          },
                        ),
                        Text(
                          transaction.value.toString(),
                          style: subtitle,
                        ),
                        Text(
                          ' ${widget.coinBalance.coin.abbr}',
                          style: subtitle,
                        ),
                        Expanded(
                          child: SizedBox(
                            width: 8,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            return transaction.isConfirm
                                ? Container(
                                    height: 12,
                                    width: 12,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                        color: Colors.green),
                                  )
                                : Container(
                                    height: 12,
                                    width: 12,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                        color: Colors.red),
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, bottom: 16, top: 8),
                    child: AutoSizeText(
                      "TXID: " +
                          transaction.txid.substring(1, 5) +
                          "..." +
                          transaction.txid.substring(
                              transaction.txid.length - 5,
                              transaction.txid.length),
                      maxLines: 1,
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ),
                  Container(
                    color: Theme.of(context).backgroundColor,
                    height: 1,
                    width: double.infinity,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          transaction.getTimeFormat(),
                          style: Theme.of(context).textTheme.body2,
                        ),
                        Icon(
                          Icons.more_horiz,
                          color: Theme.of(context).accentColor,
                          size: 32,
                        )
                      ],
                    ),
                  )
                ],
              )),
            )),
      ));
    });
    return Column(
      children: transactions,
    );
  }

  _buildHeaderCoinDetail(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: StreamBuilder<List<CoinBalance>>(
              initialData: coinsBloc.coinBalance,
              stream: coinsBloc.outCoins,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  snapshot.data.forEach((coinBalance) {
                    if (coinBalance.coin.abbr == widget.coinBalance.coin.abbr) {
                      widget.coinBalance = coinBalance;
                    }
                  });
                  return Column(
                    children: <Widget>[
                      Text(
                        widget.coinBalance.balance.balance.toString() +
                            " " +
                            widget.coinBalance.balance.coin.toString(),
                        style: Theme.of(context).textTheme.title,
                        textAlign: TextAlign.center,
                      ),
                      Text('\$${widget.coinBalance.getBalanceUSD()} USD')
                    ],
                  );
                } else {
                  return Container();
                }
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildButtonLight(StatusButton.RECEIVE, context),
            _buildButtonLight(StatusButton.SEND, context),
          ],
        ),
        SizedBox(
          height: 36,
        )
      ],
    );
  }

  _buildButtonLight(StatusButton statusButton, BuildContext context) {
    if (currentIndex == 2) {
      _closeAfterAWait();
    }
    return Expanded(
      child: FlatButton(
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(32)),
          onTap: () {
            if (statusButton == StatusButton.RECEIVE)
              _showDialogAddress(context);
            if (statusButton == StatusButton.SEND) {
              if (currentIndex == 2) {
                setState(() {
                  isExpanded = false;
                  _waitForInit();
                });
              } else {
                setState(() {
                  isExpanded = !isExpanded;
                });
              }
            }
          },
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                  border:
                      Border.all(color: Theme.of(context).textSelectionColor)),
              child: Center(child: Builder(
                builder: (context) {
                  switch (statusButton) {
                    case StatusButton.RECEIVE:
                      return Text(
                        AppLocalizations.of(context).receive,
                        style: Theme.of(context).textTheme.body1,
                      );
                      break;
                    case StatusButton.SEND:
                      return isExpanded
                          ? Text(
                              AppLocalizations.of(context).close.toUpperCase(),
                              style: Theme.of(context).textTheme.body1,
                            )
                          : Text(
                              AppLocalizations.of(context).send.toUpperCase(),
                              style: Theme.of(context).textTheme.body1,
                            );
                      break;
                  }
                },
              ))),
        ),
      ),
    );
  }

  _showDialogAddress(BuildContext mContext) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          contentPadding: EdgeInsets.all(16),
          titlePadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(6.0)),
          content: InkWell(
            onTap: () {
              _copyToClipBoard(mContext, widget.coinBalance.balance.address);
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: QrImage(
                      foregroundColor: Colors.white,
                      data: widget.coinBalance.balance.address,
                    ),
                  ),
                  Container(
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AutoSizeText(
                        widget.coinBalance.balance.address,
                        style: Theme.of(context).textTheme.body1,
                        maxLines: 1,
                      ),
                    )),
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(AppLocalizations.of(context).close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((data) {
      setState(() {});
    });
  }

  _buildForm() {
    return AnimatedCrossFade(
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: Duration(milliseconds: 200),
      firstChild: Container(),
      secondChild: Container(
          color: Theme.of(context).primaryColor,
          child: listSteps[currentIndex]),
    );
  }

  _buildWithdrawButton(BuildContext context) {
    if (_onWithdrawPost) {
      return Center(
        child: Container(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            )),
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
              color: Theme.of(context).buttonColor,
              disabledColor: Theme.of(context).disabledColor,
              child: Text(
                AppLocalizations.of(context).withdraw.toUpperCase(),
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                print(_formKey.currentState);
                if (_formKey.currentState.validate()) {
                  setState(() {
                    isExpanded = false;
                    listSteps.add(_buildConfirmationStep());
                  });
                  setState(() {
                    currentIndex = 1;
                    isExpanded = true;
                  });
                }
              },
            );
          },
        ),
      );
    }
  }

  _buildConfirmationStep() {
    double amountMinusFee = double.parse(_amountController.text) -
        double.parse(widget.coinBalance.coin.getTxFeeSatoshi());
    amountMinusFee = double.parse(amountMinusFee.toStringAsFixed(8));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).youAreSending,
            style: Theme.of(context).textTheme.subtitle,
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                _amountController.text,
                style: Theme.of(context).textTheme.subtitle,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                widget.coinBalance.coin.abbr,
                style: Theme.of(context).textTheme.body1,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "- ",
                style: Theme.of(context).textTheme.body2,
              ),
              Text(
                widget.coinBalance.coin.getTxFeeSatoshi(),
                style: Theme.of(context).textTheme.body2,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                AppLocalizations.of(context).networkFee,
                style: Theme.of(context).textTheme.body2,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              height: 1,
              width: double.infinity,
              color: Theme.of(context).textSelectionColor.withOpacity(0.4),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                amountMinusFee.toString(),
                style: amountMinusFee > 0
                    ? Theme.of(context).textTheme.title
                    : Theme.of(context)
                        .textTheme
                        .title
                        .copyWith(color: Colors.red),
              ),
              SizedBox(
                width: 4,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  widget.coinBalance.coin.abbr,
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            AppLocalizations.of(context).toAddress,
            style: Theme.of(context).textTheme.subtitle,
          ),
          SizedBox(
            height: 24,
          ),
          Container(
            child: AutoSizeText(
              _addressController.text,
              style: Theme.of(context).textTheme.body1,
              maxLines: 1,
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 50,
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    onTap: () {
                      setState(() {
                        isExpanded = false;
                        _waitForInit();
                      });
                    },
                    child: FlatButton(
                      child: Text(
                        AppLocalizations.of(context).cancel.toUpperCase(),
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: Container(
                  height: 50,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0)),
                    color: Theme.of(context).buttonColor,
                    disabledColor: Theme.of(context).disabledColor,
                    child: Text(
                      AppLocalizations.of(context).confirm.toUpperCase(),
                      style: Theme.of(context).textTheme.button,
                    ),
                    onPressed: amountMinusFee > 0
                        ? () {
                            _onPressedConfirmWithdraw(context);
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _onPressedConfirmWithdraw(BuildContext context) {
    double amountMinusFee = double.parse(_amountController.text) -
        double.parse(widget.coinBalance.coin.getTxFeeSatoshi());
    amountMinusFee = double.parse(amountMinusFee.toStringAsFixed(8));

    mm2
        .postWithdraw(widget.coinBalance.coin,
            _addressController.text.toString(), amountMinusFee)
        .then((data) {
      setState(() {
        _onWithdrawPost = true;
      });
      if (data is WithdrawResponse) {
        mm2
            .postRawTransaction(widget.coinBalance.coin, data.txHex)
            .then((dataRawTx) {
          if (dataRawTx is SendRawTransactionResponse) {
            setState(() {
              coinsBloc.clearTransactions();
              coinsBloc.updateTransactions(widget.coinBalance);
              listSteps.add(Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Container(
                          child: InkWell(
                        onTap: () {
                          _copyToClipBoard(context, dataRawTx.txHash);
                        },
                        child: Column(
                          children: <Widget>[
                            Text("Success !"),
                            SizedBox(
                              height: 16,
                            ),
                            Icon(
                              Icons.check_circle_outline,
                              color: Theme.of(context).hintColor,
                              size: 60,
                            )
                          ],
                        ),
                      )),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ));
              currentIndex = 2;
            });
          }
          setState(() {
            _onWithdrawPost = false;
          });
        });
      } else {
        setState(() {
          _onWithdrawPost = false;
        });
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(AppLocalizations.of(context).errorTryLater),
        ));
      }
    });
  }

  _closeAfterAWait() async {
    Timer(Duration(milliseconds: 3000), () {
      setState(() {
        isExpanded = false;
        _waitForInit();
      });
    });
  }

  _waitForInit() async {
    Timer(Duration(milliseconds: 500), () {
      setState(() {
        currentIndex = 0;
        initSteps();
      });
    });
  }

  _copyToClipBoard(BuildContext context, String str) {
    print(str);
    Scaffold.of(context).showSnackBar(new SnackBar(
      duration: Duration(milliseconds: 300),
      content: new Text("Copied to the clipboard"),
    ));
    Clipboard.setData(new ClipboardData(text: str));
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

  void initSteps() {
    _amountController.clear();
    _addressController.clear();
    listSteps.clear();
    listSteps.add(Container(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).withdraw,
              style: Theme.of(context).textTheme.title,
            ),
            SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    inputFormatters: [
                      DecimalTextInputFormatter(decimalRange: 8)
                    ],
                    controller: _amountController,
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    style: Theme.of(context).textTheme.body1,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColorLight)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor)),
                        hintStyle: Theme.of(context).textTheme.body1,
                        labelStyle: Theme.of(context).textTheme.body1,
                        labelText: AppLocalizations.of(context).amount),
                    // The validator receives the text the user has typed in
                    validator: (value) {
                      double balance = widget.coinBalance.balance.balance;

                      if (value.isEmpty || double.parse(value) <= 0) {
                        return AppLocalizations.of(context).errorValueNotEmpty;
                      }

                      double currentAmount = double.parse(value);

                      if (currentAmount > balance) {
                        return AppLocalizations.of(context).errorAmountBalance;
                      }
                    },
                  ),
                ),
                Container(
                  height: 60,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _amountController.text =
                            widget.coinBalance.balance.balance.toString();
                      });
                    },
                    child: FlatButton(
                      child: Text(
                        "MAX",
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(color: Theme.of(context).accentColor),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _addressController,
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    style: Theme.of(context).textTheme.body1,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColorLight)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor)),
                        hintStyle: Theme.of(context).textTheme.body1,
                        labelStyle: Theme.of(context).textTheme.body1,
                        labelText: AppLocalizations.of(context).addressSend),
                    // The validator receives the text the user has typed in
                    validator: (value) {
                      if (value.isEmpty) {
                        return AppLocalizations.of(context).errorValueNotEmpty;
                      }
                      try {
                        Uint8List decoded = bs58check.decode(value);
                        print(bs58check.encode(decoded));
                      } catch (e) {
                        return AppLocalizations.of(context)
                            .errorNotAValidAddress;
                      }
                    },
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
        ),
      ),
    ));
  }
}

enum StatusButton { SEND, RECEIVE }
