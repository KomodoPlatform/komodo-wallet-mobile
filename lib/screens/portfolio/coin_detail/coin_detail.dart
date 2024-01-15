import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app_config/app_config.dart';
import '../../../../blocs/coin_detail_bloc.dart';
import '../../../../blocs/coins_bloc.dart';
import '../../../../blocs/main_bloc.dart';
import '../../../../blocs/settings_bloc.dart';
import '../../../../localizations.dart';
import '../../../../model/cex_provider.dart';
import '../../../../model/coin.dart';
import '../../../../model/coin_balance.dart';
import '../../../../model/coin_type.dart';
import '../../../../model/error_code.dart';
import '../../../../model/error_string.dart';
import '../../../../model/get_send_raw_transaction.dart';
import '../../../../model/rewards_provider.dart';
import '../../../../model/send_raw_transaction_response.dart';
import '../../../../model/transaction_data.dart';
import '../../../../model/transactions.dart';
import '../../../../model/withdraw_response.dart';
import '../../../../services/mm.dart';
import '../../../../services/mm_service.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/auto_scroll_text.dart';
import '../../../../widgets/build_red_dot.dart';
import '../../../../widgets/photo_widget.dart';
import '../../../../widgets/primary_button.dart';
import '../../../../widgets/secondary_button.dart';
import '../../authentification/lock_screen.dart';
import '../../portfolio/coin_detail/steps_withdraw.dart/amount_address_step/amount_address_step.dart';
import '../../portfolio/coin_detail/steps_withdraw.dart/build_confirmation_step.dart';
import '../../portfolio/coin_detail/steps_withdraw.dart/success_step.dart';
import '../../portfolio/coin_detail/tx_list_item.dart';
import '../../portfolio/copy_dialog.dart';
import '../../portfolio/faucet_dialog.dart';
import '../../portfolio/rewards_page.dart';

class CoinDetail extends StatefulWidget {
  const CoinDetail({
    this.coinBalance,
    this.isSendIsActive = false,
    this.paymentUriInfo,
  });

  final CoinBalance coinBalance;
  final bool isSendIsActive;
  final PaymentUriInfo paymentUriInfo;

  @override
  _CoinDetailState createState() => _CoinDetailState();
}

class _CoinDetailState extends State<CoinDetail> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final FocusNode _focus = FocusNode();
  BuildContext mainContext;
  String fromId;
  bool isExpanded = false;
  Timer closeTimer;
  bool isLoading = false;
  bool loadingWithdrawDialog = true;
  bool isSendIsActive;
  double elevationHeader = 0.0;
  int currentIndex = 0;
  int limit = 10;
  CoinBalance currentCoinBalance;
  NumberFormat f = NumberFormat('###,###.0#');
  List<Widget> listSteps = <Widget>[];
  Timer timer;
  bool isDeleteLoading = false;
  CexProvider cexProvider;
  bool _shouldRefresh = false;
  bool _isWaiting = false;
  RewardsProvider rewardsProvider;
  Transaction latestTransaction;

  bool isRetryingActivation = false;

  @override
  void initState() {
    cexProvider ??= Provider.of<CexProvider>(context, listen: false);
    // set default coin
    Future.delayed(Duration.zero, () {
      cexProvider.withdrawCurrency = widget.coinBalance.coin.abbr.toUpperCase();
    });

    isSendIsActive = widget.isSendIsActive;
    currentCoinBalance = widget.coinBalance;
    if (isSendIsActive) {
      setState(() {
        isExpanded = true;
      });
    }
    currentIndex = 0;
    setState(() {
      isLoading = true;
    });
    coinsBloc.updateTransactions(currentCoinBalance, limit, null).then((_) {
      final result = coinsBloc.transactionsOrNull?.result;

      if (result?.transactions?.isNotEmpty ?? false) {
        fromId = result.transactions.last.internalId;
      }
    }).whenComplete(() {
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
    coinsBloc.getLatestTransaction(currentCoinBalance).then((Transaction t) {
      if (t != null) latestTransaction = t;
    });
    super.initState();

    _scrollController.addListener(() {
      if (!isTransactionsScrolledToEnd || isLoading) return;

      final blocTransactions = coinsBloc.transactionsOrNull;

      final hasMoreToLoad = blocTransactions.result == null
          ? null
          : blocTransactions.result.total >
              blocTransactions.result.transactions.length;

      if (hasMoreToLoad ?? true) {
        setState(() {
          isLoading = true;
        });

        final maxScrollBeforeLoading =
            _scrollController.position.maxScrollExtent.toDouble();

        coinsBloc
            .updateTransactions(currentCoinBalance, limit, fromId)
            .then((_) {
          final result = coinsBloc.transactionsOrNull?.result;

          if (result?.transactions?.isNotEmpty ?? false) {
            fromId = result.transactions.last.internalId;
          }

          // Scroll down slightly so that the user is aware that there is new
          // content. If the user has scrolled up while loading, they will
          // be scrolled back down to the beginning of the new content.
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              maxScrollBeforeLoading + 40,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        }).whenComplete(() {
          if (mounted) setState(() => isLoading = false);
        });
      }
    });
  }

  bool get isTransactionsScrolledToEnd =>
      _scrollController.position.pixels ==
      _scrollController.position.maxScrollExtent;

  @override
  void dispose() {
    if (!isDeleteLoading) {
      coinsBloc.updateCoinBalances();
    }
    _amountController.dispose();
    _addressController.dispose();
    _scrollController.dispose();
    closeTimer?.cancel();
    coinsBloc.resetTransactions();
    if (timer != null) {
      timer.cancel();
    }
    mainBloc.isUrlLaucherIsOpen = false;
    coinsDetailBloc.resetCustomFee();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (listSteps.isEmpty) {
      initSteps();
    }
    cexProvider ??= Provider.of<CexProvider>(context);
    rewardsProvider ??= Provider.of<RewardsProvider>(context);

    return LockScreen(
      context: context,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: elevationHeader,
          foregroundColor: ThemeData.estimateBrightnessForColor(
                    Color(int.parse(currentCoinBalance.coin.colorCoin)),
                  ) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black,
          actions: <Widget>[
            IconButton(
              splashRadius: 24,
              key: const Key('coin-deactivate'),
              icon: isDeleteLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: const CircularProgressIndicator(strokeWidth: 1.5),
                    )
                  : Icon(Icons.delete),
              onPressed: () async {
                if (currentCoinBalance.coin.isDefault) {
                  await showCantRemoveDefaultCoin(
                    context,
                    currentCoinBalance.coin,
                  );
                } else {
                  setState(() {
                    isDeleteLoading = true;
                  });
                  showConfirmationRemoveCoin(context, currentCoinBalance.coin)
                      .then((_) {
                    setState(() {
                      isDeleteLoading = false;
                    });
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                mainBloc.isUrlLaucherIsOpen = true;
                await Share.share(
                  AppLocalizations.of(context).shareAddress(
                    currentCoinBalance.coin.name,
                    currentCoinBalance.balance.address,
                  ),
                );
              },
            )
          ],
          title: Row(
            children: <Widget>[
              Stack(
                children: [
                  PhotoHero(
                    tag: getCoinIconPath(currentCoinBalance.balance.coin),
                    radius: 16,
                  ),
                  if (currentCoinBalance.coin.suspended)
                    Icon(
                      Icons.warning_rounded,
                      size: 12,
                      color: Colors.yellow[600],
                    ),
                ],
                alignment: Alignment.bottomRight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AutoScrollText(
                  text: currentCoinBalance.coin.name.toUpperCase(),
                ),
              ),
            ],
          ),
          centerTitle: false,
          backgroundColor: Color(int.parse(currentCoinBalance.coin.colorCoin)),
        ),
        body: Column(
          children: [
            // Don't show the loading bar for the initial load, since there is
            // already a circular progress indicator in the place of the list.
            if (isLoading && fromId != null) LinearProgressIndicator(),
            Expanded(
              child: Builder(
                builder: (BuildContext context) {
                  mainContext = context;

                  return RefreshIndicator(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    color: Theme.of(context).colorScheme.secondary,
                    key: _refreshIndicatorKey,
                    onRefresh: _refresh,
                    child: Scrollbar(
                      controller: _scrollController,
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          if (!currentCoinBalance.coin.suspended)
                            SliverToBoxAdapter(child: _buildForm()),
                          SliverToBoxAdapter(
                            child: _buildHeaderCoinDetail(context),
                          ),
                          if (_shouldRefresh &&
                              !currentCoinBalance.coin.suspended)
                            SliverToBoxAdapter(
                              child: _buildNewTransactionsButton(),
                            ),
                          if (!currentCoinBalance.coin.suspended)
                            SliverToBoxAdapter(child: _buildSyncChain()),
                          (currentCoinBalance.coin.suspended)
                              ? SliverToBoxAdapter(
                                  child: _buildErrorMessage(context),
                                )
                              : _buildTransactionsSliverList(context),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isRefresh = false;

  Widget _buildSyncChain() {
    // Since we currently fetching erc20 transactions history
    // from the http endpoint, sync status indicator is hidden
    // for erc20 tokens

    if (isErcType(widget.coinBalance.coin)) {
      return SizedBox();
    }

    return StreamBuilder<dynamic>(
      stream: coinsBloc.outTransactions,
      initialData: coinsBloc.transactions,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data is Transactions) {
          final Transactions tx = snapshot.data;
          final String syncState = StateOfSync.InProgress.toString()
              .substring(StateOfSync.InProgress.toString().indexOf('.') + 1);
          if (tx.result != null &&
              tx.result.syncStatus != null &&
              tx.result.syncStatus.state != null) {
            timer ??= Timer.periodic(const Duration(seconds: 3), (_) async {
              final Transaction t =
                  await coinsBloc.getLatestTransaction(currentCoinBalance);

              if (_isWaiting) {
                _refresh();
              } else if (_scrollController.hasClients &&
                  _scrollController.position.pixels == 0.0) {
                _refresh();
              } else if (latestTransaction == null ||
                  latestTransaction.internalId != t.internalId) {
                _shouldRefresh = true;
              }

              latestTransaction = t;
            });

            if (tx.result.syncStatus.state == syncState) {
              final String txLeft = tx
                  .result.syncStatus.additionalInfo.transactionsLeft
                  .toString();

              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(AppLocalizations.of(context).loading),
                    Expanded(child: SizedBox()),
                    Text(AppLocalizations.of(context).txleft(txLeft)),
                  ],
                ),
              );
            }
          }
        }
        return SizedBox();
      },
    );
  }

  Widget _buildTxExplorerButton(String link) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton(
              key: Key('tx-explorer-button'),
              onPressed: () => launchURL(link),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 12),
                side:
                    BorderSide(color: Theme.of(context).colorScheme.secondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child:
                  Text(AppLocalizations.of(context).seeTxHistory.toUpperCase()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSliverList(BuildContext context) {
    List<CoinType> coinsWithoutHist = [
      CoinType.hrc,
      CoinType.ubiq,
      CoinType.sbch,
      CoinType.krc,
      CoinType.hco,
    ];

    if (coinsWithoutHist.contains(currentCoinBalance.coin.type)) {
      return SliverToBoxAdapter(
        child: _buildTxExplorerButton(
          '${currentCoinBalance.coin.explorerUrl}address/${currentCoinBalance.balance.address}',
        ),
      );
    }

    return StreamBuilder<dynamic>(
      key: const Key('transactions-list'),
      stream: coinsBloc.outTransactions,
      initialData: coinsBloc.transactions,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          _isWaiting = true;
          return SliverFillRemaining(
            child: const Center(child: CircularProgressIndicator()),
          );
        } else {
          _isWaiting = false;
        }

        if (snapshot.data is Transactions) {
          final Transactions transactions = snapshot.data;
          final String syncState = StateOfSync.InProgress.toString().substring(
            StateOfSync.InProgress.toString().indexOf('.') + 1,
          );

          if (snapshot.hasData &&
              transactions.result != null &&
              transactions.result.transactions != null) {
            if (transactions.result.transactions.isNotEmpty) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildTransactionItem(
                    transactions.result.transactions[i],
                  ),
                  childCount: transactions.result.transactions.length,
                ),
              );
            } else if (transactions.result.transactions.isEmpty &&
                !(transactions.result.syncStatus.state == syncState)) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).noTxs,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              );
            }
          }
        } else if (snapshot.data is ErrorCode && snapshot.data.error != null) {
          return SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  snapshot.data.error.message,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return SliverFillRemaining(child: SizedBox());
      },
    );
  }

  void _goToPreviousPage(BuildContext context) {
    Navigator.of(context).pop();
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: isRetryingActivation
              ? [
                  CircularProgressIndicator(),
                  SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).retryActivating,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).willBeRedirected,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).tryRestarting,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ]
              : [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 128,
                    color: Colors.yellow[600],
                  ),
                  SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)
                        .weFailedTo(currentCoinBalance.coin.abbr),
                  ),
                  SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).pleaseRestart,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  SizedBox(height: 24),
                  PrimaryButton(
                    onPressed: () {
                      setState(() {
                        isRetryingActivation = true;
                      });
                      coinsBloc
                          .retryActivatingSuspendedCoins()
                          .whenComplete(() => _goToPreviousPage(context));
                    },
                    text: AppLocalizations.of(context).retryAll,
                  ),
                  SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).automaticRedirected,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await coinsBloc.updateTransactions(currentCoinBalance, limit, null);
    if (mounted) {
      setState(() {
        _shouldRefresh = false;
      });
    }
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return TransactionListItem(
      key: ValueKey('transaction-list-item-${transaction.internalId}'),
      transaction: transaction,
      currentCoinBalance: currentCoinBalance,
    );
  }

  Widget _buildHeaderCoinDetail(BuildContext mContext) {
    return Column(
      children: <Widget>[
        if (currentCoinBalance.coin.protocol?.protocolData != null)
          _buildContractAddress(currentCoinBalance.coin.protocol),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: StreamBuilder<List<CoinBalance>>(
            initialData: coinsBloc.coinBalance,
            stream: coinsBloc.outCoins,
            builder: (
              BuildContext context,
              AsyncSnapshot<List<CoinBalance>> snapshot,
            ) {
              if (snapshot.hasData) {
                for (CoinBalance coinBalance in snapshot.data) {
                  if (coinBalance.coin.abbr == currentCoinBalance.coin.abbr) {
                    currentCoinBalance = coinBalance;
                  }
                }

                return StreamBuilder<bool>(
                  initialData: settingsBloc.showBalance,
                  stream: settingsBloc.outShowBalance,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> showBalance) {
                    String coinBalance =
                        currentCoinBalance.balance.getBalance();
                    final String unspendableBalance =
                        currentCoinBalance.balance.getUnspendableBalance();
                    bool hidden = false;
                    if (showBalance.hasData && showBalance.data == false) {
                      coinBalance = '**.**';
                      hidden = true;
                    }
                    return Column(
                      children: <Widget>[
                        Text(
                          coinBalance + ' ' + currentCoinBalance.coin.abbr,
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.center,
                        ),
                        if (double.tryParse(unspendableBalance ?? '0') > 0)
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                            child: Text(
                              '(+${hidden ? '**.**' : unspendableBalance}'
                              ' ${currentCoinBalance.coin.abbr}'
                              ' ${AppLocalizations.of(context).unspendable})',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                        Text(
                          cexProvider.convert(
                            currentCoinBalance.balanceUSD,
                            hidden: hidden,
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Flexible(
                child: _buildButtonLight(StatusButton.RECEIVE, mContext),
              ),
              SizedBox(width: 8),
              if (appConfig.defaultTestCoins
                      .contains(currentCoinBalance.coin.abbr) ||
                  currentCoinBalance.coin.abbr == 'ZOMBIE') ...[
                Flexible(
                  child: _buildButtonLight(StatusButton.FAUCET, mContext),
                ),
                SizedBox(width: 8),
              ],
              Flexible(
                child: _buildButtonLight(StatusButton.SEND, mContext),
              ),
              SizedBox(width: 8),
              if (currentCoinBalance.coin.abbr == 'KMD' &&
                  double.parse(currentCoinBalance.balance.getBalance()) >= 10)
                Flexible(
                  child: _buildButtonLight(StatusButton.CLAIM, mContext),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16)
      ],
    );
  }

  Widget _buildContractAddress(Protocol protocol) {
    final platform = protocol.protocolData.platform;
    String contractAddress = protocol.protocolData.contractAddress;
    if (platform == null || contractAddress == null) return SizedBox();
    String middleUrl = 'address';
    if (platform == 'QTUM') {
      contractAddress = contractAddress.replaceFirst('0x', '');
      middleUrl = 'contract';
    } else if (protocol?.type == 'TENDERMINT') {
      middleUrl = 'account';
      contractAddress = widget.coinBalance.balance.address;
    } else if (protocol?.type == 'TENDERMINTTOKEN') {
      middleUrl = 'address';
      contractAddress = widget.coinBalance.balance.address;
    }

    final allCoins = coinsBloc.knownCoins;
    final platformCoin = allCoins[platform];
    final explorerUrl = platformCoin.explorerUrl;

    final baseUrl = '$explorerUrl/$middleUrl/$contractAddress';

    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 12),
            Text('${AppLocalizations.of(context).contract}:'),
            SizedBox(width: 8),
            Flexible(
              child: Card(
                color: Theme.of(context).cardColor.withAlpha(200),
                child: InkWell(
                  onTap: () => launchURL(baseUrl.replaceAll('//', '/')),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          getCoinIconPath(platform),
                          width: 16,
                          height: 16,
                        ),
                        SizedBox(width: 4),
                        Text('$platform:'),
                        SizedBox(width: 4),
                        Expanded(
                          child: truncateMiddle(contractAddress),
                        ),
                        SizedBox(width: 4),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          iconSize: 16,
                          splashRadius: 12,
                          constraints:
                              BoxConstraints.tightFor(width: 16, height: 16),
                          padding: EdgeInsets.all(0),
                          icon: Icon(Icons.copy_rounded),
                          onPressed: () =>
                              copyToClipBoard(context, contractAddress),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
          ],
        ),
      ],
    );
  }

  Widget _buildButtonLight(StatusButton statusButton, BuildContext mContext) {
    String text = '';
    Widget icon;

    switch (statusButton) {
      case StatusButton.RECEIVE:
        icon = Icon(Icons.qr_code_rounded, color: Colors.green);
        break;
      case StatusButton.SEND:
        icon = Icon(
          Icons.north_east_rounded,
          color: Colors.red,
        );
        break;
      case StatusButton.PUBKEY:
        icon = Icon(Icons.copy_rounded);
        break;
      case StatusButton.FAUCET:
        icon = Icon(Icons.local_drink_rounded, color: Colors.blue);
        break;
      case StatusButton.CLAIM:
        icon = Icon(Icons.card_giftcard_rounded);
        break;
    }

    switch (statusButton) {
      case StatusButton.RECEIVE:
        text = AppLocalizations.of(context).receive;
        break;
      case StatusButton.SEND:
        text = isExpanded
            ? AppLocalizations.of(context).close.toUpperCase()
            : AppLocalizations.of(context).send.toUpperCase();
        break;

      case StatusButton.PUBKEY:
        text = AppLocalizations.of(context).pubkey.toUpperCase();
        break;
      case StatusButton.FAUCET:
        text = AppLocalizations.of(context).faucetName;
        break;
      case StatusButton.CLAIM:
        text = AppLocalizations.of(context).claim.toUpperCase();
        return Stack(
          children: <Widget>[
            SecondaryButton(
              icon: icon,
              key: Key('open-' + statusButton.name),
              text: text,
              textColor: Theme.of(context).textTheme.button.color,
              borderColor: Theme.of(context).colorScheme.secondary,
              onPressed: currentCoinBalance.coin.suspended
                  ? null
                  : () {
                      rewardsProvider.update();
                      Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => RewardsPage(),
                        ),
                      );
                    },
            ),
            if (!currentCoinBalance.coin.suspended && rewardsProvider.needClaim)
              buildRedDot(
                context,
                right: null,
                left: 14,
                top: 20,
              )
          ],
        );
    }

    return SecondaryButton(
      key: Key('open-' + statusButton.name),
      text: text,
      icon: icon,
      isDarkMode: Theme.of(context).brightness != Brightness.light,
      textColor: Theme.of(context).colorScheme.secondary,
      borderColor: Theme.of(context).colorScheme.secondary,
      onPressed: currentCoinBalance.coin.suspended
          ? null
          : () {
              switch (statusButton) {
                case StatusButton.RECEIVE:
                  showCopyDialog(
                    mContext,
                    currentCoinBalance.balance.address,
                    currentCoinBalance.coin,
                  );
                  break;
                case StatusButton.FAUCET:
                  showFaucetDialog(
                    context: mContext,
                    coin: currentCoinBalance.coin.abbr,
                    address: currentCoinBalance.balance.address,
                  );
                  break;
                case StatusButton.SEND:
                  if (double.parse(currentCoinBalance.balance.getBalance()) ==
                      0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(AppLocalizations.of(context).noFundsDetected),
                      ),
                    );
                    return;
                  }
                  if (currentIndex == 3) {
                    setState(() {
                      isExpanded = false;
                      closeTimer?.cancel();
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
                case StatusButton.PUBKEY:
                  getPublicKey().then(
                    (v) => showCopyDialog(mContext, v, currentCoinBalance.coin),
                  );
                  break;
                default:
              }
            },
    );
  }

  Future<String> getPublicKey() async {
    final pb = await MM.getPublicKey();
    final String key = pb.result.publicKey;
    return key;
  }

  Widget _buildForm() {
    return AnimatedCrossFade(
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
      firstChild: SizedBox(),
      firstCurve: Curves.easeIn,
      secondCurve: Curves.easeIn,
      alignment: Alignment.topRight,
      secondChild: GestureDetector(
        onTap: () {
          unfocusEverything();
        },
        child: Card(
          margin: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 16),
          elevation: 8.0,
          child: listSteps[currentIndex],
        ),
      ),
    );
  }

  Widget _buildNewTransactionsButton() {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Theme.of(context).colorScheme.secondary,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            SizedBox(
              width: 8.0,
            ),
            Text(
              AppLocalizations.of(context).latestTxs,
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: Theme.of(context).colorScheme.onSecondary),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      onTap: () async {
        await _refresh();
        if (_scrollController.hasClients)
          _scrollController.position.jumpTo(0.0);
      },
    );
  }

  void catchError(BuildContext mContext, [String err]) {
    resetSend();
    coinsDetailBloc.resetCustomFee();
    ScaffoldMessenger.of(mContext).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).errorColor,
        content: Text(err ?? AppLocalizations.of(mContext).errorTryLater),
      ),
    );
  }

  void resetSend() {
    setState(() {
      currentIndex = 0;
      isExpanded = false;
      initSteps();
    });
  }

  Future<void> _closeAfterAWait() async {
    closeTimer = Timer(const Duration(milliseconds: 3000), () {
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
        coinsDetailBloc.resetCustomFee();
        currentIndex = 0;
        initSteps();
      });
    });
  }

  String _getWithdrawAmountCrypto() {
    String convertedVal;
    final amountParsed = double.tryParse(_amountController.text) ?? 0.0;
    if (cexProvider.withdrawCurrency ==
        currentCoinBalance.coin.abbr.toUpperCase()) {
      convertedVal = _amountController.text;
    } else if (cexProvider.withdrawCurrency == cexProvider.selectedFiat) {
      convertedVal = cexProvider.convert(
        amountParsed,
        from: cexProvider.withdrawCurrency,
        to: currentCoinBalance.coin.abbr,
        showSymbol: false,
      );
    } else {
      convertedVal = cexProvider.convert(
        amountParsed,
        from: cexProvider.withdrawCurrency,
        to: currentCoinBalance.coin.abbr,
        showSymbol: false,
      );
    }
    return convertedVal;
  }

  void initSteps() {
    _amountController.clear();
    _addressController.clear();
    _memoController.clear();
    listSteps.clear();
    listSteps.add(
      AmountAddressStep(
        coinBalance: currentCoinBalance,
        paymentUriInfo: widget.paymentUriInfo,
        scrollController: _scrollController,
        onCancel: () {
          setState(() {
            isExpanded = false;
            _waitForInit();
          });
        },
        onWithdrawPressed: () async {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
          setState(() {
            isExpanded = false;
            listSteps.add(
              BuildConfirmationStep(
                coinBalance: currentCoinBalance,
                amountToPay: _getWithdrawAmountCrypto(),
                addressToSend: _addressController.text,
                memo: _memoController.text,
                onCancel: () {
                  setState(() {
                    isExpanded = false;
                    _waitForInit();
                  });
                },
                onNoInternet: () {
                  ScaffoldMessenger.of(mainContext).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 2),
                      backgroundColor: Theme.of(context).errorColor,
                      content:
                          Text(AppLocalizations.of(mainContext).noInternet),
                    ),
                  );
                },
                onError: () {
                  catchError(mainContext);
                },
                onConfirmPressed: (WithdrawResponse response) {
                  setState(() {
                    isSendIsActive = false;
                  });
                  _scrollController.animateTo(
                    _scrollController.position.minScrollExtent,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 300),
                  );

                  listSteps.add(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context).finishingUp,
                          style: Theme.of(context).textTheme.button.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  );

                  setState(() {
                    currentIndex = 2;
                  });

                  ApiProvider()
                      .postRawTransaction(
                    mmSe.client,
                    GetSendRawTransaction(
                      coin: currentCoinBalance.coin.abbr,
                      txHex: response.txHex,
                    ),
                  )
                      .then((dynamic dataRawTx) {
                    if (dataRawTx is SendRawTransactionResponse &&
                        dataRawTx.txHash.isNotEmpty) {
                      coinsBloc.updateCoinBalances();
                      Future<dynamic>.delayed(const Duration(seconds: 5), () {
                        coinsBloc.updateCoinBalances();
                      });

                      setState(() {
                        listSteps.add(
                          SuccessStep(
                            txHash: dataRawTx.txHash,
                          ),
                        );

                        currentIndex = 3;
                      });
                      _closeAfterAWait();
                    } else if (dataRawTx is ErrorString &&
                        dataRawTx.error.contains('gas is too low')) {
                      resetSend();
                      final String gas = dataRawTx.error
                          .substring(
                            dataRawTx.error.indexOf(
                                  r':',
                                  dataRawTx.error.indexOf(r'"'),
                                ) +
                                1,
                            dataRawTx.error
                                .indexOf(r',', dataRawTx.error.indexOf(r'"')),
                          )
                          .trim();
                      ScaffoldMessenger.of(mainContext).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          backgroundColor: Theme.of(context).errorColor,
                          content: Text(
                            AppLocalizations.of(mainContext)
                                .errorNotEnoughGas(gas),
                          ),
                        ),
                      );
                    } else {
                      if (dataRawTx is ErrorString) {
                        int start = dataRawTx.error.indexOf(r'"');
                        int end = dataRawTx.error.lastIndexOf(r'"');
                        if (start != -1 || end != -1) {
                          String err =
                              dataRawTx.error.substring(start + 1, end);
                          catchError(mainContext, toInitialUpper(err));
                          return;
                        }
                      }
                      catchError(mainContext);
                    }
                  }).catchError((dynamic onError) {
                    if (onError is ErrorString) {
                      int start = onError.error.indexOf(r'"');
                      int end = onError.error.lastIndexOf(r'"');
                      if (start != -1 || end != -1) {
                        String err = onError.error.substring(start + 1, end);
                        catchError(mainContext, toInitialUpper(err));
                        return;
                      }
                    }
                    catchError(mainContext);
                  });

                  if (response is WithdrawResponse) {
                  } else {
                    catchError(mainContext);
                  }
                },
              ),
            );
          });
          setState(() {
            currentIndex = 1;
            isExpanded = true;
          });
        },
        focusNode: _focus,
        addressController: _addressController,
        amountController: _amountController,
        memoController: _memoController,
      ),
    );
  }
}

enum StatusButton { SEND, RECEIVE, FAUCET, CLAIM, PUBKEY }
