import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/swap.dart';

class SwapProvider extends ChangeNotifier {
  SwapProvider() {
    swapHistoryBloc.outSwaps.listen(_updateLocalSwapsData);
  }

  List<Swap> _swaps = [];

  List<Swap> getSwaps() {
    return _swaps;
  }

  Swap getSwap(String swapUuid) {
    return _swaps.firstWhere((Swap swap) => swap.result.uuid == swapUuid);
  }

  void _updateLocalSwapsData(List<Swap> newData) {
    _swaps = newData;
    notifyListeners();
  } 
}
