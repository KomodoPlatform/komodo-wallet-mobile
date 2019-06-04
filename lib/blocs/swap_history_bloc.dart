import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/uuid.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final swapHistoryBloc = SwapHistoryBloc();

class SwapHistoryBloc implements BlocBase {
  List<Swap> swaps = new List<Swap>();

  // Streams to handle the list coin
  StreamController<List<Swap>> _swapsController =
      StreamController<List<Swap>>.broadcast();
  Sink<List<Swap>> get _inSwaps => _swapsController.sink;
  Stream<List<Swap>> get outSwaps => _swapsController.stream;

  bool isAnimationStepFinalIsFinish = false;

  // Streams to handle the list coin
  StreamController<bool> _isAnimationStepFinalIsFinishController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsAnimationStepFinalIsFinish =>
      _isAnimationStepFinalIsFinishController.sink;
  Stream<bool> get outIsAnimationStepFinalIsFinish =>
      _isAnimationStepFinalIsFinishController.stream;

  bool isSwapsOnGoing = false;

  @override
  void dispose() {
    _swapsController.close();
    _isAnimationStepFinalIsFinishController.close();
  }

  void saveUUID(String uuid, Coin base, Coin rel, double amountToBuy,
      double amountToGet) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> uuids = prefs.getStringList('uuids');
    if (uuids == null) {
      uuids = new List<String>();
    }
    uuids.add(uuidToJson(Uuid(
        base: base,
        rel: rel,
        amountToBuy: amountToBuy,
        amountToGet: amountToGet,
        uuid: uuid,
        pubkey: mm2.pubkey,
        timeStart: DateTime.now().millisecondsSinceEpoch ~/ 1000)));
    await prefs.setStringList('uuids', uuids);
  }

  Future<void> updateSwap() async {
    print("UPDATE SWAPS");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> uuids = prefs.getStringList('uuids');
    List<Swap> swaps = new List<Swap>();

    // 0/3 - "Order matching" --> before Started
    // 1/3 - "Order matched" - matched (when entering swap loop) --> Started
    // 2/3 - "Swap ongoing" - takefee paid --> TakerFeeSent
    // 3/3 - "Swap successful" - makerpayment issued (or confirmed with 1 conf) --> MakerPaymentSpent

    isSwapsOnGoing = false;

    if (uuids != null) {
      for (var uuid in uuids) {
        Uuid uuidData = uuidFromJson(uuid);
        Status status = Status.ORDER_MATCHING;

        if (uuidData.pubkey == mm2.pubkey) {
          dynamic swap = await mm2.getSwapStatus(uuidData.uuid);
          uuidData.pubkey = mm2.pubkey;

          if (swap is Swap) {
            swap.status = getStatusSwap(swap);
            if (uuidData.timeStart + 3600 <
                    DateTime.now().millisecondsSinceEpoch ~/ 1000 &&
                swap.status != Status.SWAP_SUCCESSFUL) {
              swap.status = Status.TIME_OUT;
            }
            swap.uuid = uuidData;
            swaps.add(swap);
            if (swap.status == Status.ORDER_MATCHED ||
                swap.status == Status.ORDER_MATCHING ||
                swap.status == Status.SWAP_ONGOING) {
              isSwapsOnGoing = true;
            }
          } else if (swap is ErrorString) {
            if (uuidData.timeStart + 600 <
                DateTime.now().millisecondsSinceEpoch ~/ 1000) {
              status = Status.TIME_OUT;
            }
            swaps.add(Swap(
              status: status,
              result: Result(uuid: uuidData.uuid),
              uuid: uuidData,
            ));
          }
        }
      }
    }

    this.swaps = swaps;
    return _inSwaps.add(this.swaps);
  }

  Status getStatusSwap(Swap swap) {
    Status status = Status.ORDER_MATCHING;

    swap.result.events.forEach((event) {
      switch (event.event.type) {
        case "Started":
          status = Status.ORDER_MATCHED;
          break;
        case "TakerFeeSent":
          status = Status.SWAP_ONGOING;
          break;
        case "MakerPaymentSpent":
          status = Status.SWAP_SUCCESSFUL;
          break;
        default:
      }
    });

    return status;
  }

  String getSwapStatusString(BuildContext context, Status status) {
    switch (status) {
      case Status.ORDER_MATCHING:
        return AppLocalizations.of(context).orderMatching;
        break;
      case Status.ORDER_MATCHED:
        return AppLocalizations.of(context).orderMatched;
        break;
      case Status.SWAP_ONGOING:
        return AppLocalizations.of(context).swapOngoing;
        break;
      case Status.SWAP_SUCCESSFUL:
        return AppLocalizations.of(context).swapSucceful;
        break;
      case Status.TIME_OUT:
        return AppLocalizations.of(context).timeOut;
        break;
      default:
    }
    return "";
  }

  Color getColorStatus(Status status) {
    switch (status) {
      case Status.ORDER_MATCHING:
        return Colors.grey;
        break;
      case Status.ORDER_MATCHED:
        return Colors.yellowAccent.shade700.withOpacity(0.7);
        break;
      case Status.SWAP_ONGOING:
        return Colors.orangeAccent;
        break;
      case Status.SWAP_SUCCESSFUL:
        return Colors.green.shade500;
        break;
      case Status.TIME_OUT:
        return Colors.redAccent;
        break;
      default:
    }
    return Colors.redAccent;
  }

  String getStepStatus(Status status) {
    switch (status) {
      case Status.ORDER_MATCHING:
        return "0/3";
        break;
      case Status.ORDER_MATCHED:
        return "1/3";
        break;
      case Status.SWAP_ONGOING:
        return "2/3";
        break;
      case Status.SWAP_SUCCESSFUL:
        return "✓";
        break;
      case Status.TIME_OUT:
        return "";
        break;
      default:
    }
    return "";
  }

  int getStepStatusNumber(Status status) {
    switch (status) {
      case Status.ORDER_MATCHING:
        return 0;
        break;
      case Status.ORDER_MATCHED:
        return 1;
        break;
      case Status.SWAP_ONGOING:
        return 2;
        break;
      case Status.SWAP_SUCCESSFUL:
        return 3;
        break;
      case Status.TIME_OUT:
        return 0;
        break;
      default:
    }
    return 0;
  }

  double getNumberStep() {
    return 3;
  }
}
