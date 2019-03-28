import 'dart:async';

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

  void saveUUID(String uuid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> uuids = prefs.getStringList('uuids');
    if (uuids == null) {
      uuids = new List<String>();
    }
    uuids.add(uuidToJson(Uuid(uuid: uuid, pubkey: mm2.pubkey)));
    await prefs.setStringList('uuids', uuids);
  }

  void updateSwap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> uuids = prefs.getStringList('uuids');
    List<Swap> swaps = new List<Swap>();

    // 0/3 - "Order matching" --> before Started
    // 1/3 - "Order matched" - matched (when entering swap loop) --> Started
    // 2/3 - "Swap ongoing" - takefee paid --> TakerFeeSent
    // 3/3 - "Swap successful" - makerpayment issued (or confirmed with 1 conf) --> MakerPaymentSpent

    if (uuids != null) {
      for (var uuid in uuids) {
        print("PUBKEY: " + uuidFromJson(uuid).pubkey);
        if (uuidFromJson(uuid).pubkey == mm2.pubkey) {
          dynamic swap = await mm2.getSwapStatus(uuidFromJson(uuid).uuid);

          print("IF IS SWAP: " + (swap is Swap).toString());
          if (swap is Swap) {
            swap.status = getStatusSwap(swap);
            swap.pubkey = mm2.pubkey;
            swaps.add(swap);
          } else if (swap is ErrorString) {
            swaps.add(Swap(
                pubkey: mm2.pubkey,
                status: Status.ORDER_MATCHING,
                result: Result(uuid: uuidFromJson(uuid).uuid)));
          }
        }
      }
    }

    this.swaps = swaps;
    _inSwaps.add(this.swaps);
  }

  Status getStatusSwap(Swap swap) {
    Status status = Status.ORDER_MATCHING;

    swap.result.events.forEach((event){
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
