import 'dart:async';

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

  @override
  void dispose() {
    _swapsController.close();
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> uuids = prefs.getStringList('uuids');
    List<Swap> swaps = new List<Swap>();

    // 0/3 - "Order matching" --> before Started
    // 1/3 - "Order matched" - matched (when entering swap loop) --> Started
    // 2/3 - "Swap ongoing" - takefee paid --> TakerFeeSent
    // 3/3 - "Swap successful" - makerpayment issued (or confirmed with 1 conf) --> MakerPaymentSpent

    print("TIMESTAMP" + new DateTime.now().millisecondsSinceEpoch.toString());

    if (uuids != null) {
      for (var uuid in uuids) {
        Uuid uuidData = uuidFromJson(uuid);
        Status status = Status.ORDER_MATCHING;

        if (uuidData.pubkey == mm2.pubkey) {
          dynamic swap = await mm2.getSwapStatus(uuidData.uuid);
          uuidData.pubkey = mm2.pubkey;

          if (swap is Swap) {
            swap.status = getStatusSwap(swap);
            if (uuidData.timeStart + 600 <
              DateTime.now().millisecondsSinceEpoch ~/ 1000 && swap.status != Status.SWAP_SUCCESSFUL) {
              swap.status = Status.TIME_OUT;
            }
            swap.uuid = uuidData;
            swaps.add(swap);
          } else if (swap is ErrorString) {
            if (uuidData.timeStart + 120 <
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
}
