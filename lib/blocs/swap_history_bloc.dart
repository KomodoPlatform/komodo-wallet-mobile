import 'dart:async';

import 'package:komodo_dex/blocs/coins_bloc.dart';
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

  Stream<List<Swap>> get outSwaps =>
      _swapsController.stream;

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

  void updateSwap() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> uuids = prefs.getStringList('uuids');
    List<Swap> swaps = new List<Swap>();

    if (uuids != null) {
      print("LENGHT" + uuids.length.toString());

      for (var uuid in uuids) {
        dynamic swap = await mm2.getSwapStatus(uuid);

        if (swap is Swap) {
          swap.pubkey = mm2.pubkey;
          swaps.add(swap);
        } else if (swap is ErrorString) {
          swaps.add(Swap(pubkey: mm2.pubkey, status: Status.ORDER_MATCHING, result: Result(uuid: uuid)));
        }
      }
    }

    this.swaps = swaps;
    _inSwaps.add(this.swaps);
  }

}