import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';

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
    final MmSwap rswap = swap.result;
    if (rswap == null) return '';
    if (rswap.events.isEmpty) return '';
    final bool finished = rswap.events.last.event.type == 'Finished';
    // Event before 'Finished'.
    final SwapEEL ev = rswap.events.reversed
        .map((ev) => ev.event)
        .firstWhere((ev) => ev.type != 'Finished');
    if (ev == null) return '';

    // Whether the swap is a successful one (so far).
    final bool succ = rswap.successEvents.contains(ev.type);

    final StringBuffer text = StringBuffer();
    if (succ) {
      if (!finished) _transitions(text, ev);
    } else {
      _failEv(text, ev);
    }
    return text.toString();
  }

  void _failEv(StringBuffer text, SwapEEL ev) {
    text.writeln('Failure ${ev.type}');
    if (ev.data.error.isNotEmpty) {
      text.writeln('--- raw error message ---');
      text.writeln(ev.data.error);
    }
  }

  /// If we've seen different states reached from the current one then share these observations.
  void _transitions(StringBuffer text, SwapEEL ev) {
    final Map<String, int> knownTransitions = {};
    final String pref = ev.type + '→';
    // TBD: Should probably filter by (sorted) coin pair.
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

  /// Based on the available gossip information
  /// tries to estimate the speed of transition [from] one [to] another steps of a given [uuid] swap.
  /// Returns `null` if no estimate is currently available.
  StepSpeed stepSpeed(String uuid, String from, String to) {
    final String transition = '$from→$to';
    int count = 0;
    final List<double> values = [];
    // TBD: Should probably filter by (sorted) coin pair.
    for (SwapGossip gossip in syncSwaps._ours.values) {
      final int speed = gossip.stepSpeed[transition];
      if (speed == null) continue;
      values.add(speed.toDouble());
      count += 1;
    }
    if (count == 0) return null;
    final int speed = mean(values).round();
    final int dev = deviation(values).round();
    return StepSpeed(speed: speed, deviation: dev);
  }
}

class StepSpeed {
  StepSpeed({this.speed, this.deviation});

  /// Speed estimate of step transition, in milliseconds.
  int speed;
  int deviation;
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

  final Set<String> _gossiped = {};

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
    Log('swap_provider:157', 'update] reason $reason');

    final dynamic mswaps = await MM.getRecentSwaps(
        mmSe.client, GetRecentSwap(limit: 50, fromUuid: null));

    if (mswaps is ErrorString) {
      Log('swap_provider:163', '!getRecentSwaps: ${mswaps.error}');
      return;
    }
    if (mswaps is! RecentSwaps) throw Exception('!RecentSwaps');

    final Map<String, Swap> swaps = {};
    for (MmSwap rswap in mswaps.result.swaps) {
      final Status status = swapHistoryBloc.getStatusSwap(rswap);
      final String uuid = rswap.uuid;
      swaps[uuid] = Swap(result: rswap, status: status);
      _gossip(rswap);
    }

    _swaps = swaps;
    _notifyListeners();
    swapHistoryBloc.inSwaps.add(swaps.values);

    try {
      await _gossipSync();
    } catch (ex) {
      Log('swap_provider:183', '!_gossipSync: $ex');
    }
  }

  /// Share swap information on dexp2p.
  void _gossip(MmSwap mswap) {
    if (mswap.events.isEmpty) return;

    // See if we have already gossiped about this version of the swap.
    final String uuid = mswap.uuid;
    final int timestamp = mswap.events.last.timestamp;
    if (_ours[uuid]?.timestamp == timestamp) return;

    // Skip old swaps.
    final int now = DateTime.now().millisecondsSinceEpoch;
    if ((now - timestamp).abs() > 3600) return;

    final SwapGossip gossip = SwapGossip.from(timestamp, mswap);
    if (gossip.makerCoin == null) return; // No Start event.
    _ours[uuid] = gossip;
  }

  Future<void> _gossipSync() async {
    // Exploratory.

    final List<SwapGossip> entities = [];
    for (String uuid in _ours.keys) {
      if (_gossiped.contains(uuid)) continue;
      entities.add(_ours[uuid]);
    }
    if (entities.isEmpty) return;

    final pr = await mmSe.client.post('http://ct.cipig.net/sync',
        body: json.encode(<String, dynamic>{
          'components': <String, dynamic>{
            'swap-events.1': <String, dynamic>{
              // Coins we're currently interested in (e.g. activated).
              'tickers': ['RICK', 'MORTY'],
              // Gossip entities we share with the network.
              'ours': entities.map((e) => e.toJson).toList()
            }
          }
        }));
    if (pr.statusCode != 200) throw Exception('HTTP ${pr.statusCode}');

    for (SwapGossip entity in entities) _gossiped.add(entity.uuid);
  }
}

class SwapGossip {
  SwapGossip.from(this.timestamp, MmSwap mswap) {
    uuid = mswap.uuid;
    gui = mswap.gui;
    mmMersion = mswap.mmMersion;

    for (int ix = 0; ix < mswap.events.length - 1; ++ix) {
      final SwapEL eva = mswap.events[ix];
      final SwapEL adam = mswap.events[ix + 1];
      final String evaT = eva.event.type;
      final String adamT = adam.event.type;
      final int delta = adam.timestamp - eva.timestamp;
      if (delta < 0) {
        Log('swap_provider:245', 'Negative delta ($evaT→$adamT): $delta');
        continue;
      }
      stepSpeed['$evaT→$adamT'] = delta;

      if (evaT == 'Started') {
        final SwapEF data = eva.event.data;
        makerCoin = data.makerCoin;
        takerCoin = data.takerCoin;
        makerPaymentConfirmations = data.makerPaymentConfirmations;
        takerPaymentConfirmations = data.takerPaymentConfirmations;
        makerPaymentRequiresNota = data.makerPaymentRequiresNota;
        takerPaymentRequiresNota = data.takerPaymentRequiresNota;
      }
    }
  }

  /// Swap ID. Gossip entity ID.
  String uuid;

  /// Ticker of maker coin.
  String makerCoin;

  /// Ticker of taker coin.
  String takerCoin;

  /// Time of last swap event, in milliseconds since UNIX epoch.
  int timestamp;

  /// Time between swap states in milliseconds.
  Map<String, int> stepSpeed = {};

  /// Name and version of UI that has shared this gossip entity.
  String gui;

  /// Commit version of MM.
  String mmMersion;

  int makerPaymentConfirmations, takerPaymentConfirmations;
  bool makerPaymentRequiresNota, takerPaymentRequiresNota;

  Map<String, dynamic> get toJson => <String, dynamic>{
        'uuid': uuid,
        'maker_coin': makerCoin,
        'taker_coin': takerCoin,
        'timestamp': timestamp,
        'step_speed': stepSpeed,
        'gui': gui,
        'mm_version': mmMersion,
        'maker_payment_confirmations': makerPaymentConfirmations,
        'taker_payment_confirmations': takerPaymentConfirmations,
        'maker_payment_requires_nota': makerPaymentRequiresNota,
        'taker_payment_requires_nota': takerPaymentRequiresNota
      };
}
