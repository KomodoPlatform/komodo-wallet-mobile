import 'dart:async';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/error_code.dart';
import 'package:komodo_dex/model/send_raw_transaction_response.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/model/transaction_data.dart';
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/portfolio/transaction_detail.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';

class CoinDetail extends StatefulWidget {
  const CoinDetail({this.coinBalance, this.isSendIsActive = false});

  final CoinBalance coinBalance;
  final bool isSendIsActive;

  @override
  _CoinDetailState createState() => _CoinDetailState();

  void showDialogClaim(BuildContext mContext) {
    dialogBloc.dialog = showDialog<dynamic>(
        context: mContext,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(AppLocalizations.of(context).loading),
                ],
              ),
            ),
          );
        }).then((dynamic _) {
      dialogBloc.dialog = null;
    });

    mm2
        .postWithdraw(
            coinBalance.coin,
            coinBalance.balance.address,
            (Decimal.parse(coinBalance.balance.getBalance()) -
                    (Decimal.parse(coinBalance.coin.txfee.toString()) /
                        Decimal.parse('100000000')))
                .toDouble(),
            true)
        .then((dynamic data) {
      Navigator.of(mContext).pop();
      if (data is WithdrawResponse) {
        print(data.myBalanceChange);
        if (data.myBalanceChange > 0) {
          dialogBloc.dialog = showDialog<dynamic>(
            context: mContext,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context).claimTitle),
                content: Text(AppLocalizations.of(context).youWillReceiveClaim(
                    data.myBalanceChange.toString(), coinBalance.coin.abbr)),
                actions: <Widget>[
                  FlatButton(
                    child:
                        Text(AppLocalizations.of(context).close.toUpperCase()),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  RaisedButton(
                    child: Text(
                        AppLocalizations.of(context).confirm.toUpperCase(),
                        style: Theme.of(context).textTheme.button),
                    onPressed: () {
                      mm2
                          .postRawTransaction(coinBalance.coin, data.txHex)
                          .then((dynamic dataRawTx) {
                        if (dataRawTx is SendRawTransactionResponse) {
                          Navigator.of(context).pop();
                          dialogBloc.dialog = showDialog<dynamic>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                      AppLocalizations.of(context).success),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(AppLocalizations.of(context)
                                          .close
                                          .toUpperCase()),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              }).then((dynamic _) {
                            dialogBloc.dialog = null;
                          });
                        }
                      }).catchError((dynamic onError) {
                        generateSnackBar(mContext,
                            AppLocalizations.of(mContext).errorTryLater);
                      });
                    },
                  )
                ],
              );
            },
          ).then((dynamic _) {
            dialogBloc.dialog = null;
          });
        } else {
          generateSnackBar(mContext, AppLocalizations.of(mContext).noRewardYet);
        }
      } else {
        generateSnackBar(mContext, AppLocalizations.of(mContext).errorTryLater);
      }
    }).catchError((dynamic onError) {
      generateSnackBar(mContext, AppLocalizations.of(mContext).errorTryLater);
    });
  }

  void generateSnackBar(BuildContext mContext, String text) {
    Scaffold.of(mContext).showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(text),
    ));
  }
}

class _CoinDetailState extends State<CoinDetail> {
  String barcode = '';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _onWithdrawPost = false;
  NumberFormat f = NumberFormat('###,###.0#');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isExpanded = false;
  int currentIndex = 0;
  List<Widget> listSteps = <Widget>[];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final FocusNode _focus = FocusNode();
  String fromId;
  int limit = 10;
  bool isLoading = false;
  double elevationHeader = 0.0;
  bool loadingWithdrawDialog = true;
  CoinBalance currentCoinBalance;
  bool isSendIsActive;
  Timer timer;
  BuildContext mainContext;

  @override
  void initState() {
    isSendIsActive = widget.isSendIsActive;
    currentCoinBalance = widget.coinBalance;
    if (isSendIsActive) {
      setState(() {
        isExpanded = true;
      });
    }
    authBloc.setIsQrCodeActive(false);
    currentIndex = 0;
    setState(() {
      isLoading = true;
    });
    coinsBloc
        .updateTransactions(currentCoinBalance.coin, limit, null)
        .then((_) {
      setState(() {
        isLoading = false;
      });
    });
    _amountController.addListener(onChange);
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        coinsBloc
            .updateTransactions(currentCoinBalance.coin, limit, fromId)
            .then((_) {
          setState(() {
            isLoading = false;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    coinsBloc.loadCoin();
    _amountController.dispose();
    _addressController.dispose();
    _scrollController.dispose();
    coinsBloc.resetTransactions();
    if (timer != null) {
      timer.cancel();
    }
    mainBloc.isUrlLaucherIsOpen = false;
    super.dispose();
  }

  void onChange() {
    final String text = _amountController.text.replaceAll(',', '.');
    if (text.isNotEmpty) {
      setState(() {
        if (currentCoinBalance != null &&
            text.isNotEmpty &&
            double.parse(text) >
                double.parse(currentCoinBalance.balance.getBalance())) {
          setMaxValue();
        }
      });
    }
  }

  Future<void> setMaxValue() async {
    _focus.unfocus();
    setState(() {
      _amountController.text = currentCoinBalance.balance.getBalance();
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 0), () {
      setState(() {
        FocusScope.of(context).requestFocus(_focus);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (listSteps.isEmpty) {
      initSteps();
    }

    return LockScreen(
      context: context,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          elevation: elevationHeader,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                mainBloc.isUrlLaucherIsOpen = true;
                await Share.share(AppLocalizations.of(context).shareAddress(
                    currentCoinBalance.coin.name,
                    currentCoinBalance.balance.address));
              },
            )
          ],
          title: Row(
            children: <Widget>[
              PhotoHero(
                tag:
                    'assets/${currentCoinBalance.balance.coin.toLowerCase()}.png',
                radius: 16,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(currentCoinBalance.coin.name.toUpperCase()),
            ],
          ),
          centerTitle: false,
          backgroundColor: Color(int.parse(currentCoinBalance.coin.colorCoin)),
        ),
        body: Builder(builder: (BuildContext context) {
          mainContext = context;
          return Column(
            children: <Widget>[
              _buildForm(),
              _buildHeaderCoinDetail(context),
              _buildSyncChain(),
              _buildTransactionsList(context),
            ],
          );
        }),
      ),
    );
  }

  bool isRefresh = false;

  Widget _buildSyncChain() {
    return StreamBuilder<dynamic>(
        stream: coinsBloc.outTransactions,
        initialData: coinsBloc.transactions,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data is Transactions) {
            final Transactions tx = snapshot.data;
            final String syncState =
                '${StateOfSync.InProgress.toString().substring(StateOfSync.InProgress.toString().indexOf('.') + 1)}';
            if (tx.result != null &&
                tx.result.syncStatus != null &&
                tx.result.syncStatus.state != null) {
              print(tx.result.syncStatus.state);
              print('START TIMER');
              timer ??= Timer.periodic(const Duration(seconds: 15), (_) {
                _refresh();
              });

              if (tx.result.syncStatus.state == syncState) {
                String txLeft;
                if (widget.coinBalance.coin.swapContractAddress.isNotEmpty) {
                  txLeft =
                      tx.result.syncStatus.additionalInfo.blocksLeft.toString();
                } else {
                  txLeft = tx.result.syncStatus.additionalInfo.transactionsLeft
                      .toString();
                }
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Theme.of(context).backgroundColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Center(
                          child: Container(
                        height: 20,
                        width: 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                      )),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text('Loading...'),
                      Expanded(
                        child: Container(),
                      ),
                      Text(
                          widget.coinBalance.coin.swapContractAddress.isNotEmpty
                              ? 'Syncing $txLeft TXs'
                              : 'Transactions left $txLeft'),
                    ],
                  ),
                );
              }
            }
          }
          return Container();
        });
  }

  Widget _buildTransactionsList(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        backgroundColor: Theme.of(context).backgroundColor,
        color: Theme.of(context).accentColor,
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            StreamBuilder<dynamic>(
                stream: coinsBloc.outTransactions,
                initialData: coinsBloc.transactions,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: const CircularProgressIndicator());
                  }
                  if (snapshot.data is Transactions) {
                    final Transactions transactions = snapshot.data;
                    final String syncState =
                        '${StateOfSync.InProgress.toString().substring(StateOfSync.InProgress.toString().indexOf('.') + 1)}';

                    if (snapshot.hasData &&
                        transactions.result != null &&
                        transactions.result.transactions != null) {
                      if (transactions.result.transactions.isNotEmpty) {
                        //@Slyris plz clean up
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          child: _buildTransactions(
                              context, transactions.result.transactions),
                        );
                      } else if (transactions.result.transactions.isEmpty &&
                          !(transactions.result.syncStatus.state ==
                              syncState)) {
                        return Center(
                            child: Text(
                          AppLocalizations.of(context).noTxs,
                          style: Theme.of(context).textTheme.body2,
                        ));
                      }
                    }
                  } else if (snapshot.data is ErrorCode &&
                      snapshot.data.error != null) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: Text(
                        snapshot.data.error.message,
                        style: Theme.of(context).textTheme.body2,
                        textAlign: TextAlign.center,
                      )),
                    );
                  }
                  return Container();
                })
          ],
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    return await coinsBloc.updateTransactions(
        currentCoinBalance.coin, limit, null);
  }

  Widget _buildTransactions(
      BuildContext context, List<Transaction> transactionsData) {
    final List<Widget> transactionsWidget = transactionsData
        .map((Transaction transaction) =>
            _buildItemTransaction(transaction, context))
        .toList();

    transactionsWidget.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: const CircularProgressIndicator(),
        ),
      ),
    ));

    return Column(
      children: transactionsWidget,
    );
  }

  Widget _buildItemTransaction(Transaction transaction, BuildContext context) {
    fromId = transaction.internalId;

    final TextStyle subtitle = Theme.of(context)
        .textTheme
        .subtitle
        .copyWith(fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Card(
          color: Theme.of(context).primaryColor,
          elevation: 8.0,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            onTap: () {
              Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => TransactionDetail(
                        transaction: transaction,
                        coinBalance: currentCoinBalance)),
              );
            },
            child: Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: transaction.myBalanceChange > 0
                                      ? Colors.green
                                      : Colors.redAccent,
                                  width: 2)),
                          child: transaction.myBalanceChange > 0
                              ? Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                )
                              : Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                )),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 8),
                            child: Builder(builder: (BuildContext context) {
                              final String amount = widget.coinBalance.coin
                                      .swapContractAddress.isNotEmpty
                                  ? replaceAllTrainlingZeroERC(transaction
                                      .myBalanceChange
                                      .toStringAsFixed(16))
                                  : replaceAllTrainlingZero(transaction
                                      .myBalanceChange
                                      .toStringAsFixed(8));

                              return AutoSizeText(
                                '${transaction.myBalanceChange > 0 ? '+' : ''}$amount ${currentCoinBalance.coin.abbr}',
                                maxLines: 1,
                                style: subtitle,
                                textAlign: TextAlign.end,
                              );
                            }),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16, top: 8),
                            child: Text(
                              (Decimal.parse(currentCoinBalance.priceForOne) *
                                          Decimal.parse(transaction
                                              .myBalanceChange
                                              .toString()))
                                      .toStringAsFixed(2) +
                                  ' USD',
                              style: Theme.of(context).textTheme.body2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          transaction.getTimeFormat(),
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Builder(
                        builder: (BuildContext context) {
                          return transaction.confirmations > 0
                              ? Container(
                                  height: 12,
                                  width: 12,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(16)),
                                      color: Colors.green),
                                )
                              : Container(
                                  height: 12,
                                  width: 12,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(16)),
                                      color: Colors.red),
                                );
                        },
                      )
                    ],
                  ),
                )
              ],
            )),
          )),
    );
  }

  Widget _buildHeaderCoinDetail(BuildContext mContext) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: StreamBuilder<List<CoinBalance>>(
              initialData: coinsBloc.coinBalance,
              stream: coinsBloc.outCoins,
              builder: (BuildContext context,
                  AsyncSnapshot<List<CoinBalance>> snapshot) {
                if (snapshot.hasData) {
                  for (CoinBalance coinBalance in snapshot.data) {
                    if (coinBalance.coin.abbr == currentCoinBalance.coin.abbr) {
                      currentCoinBalance = coinBalance;
                    }
                  }

                  return Column(
                    children: <Widget>[
                      Text(
                        currentCoinBalance.balance.getBalance() +
                            ' ' +
                            currentCoinBalance.balance.coin.toString(),
                        style: Theme.of(context).textTheme.title,
                        textAlign: TextAlign.center,
                      ),
                      Text('\$${currentCoinBalance.getBalanceUSD()} USD')
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
            const SizedBox(
              width: 16,
            ),
            _buildButtonLight(StatusButton.RECEIVE, mContext),
            const SizedBox(
              width: 8,
            ),
            currentCoinBalance.coin.abbr == 'KMD' &&
                    double.parse(currentCoinBalance.balance.getBalance()) >= 10
                ? _buildButtonLight(StatusButton.CLAIM, mContext)
                : Container(),
            const SizedBox(
              width: 8,
            ),
            double.parse(currentCoinBalance.balance.getBalance()) > 0
                ? _buildButtonLight(StatusButton.SEND, mContext)
                : Container(),
            const SizedBox(
              width: 16,
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        )
      ],
    );
  }

  Widget _buildButtonLight(StatusButton statusButton, BuildContext mContext) {
    if (currentIndex == 3 && statusButton == StatusButton.SEND) {
      _closeAfterAWait();
    }
    return Expanded(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(32)),
        onTap: () {
          switch (statusButton) {
            case StatusButton.RECEIVE:
              showAddressDialog(mContext, currentCoinBalance.balance.address);
              break;
            case StatusButton.SEND:
              if (currentIndex == 3) {
                setState(() {
                  isExpanded = false;
                  _waitForInit();
                });
              } else {
                setState(() {
                  elevationHeader == 8.0
                      ? elevationHeader = 8.0
                      : elevationHeader = 0.0;
                  isExpanded = !isExpanded;
                });
              }
              break;
            case StatusButton.CLAIM:
              widget.showDialogClaim(mContext);
              break;
            default:
          }
        },
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                border:
                    Border.all(color: Theme.of(context).textSelectionColor)),
            child: Center(child: Builder(
              builder: (BuildContext context) {
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
                  case StatusButton.CLAIM:
                    return Text(
                      AppLocalizations.of(context).claim.toUpperCase(),
                      style: Theme.of(context).textTheme.body1,
                    );
                    break;
                }
                return Container();
              },
            ))),
      ),
    );
  }

  Widget _buildForm() {
    return AnimatedCrossFade(
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
      firstChild: Container(),
      secondChild: Card(
          margin: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 16),
          elevation: 8.0,
          color: Theme.of(context).primaryColor,
          child: listSteps[currentIndex]),
    );
  }

  Widget _buildWithdrawButton(BuildContext context) {
    if (_onWithdrawPost) {
      return Center(
        child: Container(
            height: 30,
            width: 30,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            )),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 50,
        child: Builder(
          builder: (BuildContext mContext) {
            return RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)),
              color: Theme.of(context).buttonColor,
              disabledColor: Theme.of(context).disabledColor,
              child: Text(
                AppLocalizations.of(context).withdraw.toUpperCase(),
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () async {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                setState(() {
                  _amountController.text =
                      _amountController.text.replaceAll(',', '.');
                });
                if (_formKey.currentState.validate()) {
                  final Widget buildConfirmationStep =
                      await _buildConfirmationStep(mContext);

                  setState(() {
                    isExpanded = false;
                    listSteps.add(buildConfirmationStep);
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

  Future<Widget> _buildConfirmationStep(BuildContext mContext) async {
    final bool isErcCoin =
        widget.coinBalance.coin.swapContractAddress?.isNotEmpty;
    bool notEnoughEth = false;
    bool isEthActive = false;
    double fee = 0;
    try {
      fee = await getFee();
    } catch (e) {
      print(e);
    }

    double amountToPay = double.parse(_amountController.text);
    if (!isErcCoin) {
      amountToPay += fee;
    }
    double amountUserReceive = double.parse(_amountController.text);
    final double userBalance =
        double.parse(widget.coinBalance.balance.getBalance());

    if (amountToPay > userBalance) {
      amountUserReceive = userBalance;
    }

    if (userBalance == amountUserReceive) {
      amountToPay = amountUserReceive;
      if (!isErcCoin) {
        amountUserReceive -= fee;
      }
    }
    CoinBalance ethCoin;
    for (CoinBalance coinBalance in coinsBloc.coinBalance) {
      if (coinBalance.coin.abbr == 'ETH') {
        ethCoin = coinBalance;
      }
    }

    isEthActive = !(ethCoin == null);

    if (ethCoin != null && fee > double.parse(ethCoin.balance.balance)) {
      notEnoughEth = true;
    }

    final bool isButtonActive =
        (widget.coinBalance.coin.swapContractAddress.isEmpty &&
                amountToPay > 0) ||
            (amountToPay > 0 && !notEnoughEth && isEthActive);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).youAreSending,
            style: Theme.of(context).textTheme.subtitle,
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                amountToPay.toStringAsFixed(8),
                style: Theme.of(context).textTheme.subtitle,
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                currentCoinBalance.coin.abbr,
                style: Theme.of(context).textTheme.body1,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                '- ',
                style: Theme.of(context).textTheme.body2,
              ),
              Text(
                fee.toStringAsFixed(8),
                style: Theme.of(context).textTheme.body2,
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                isErcCoin
                    ? AppLocalizations.of(context).ethFee
                    : AppLocalizations.of(context).networkFee,
                style: Theme.of(context).textTheme.body2,
              ),
            ],
          ),
          widget.coinBalance.coin.swapContractAddress.isNotEmpty &&
                  notEnoughEth &&
                  isEthActive
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).notEnoughEth,
                      style: Theme.of(context)
                          .textTheme
                          .body2
                          .copyWith(color: Theme.of(context).errorColor),
                    ),
                  ],
                )
              : Container(),
          widget.coinBalance.coin.swapContractAddress.isNotEmpty && !isEthActive
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).ethNotActive,
                      style: Theme.of(context)
                          .textTheme
                          .body2
                          .copyWith(color: Theme.of(context).errorColor),
                    ),
                  ],
                )
              : Container(),
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
                amountUserReceive.toStringAsFixed(8),
                style: Theme.of(context).textTheme.title,
              ),
              const SizedBox(
                width: 4,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  currentCoinBalance.coin.abbr,
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            AppLocalizations.of(context).toAddress,
            style: Theme.of(context).textTheme.subtitle,
          ),
          const SizedBox(
            height: 24,
          ),
          Container(
            child: AutoSizeText(
              _addressController.text,
              style: Theme.of(context).textTheme.body1,
              maxLines: 1,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 50,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    onTap: () {
                      setState(() {
                        isExpanded = false;
                        _waitForInit();
                      });
                    },
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).cancel.toUpperCase(),
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Container(
                  height: 50,
                  child: Builder(builder: (BuildContext context) {
                    return RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0)),
                      color: Theme.of(context).buttonColor,
                      disabledColor: Theme.of(context).disabledColor,
                      child: Text(
                        AppLocalizations.of(context).confirm.toUpperCase(),
                        style: Theme.of(context).textTheme.button,
                      ),
                      onPressed: isButtonActive
                          ? () {
                              _onPressedConfirmWithdraw(
                                  mContext, amountUserReceive);
                            }
                          : null,
                    );
                  }),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<double> getFee() async {
    try {
      final TradeFee tradeFeeResponse =
          await mm2.getTradeFee(currentCoinBalance.coin);
      return double.parse(tradeFeeResponse.result.amount);
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<void> _onPressedConfirmWithdraw(
      BuildContext mContext, double sendAmount) async {
    if (mainBloc.isNetworkOffline) {
      Scaffold.of(mainContext).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).errorColor,
        content: Text(AppLocalizations.of(mainContext).noInternet),
      ));
    } else {
      setState(() {
        isSendIsActive = false;
      });
      listSteps.add(Container(
          height: 100,
          width: double.infinity,
          child: Center(
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )));
      setState(() {
        currentIndex = 2;
      });

      mm2
          .postWithdraw(
              currentCoinBalance.coin,
              _addressController.text.toString(),
              sendAmount,
              double.parse(widget.coinBalance.balance.getBalance()) ==
                  double.parse(_amountController.text))
          .then((dynamic data) {
        if (data is WithdrawResponse) {
          mm2
              .postRawTransaction(widget.coinBalance.coin, data.txHex)
              .then((dynamic dataRawTx) {
            if (dataRawTx is SendRawTransactionResponse &&
                dataRawTx.txHash.isNotEmpty) {
              setState(() {
                _onWithdrawPost = false;
                coinsBloc.updateTransactions(
                    widget.coinBalance.coin, limit, null);
                coinsBloc.loadCoin();
                Future<dynamic>.delayed(const Duration(seconds: 5), () {
                  coinsBloc.loadCoin();
                });
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
                              Text(AppLocalizations.of(context).success),
                              const SizedBox(
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
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ));
                currentIndex = 3;
              });
            } else {
              catchError(mainContext);
            }
          }).catchError((dynamic onError) {
            catchError(mainContext);
          });
        } else {
          catchError(mainContext);
        }
      }).catchError((dynamic onError) {
        catchError(mainContext);
      });
    }
  }

  void catchError(BuildContext mContext) {
    resetSend();
    Scaffold.of(mContext).showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).errorColor,
      content: Text(AppLocalizations.of(mContext).errorTryLater),
    ));
  }

  void resetSend() {
    setState(() {
      currentIndex = 0;
      isExpanded = false;
      initSteps();
    });
  }

  Future<void> _closeAfterAWait() async {
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          isExpanded = false;
          _waitForInit();
        });
      }
    });
  }

  Future<void> _waitForInit() async {
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        currentIndex = 0;
        initSteps();
      });
    });
  }

  void _copyToClipBoard(BuildContext context, String str) {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 300),
      content: Text(AppLocalizations.of(context).clipboard),
    ));
    Clipboard.setData(ClipboardData(text: str));
  }

  /// Open a activity for scan QRCode example usage:
  /// MaterialButton(onPressed: scan, child:  Text('SEND'))
  Future<void> scan() async {
    authBloc.setIsQrCodeActive(true);
    try {
      final String barcode = await BarcodeScanner.scan();
      setState(() {
        _addressController.text = barcode;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => barcode = 'Unknown error: $e');
    }
    authBloc.setIsQrCodeActive(false);
  }

  void initSteps() {
    _amountController.clear();
    _addressController.clear();
    listSteps.clear();
    listSteps.add(Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Container(
                  height: 60,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0)),
                    child: Text(
                      AppLocalizations.of(context).max,
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Theme.of(context).accentColor),
                    ),
                    onPressed: () {
                      setMaxValue();
                    },
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextFormField(
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter(RegExp(
                          '^\$|^(0|([1-9][0-9]{0,3}))([.,]{1}[0-9]{0,8})?\$'))
                    ],
                    focusNode: _focus,
                    controller: _amountController,
                    autofocus: isSendIsActive,
                    textInputAction: TextInputAction.done,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: Theme.of(context).textTheme.body1,
                    textAlign: TextAlign.end,
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
                    validator: (String value) {
                      value = value.replaceAll(',', '.');
                      final double balance =
                          double.parse(widget.coinBalance.balance.getBalance());

                      if (value.isEmpty || double.parse(value) <= 0) {
                        return AppLocalizations.of(context).errorValueNotEmpty;
                      }

                      final double currentAmount = double.parse(value);

                      if (currentAmount > balance) {
                        return AppLocalizations.of(context).errorAmountBalance;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Container(
                  height: 60,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0)),
                    onPressed: scan,
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _addressController,
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    style: Theme.of(context).textTheme.body1,
                    textAlign: TextAlign.end,
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
                    validator: (String value) {
                      if (value.isEmpty) {
                        return AppLocalizations.of(context).errorValueNotEmpty;
                      }
                      if (widget
                          .coinBalance.coin.swapContractAddress.isNotEmpty) {
                        if (!isAddress(value)) {
                          return AppLocalizations.of(context)
                              .errorNotAValidAddress;
                        }
                      } else {
                        try {
                          final Uint8List decoded = bs58check.decode(value);
                          print(bs58check.encode(decoded));
                        } catch (e) {
                          print(e);
                          return AppLocalizations.of(context)
                              .errorNotAValidAddress;
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            _buildWithdrawButton(context)
          ],
        ),
      ),
    ));
  }
}

enum StatusButton { SEND, RECEIVE, CLAIM }

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
