import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';

import 'error_string.dart';
import 'get_recent_swap.dart';

class SwapProvider extends ChangeNotifier {
  SwapProvider() {
    syncSwaps.addProvider(this);
  }
  @override
  void dispose() {
    syncSwaps.unlinkProvider(this);
    super.dispose();
  }

  void notify() => notifyListeners();

  List<Swap> get swaps => syncSwaps.swaps;
  Swap swap(String uuid) => syncSwaps.swap(uuid);
}

SyncSwaps syncSwaps = SyncSwaps();

/// In ECS terms it is a System coordinating the swap information,
/// keeping in sync with MM and decentralized gossip.
class SyncSwaps {
  final Set<SwapProvider> _providers = {};
  //RecentSwaps _recentSwaps;
  List<Swap> _swaps = [];

  void addProvider(SwapProvider provider) {
    _providers.add(provider);
  }

  void unlinkProvider(SwapProvider provider) {
    _providers.remove(provider);
  }

  List<Swap> get swaps {
    return _swaps;
  }

  /// Fresh status of swap [uuid].
  /// cf. https://developers.komodoplatform.com/basic-docs/atomicdex/atomicdex-api.html#my-swap-status
  Swap swap(String uuid) {
    return _swaps.firstWhere((Swap swap) => swap.result.uuid == uuid, orElse: () => null);
  }

  void _notifyListeners() {
    for (SwapProvider provider in _providers) provider.notify();
  }

  Future<void> update(String reason) async {
    Log.println('swap_provider:60', 'update] reason $reason');

    final dynamic rswaps = await MM.getRecentSwaps(
        MMService().client, GetRecentSwap(limit: 50, fromUuid: null));

    if (rswaps is ErrorString) {
      Log.println('swap_provider:66', '!getRecentSwaps: ${rswaps.error}');
      return;
    }
    if (rswaps is! RecentSwaps) throw Exception('!RecentSwaps');

    final List<Swap> swaps = [];
    for (ResultSwap rrswap in rswaps.result.swaps) {
      final Status status = swapHistoryBloc.getStatusSwap(rrswap);
      swaps.add(Swap(result: rrswap, status: status));
    }

    //_recentSwaps = rswaps;
    _swaps = swaps;
    _notifyListeners();
  }
}
