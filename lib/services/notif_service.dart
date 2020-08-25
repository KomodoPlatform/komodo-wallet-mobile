import 'dart:async';

import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/get_tx_history.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/model/transaction_data.dart';
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/services/job_service.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';

NotifService notifService = NotifService();

class NotifService {
  bool initialized = false;
  MethodChannel chanell = MMService.nativeC;
  bool isInBackground = false;

  AppLocalizations _localizations;
  final Map<String, Swap> _swaps = {};
  List<String> _transactions;
  final List<String> _notifIds = [];

  Future<void> init(AppLocalizations localizations) async {
    if (initialized) return;
    initialized = true;

    while (!mmSe.running) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 500));
    }

    _localizations = localizations;
    _subscribeSwapStatus();
    _subscribeTxs();
    _subscribeRewards();
  }

  Future<void> show(NotifObj notif) async {
    if (!isInBackground) return;

    int nativeId;
    if (_notifIds.contains(notif.uid)) {
      nativeId = _notifIds.indexOf(notif.uid);
    } else {
      _notifIds.add(notif.uid);
      nativeId = _notifIds.length - 1;
    }

    try {
      await chanell.invokeMethod<void>('show_notification', <String, dynamic>{
        'title': notif.title,
        'text': notif.text,
        'uid': nativeId,
      });
    } catch (e) {
      Log('notif_service', 'show] $e');
    }
  }

  void _subscribeRewards() {
    // TODO(yurii): implement after mm2 update
    jobService.install('checkRewards', 10, (j) async {
      // await MM.getRewardsInfo();
    });
  }

  Future<void> _subscribeTxs() async {
    jobService.install('checkTransactions', 10, (j) async {
      final List<CoinBalance> coins = coinsBloc.coinBalance;
      final List<Transaction> transactions = [];

      for (CoinBalance coin in coins) {
        // For ETH/ERC20 tokens we use komodo.live endpoint for txs history
        // Notifications for ETH/ERC20 txs are not available for now
        // https://github.com/ca333/komodoDEX/issues/872
        if (coin.coin.type == 'erc') continue;

        final String abbr = coin.coin.abbr;
        final String address = coin.balance.address;
        final dynamic res = await MM.getTransactions(
            mmSe.client,
            GetTxHistory(
              coin: abbr,
              limit: 5,
              fromId: null,
            ));
        if (!(res is Transactions)) continue;

        for (Transaction tx in res.result.transactions) {
          if (tx.to.contains(address)) {
            if (double.parse(tx.myBalanceChange) < 0) continue;
            transactions.add(tx);
          }
        }
      }

      _checkNewTransactions(transactions);
      _saveTransactions(transactions);
    });
  }

  void _checkNewTransactions(List<Transaction> transactions) {
    if (_transactions == null) return;

    for (Transaction tx in transactions) {
      if (_transactions.contains(tx.internalId)) continue;

      final double now = DateTime.now().millisecondsSinceEpoch / 1000;
      if (tx.timestamp > 0 && (now - tx.timestamp > 3600)) continue;

      show(NotifObj(
        // TODO(yurii): localization
        title: 'Incoming transaction',
        text: 'You have received ${tx.coin} transaction!',
        uid: tx.internalId,
      ));
    }
  }

  void _saveTransactions(List<Transaction> transactions) {
    _transactions ??= [];
    for (Transaction tx in transactions) {
      _transactions.add(tx.internalId);
    }
  }

  void _subscribeSwapStatus() {
    jobService.install('checkSwaps', 1, (j) async {
      _checkOrdersStatusChange(syncSwaps.swaps);
      _saveOrders(syncSwaps.swaps);
    });
  }

  void _checkOrdersStatusChange(Iterable<dynamic> swaps) {
    for (Swap swap in swaps) {
      final String uuid = swap.result?.uuid;
      if (uuid == null) return;

      String title;
      String text;

      if (_swaps.containsKey(uuid)) {
        if (_swaps[uuid]?.status == swap.status) return;

        switch (swap.status) {
          case Status.SWAP_SUCCESSFUL:
            {
              // TODO(yurii): localization
              title = 'Swap completed';
              text = '${swap.result.myInfo.myCoin}/'
                  '${swap.result.myInfo.otherCoin}'
                  ' swap was completed successfully';
              break;
            }
          case Status.SWAP_FAILED:
            {
              // TODO(yurii): localization
              title = 'Swap failed';
              text = '${swap.result.myInfo.myCoin}/'
                  '${swap.result.myInfo.otherCoin}'
                  ' swap failed';
              break;
            }
          case Status.TIME_OUT:
            {
              // TODO(yurii): localization
              title = 'Swap timed out';
              text = '${swap.result.myInfo.myCoin}/'
                  '${swap.result.myInfo.otherCoin}'
                  ' swap was timed out';
              break;
            }
          default:
            {
              // TODO(yurii): localization
              title = 'Swap status changed';
              text = '${swap.result.myInfo.myCoin}/'
                  '${swap.result.myInfo.otherCoin}'
                  ' ${_translateSwapStatus(swap.status)}';
              break;
            }
        }
      } else {
        switch (swap.status) {
          case Status.ORDER_MATCHED:
            {
              // TODO(yurii): localization
              title = 'New swap started';
              text = '${swap.result.myInfo.myCoin}/'
                  '${swap.result.myInfo.otherCoin}'
                  ' swap started';
              break;
            }
          default:
            {
              return;
            }
        }
      }

      show(NotifObj(
        title: title,
        text: text,
        uid: swap.result.uuid,
      ));
    }
  }

  void _saveOrders(Iterable<Swap> swaps) {
    for (Swap swap in swaps) {
      final String uuid = swap.result?.uuid;
      if (uuid == null) return;

      _swaps[uuid] = swap;
    }
  }

  String _translateSwapStatus(Status status) {
    switch (status) {
      case Status.ORDER_MATCHING:
        return _localizations.orderMatching;
        break;
      case Status.ORDER_MATCHED:
        return _localizations.orderMatched;
        break;
      case Status.SWAP_ONGOING:
        return _localizations.swapOngoing;
        break;
      case Status.SWAP_SUCCESSFUL:
        return _localizations.swapSucceful;
        break;
      case Status.TIME_OUT:
        return _localizations.timeOut;
        break;
      case Status.SWAP_FAILED:
        return _localizations.swapFailed;
        break;
      default:
    }
    return '';
  }
}

class NotifObj {
  NotifObj({
    this.title,
    this.text,
    this.uid,
  });

  String title;
  String text;
  String uid;
}
