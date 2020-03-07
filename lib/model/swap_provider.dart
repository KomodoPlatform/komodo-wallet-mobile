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
    syncSwaps.linkProvider(this);
  }
  @override
  void dispose() {
    syncSwaps.unlinkProvider(this);
    super.dispose();
  }

  void notify() => notifyListeners();

  Iterable<Swap> get swaps => syncSwaps.swaps;
  Swap swap(String uuid) => syncSwaps.swap(uuid);

  String swapDescription(String uuid) {
    return ''
        ' + --- Wake up, Neo... --- +\n'
        ' | Matrix has you...       |\n'
        ' | 👁️👁️                   |';
  }

  SwapStepData swapStepData(
      {String uuid, String prevEventType, String nextEventType}) {
    return SwapStepData(estimatedStepSpeed: 71 * 1000);
  }
}

class SwapStepData {
  SwapStepData({this.estimatedStepSpeed});
  int estimatedStepSpeed;
}

SyncSwaps syncSwaps = SyncSwaps();

/// In ECS terms it is a System coordinating the swap information,
/// keeping in sync with MM and decentralized gossip.
class SyncSwaps {
  /// [ChangeNotifier] proxies linked to this singleton.
  final Set<SwapProvider> _providers = {};

  /// Loaded from MM.
  Map<String, Swap> _swaps = {};

  /// Maps swap UUIDs to gossip entities created from our swaps.
  final Map<String, SwapGossip> _ours = {};

  /// Link a [ChangeNotifier] proxy to this singleton.
  void linkProvider(SwapProvider provider) {
    _providers.add(provider);
  }

  /// Unlink a [ChangeNotifier] proxy from this singleton.
  void unlinkProvider(SwapProvider provider) {
    _providers.remove(provider);
  }

  Iterable<Swap> get swaps {
    return _swaps.values;
  }

  /// Fresh status of swap [uuid].
  /// cf. https://developers.komodoplatform.com/basic-docs/atomicdex/atomicdex-api.html#my-swap-status
  Swap swap(String uuid) {
    return _swaps[uuid];
  }

  void _notifyListeners() {
    for (SwapProvider provider in _providers) provider.notify();
  }

  /// (Re)load recent swaps from MM.
  Future<void> update(String reason) async {
    Log('swap_provider:85', 'update] reason $reason');

    final dynamic rswaps = await MM.getRecentSwaps(
        mmSe.client, GetRecentSwap(limit: 50, fromUuid: null));

    if (rswaps is ErrorString) {
      Log('swap_provider:91', '!getRecentSwaps: ${rswaps.error}');
      return;
    }
    if (rswaps is! RecentSwaps) throw Exception('!RecentSwaps');

    final Map<String, Swap> swaps = {};
    for (ResultSwap rswap in rswaps.result.swaps) {
      final Status status = swapHistoryBloc.getStatusSwap(rswap);
      final String uuid = rswap.uuid;
      swaps[uuid] = Swap(result: rswap, status: status);
      _gossip(rswap);
    }

    _swaps = swaps;
    _notifyListeners();
    swapHistoryBloc.inSwaps.add(swaps.values);
  }

  /// Share swap information on dexp2p.
  void _gossip(ResultSwap rswap) {
    // See if we have already gossiped about this version of the swap.
    if (rswap.events.isEmpty) return;
    final String uuid = rswap.uuid;
    final int timestamp = rswap.events.last.timestamp;
    if (_ours[uuid]?.timestamp == timestamp) return;

    Log('swap_provider:117', 'gossiping of $uuid; $timestamp');
    final SwapGossip gossip = SwapGossip.from(timestamp, rswap);
    _ours[uuid] = gossip;
  }
}

class SwapGossip {
  SwapGossip.from(this.timestamp, ResultSwap rswap) {
    for (int ix = 0; ix < rswap.events.length - 1; ++ix) {
      final EventElement eva = rswap.events[ix];
      final EventElement adam = rswap.events[ix + 1];
      final String evaT = eva.event.type;
      final String adamT = adam.event.type;
      final int delta = adam.timestamp - eva.timestamp;
      if (delta < 0) {
        Log('swap_provider:132', 'Negative delta ($evaT→$adamT): $delta');
        continue;
      }
      stepSpeed['$evaT→$adamT'] = delta;
    }
  }

  /// Time of last swap event, in milliseconds since UNIX epoch.
  int timestamp;

  /// Time between swap states in milliseconds.
  Map<String, int> stepSpeed = {};
}
