import 'dart:async';

import 'package:flutter/services.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/services/mm_service.dart';

NotifService notifService = NotifService();

class NotifService {
  bool initialized = false;
  MethodChannel chanell = MMService.nativeC;
  bool isInBackground = false;

  AppLocalizations _localizations;
  final Map<String, Swap> _swaps = {};
  final List<String> _notifIds = [];

  Future<void> init(AppLocalizations localizations) async {
    if (initialized) return;
    initialized = true;

    while (!mmSe.running) {
      await Future<dynamic>.delayed(const Duration(milliseconds: 100));
    }

    _localizations = localizations;
    _subscribeSwapsStatus();
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

    await chanell.invokeMethod<void>('show_notification', <String, dynamic>{
      'title': notif.title,
      'text': notif.text,
      'uid': nativeId,
    });
  }

  void _subscribeSwapsStatus() {
    Timer.periodic(const Duration(milliseconds: 500), (_) {
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
              title = 'Swap completed';
              text = '${swap.result.myInfo.myCoin}/'
                  '${swap.result.myInfo.otherCoin}'
                  ' swap was completed successfully';
              break;
            }
          case Status.SWAP_FAILED:
            {
              title = 'Swap failed';
              text = '${swap.result.myInfo.myCoin}/'
                  '${swap.result.myInfo.otherCoin}'
                  ' swap failed';
              break;
            }
          case Status.TIME_OUT:
            {
              title = 'Swap timed out';
              text = '${swap.result.myInfo.myCoin}/'
                  '${swap.result.myInfo.otherCoin}'
                  ' swap was timed out';
              break;
            }
          default:
            {
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
