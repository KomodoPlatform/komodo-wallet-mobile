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
    final Swap swap = this.swap(uuid);
    if (swap == null) return '';
    final ResultSwap rswap = swap.result;
    if (rswap == null) return '';
    if (rswap.events.isEmpty) return '';
    final bool finished = rswap.events.last.event.type == 'Finished';
    // Event before 'Finished'.
    final EventEvent ev = rswap.events.reversed
        .map((ev) => ev.event)
        .firstWhere((ev) => ev.type != 'Finished');
    if (ev == null) return '';

    // Whether the swap is a successfull one (so far).
    final bool succ = rswap.successEvents.contains(ev.type);

    final StringBuffer text = StringBuffer();
    if (succ) {
      if (!finished) _transitions(text, ev);
    } else {
      _failEv(text, ev);
    }
    return text.toString();
  }

  void _failEv(StringBuffer text, EventEvent ev) {
    text.writeln('Failure ${ev.type}');
    if (ev.data.error.isNotEmpty) {
      text.writeln('--- raw error message ---');
      text.writeln(ev.data.error);
    }
  }

  /// If we've seen different states reached from the current one then share these observations.
  void _transitions(StringBuffer text, EventEvent ev) {
    final Map<String, int> knownTransitions = {};
    final String pref = ev.type + '→';
    // TBD: Should probably filter by (sorted) koin pair.
    for (SwapGossip gossip in syncSwaps._ours.values) {
      for (String trans in gossip.stepSpeed.keys) {
        if (trans.startsWith(pref)) {
          final String to = trans.substring(pref.length);
          knownTransitions[to] = knownTransitions[to] ?? 0 + 1;
        }
      }
    }
    if (knownTransitions.length > 1) {
      text.writeln('Next step was');
      for (String trans in knownTransitions.keys) {
        final int count = knownTransitions[trans];
        text.writeln(' $trans for $count swaps');
      }
    }
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
    if (uuid == null) return null;
    return _swaps[uuid];
  }

  void _notifyListeners() {
    for (SwapProvider provider in _providers) provider.notify();
  }

  /// (Re)load recent swaps from MM.
  Future<void> update(String reason) async {
    Log('swap_provider:134', 'update] reason $reason');

    final dynamic rswaps = await MM.getRecentSwaps(
        mmSe.client, GetRecentSwap(limit: 50, fromUuid: null));

    if (rswaps is ErrorString) {
      Log('swap_provider:140', '!getRecentSwaps: ${rswaps.error}');
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

    Log('swap_provider:166', 'gossiping of $uuid; $timestamp');
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
        Log('swap_provider:181', 'Negative delta ($evaT→$adamT): $delta');
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
