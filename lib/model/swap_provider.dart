import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';

import 'get_recent_swap.dart';
import 'recent_swaps.dart';
import 'swap.dart';

// TODO(AG): at "_goToNextScreen] swap started…" create a virtual
// swap that would allow the UI to better track
// them before they're "Started"

/// “${swap_uuid}/${type}”, where $type is “t” for Taker and “m” for Maker.
/// For example: “8f2464eb-4a1c-4d2e-b6e4-26b1de99ca8c/t”.
/// xxxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx, cf. https://en.wikipedia.org/wiki/Universally_unique_identifier#Format
final _idExp = RegExp(
    r'^([0-9a-f]{8})-([0-9a-f]{4})-(\d)([0-9a-f]{3})-([0-9a-f]{4})-([0-9a-f]{12})/(t|m)$');

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

  bool notarizationAvailable(Coin coin) {
    return coin.requiresNotarization != null;
  }

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
      if (!finished) _transitions(text, swap, ev);
    } else {
      _failEv(text, rswap);
    }
    return text.toString();
  }

  void _failEv(StringBuffer text, MmSwap rswap) {
    final SwapEL deviation = rswap.events.firstWhere(
        (SwapEL ev) => !rswap.successEvents.contains(ev.event.type));
    if (deviation == null) return;
    text.writeln('Failure ${deviation.event.type}');
    if (deviation.event.data.error.isNotEmpty) {
      text.writeln('--- raw error message ---');
      text.writeln(deviation.event.data.error);
    }
  }

  /// If we've seen different states reached from the current one then share these observations.
  void _transitions(StringBuffer text, Swap swap, SwapEEL ev) {
    final Map<String, int> knownTransitions = {};
    final String pref = ev.type + '→';
    final String makerCoin = swap?.makerCoin, takerCoin = swap?.takerCoin;
    final ens = syncSwaps._ours.values.followedBy(syncSwaps._theirs.values);
    for (SwapGossip gossip in ens) {
      // Filter by coin pair and direction.
      if (makerCoin != null && makerCoin != gossip.makerCoin) continue;
      if (takerCoin != null && takerCoin != gossip.takerCoin) continue;

      for (String trans in gossip.stepSpeed.keys) {
        if (trans.startsWith(pref)) {
          final String to = trans.substring(pref.length);
          knownTransitions[to] = (knownTransitions[to] ?? 0) + 1;
        }
      }
    }
    if (knownTransitions.length > 1) {
      text.writeln('Next step was');
      final int total = knownTransitions.values.reduce((a, b) => a + b);
      for (String trans in knownTransitions.keys) {
        final int count = knownTransitions[trans];
        text.writeln(' $trans: $count/$total');
      }
    }
  }

  /// Based on the available gossip information
  /// tries to estimate the speed of transition [from] one [to] another steps of a given [uuid] swap.
  /// Returns `null` if no estimate is currently available.
  StepSpeed stepSpeed(String uuid, String from, String to) {
    final Swap swap = this.swap(uuid);
    final String makerCoin = swap?.makerCoin, takerCoin = swap?.takerCoin;

    final String transition = '$from→$to';
    final List<double> values = [];
    final ens = syncSwaps._ours.values.followedBy(syncSwaps._theirs.values);
    for (SwapGossip gossip in ens) {
      // Filter by coin pair and direction.
      if (makerCoin != null && makerCoin != gossip.makerCoin) continue;
      if (takerCoin != null && takerCoin != gossip.takerCoin) continue;

      final int speed = gossip.stepSpeed[transition];
      if (speed == null) continue;
      values.add(speed.toDouble());
    }
    if (values.isEmpty) return null;
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

  /// Gossip entities created from our swaps.
  final Map<String, SwapGossip> _ours = {};

  /// Gossiped timestamps.
  /// If timestamp differs then we haven't shared that version of gossip yet.
  final Map<String, int> _gossiped = {};

  /// Gossip obtained from a caretaker.
  /// The keys are entity IDs: “${swap_uuid}/${type}”, where $type is “t” for Taker and “m” for Maker.
  final Map<String, SwapGossip> _theirs = {};

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
  Future<void> update() async {
    Log('swap_provider:188', 'update]');

    final RecentSwaps rswaps =
        await MM.getRecentSwaps(GetRecentSwap(limit: 50, fromUuid: null));

    final Map<String, Swap> swaps = {};
    for (MmSwap rswap in rswaps.result.swaps) {
      final String uuid = rswap.uuid;
      swaps[uuid] = Swap(result: rswap, status: rswap.status);
      _gossip(rswap);
    }

    _swaps = swaps;
    _notifyListeners();
    swapHistoryBloc.inSwaps.add(swaps.values);

    try {
      await _gossipSync();
    } catch (ex) {
      Log('swap_provider:207', '!_gossipSync: $ex');
    }
  }

  /// Share swap information on dexp2p.
  void _gossip(MmSwap mswap) {
    if (mswap.events.isEmpty) return;

    // See if we have already gossiped about this version of the swap.
    final String id = SwapGossip.swap2id(mswap);
    final int timestamp = mswap.events.last.timestamp;
    if (_ours[id]?.timestamp == timestamp) return;

    // Skip old swaps.
    final int now = DateTime.now().millisecondsSinceEpoch;
    if ((now - timestamp).abs() > 86400) return;

    final SwapGossip gossip = SwapGossip.from(timestamp, mswap);
    if (gossip.makerCoin == null) return; // No Start event.
    _ours[id] = gossip;
  }

  Future<void> _gossipSync() async {
    // Exploratory.

    final List<SwapGossip> entities = [];
    for (String id in _ours.keys) {
      final entity = _ours[id];
      if (entity.timestamp == _gossiped[id]) continue;
      Log('swap_provider:236', 'Gossiping $id…');
      entities.add(entity);
    }

    final List<String> tickers = (await Db.activeCoins).toList();

    final bstart = DateTime.now().millisecondsSinceEpoch;
    final blen = _theirs.length * 3 ~/ 32 + 1;
    final bloom = List<int>.filled(blen, 0, growable: false);
    for (final id in _theirs.keys) {
      final mat = _idExp.firstMatch(id);
      final mt = mat.group(7) == 'm' ? 1 : 0;
      for (int group in [1, 2, 5]) {
        final iv = hex2int(mat.group(group)) + mt;
        final bucket = iv % bloom.length;
        final bit = iv % 64;
        bloom[bucket] |= 1 << bit;
      }
    }
    final bsec = (DateTime.now().millisecondsSinceEpoch - bstart) / 1000.0;
    double bpe = blen * 64 / _theirs.length; // Bits per element.
    bpe = double.parse(bpe.toStringAsFixed(1));
    Log('swap_provider:258', 'Bloom $bloom (${_theirs.length}, $bpe) in $bsec');

    //Log('swap_provider:260', 'ct.cipig.net/sync…');
    final pr = await mmSe.client.post('http://ct.cipig.net/sync',
        body: json.encode(<String, dynamic>{
          'components': <String, dynamic>{
            'swap-events.1': <String, dynamic>{
              // Coins we're currently interested in (e.g. activated).
              'tickers': tickers,
              // Bloom filter allows us to skip receiving old known entities.
              'bloom': bloom,
              // Gossip entities we share with the network.
              'ours': entities.map((e) => e.toJson).toList()
            },
            'metrics.1': <String, dynamic>{
              'pk': mmSe.pubkey,
              'gui': mmSe.gui,
              'mm_version': mmSe.mmVersion,
              'mm_date': mmSe.mmDate,
              'footprint': mmSe.footprint,
              'rs': mmSe.rs,
              'files': mmSe.files,
              'lm': mmSe.metricsLM != null ? mmSe.metricsLM ~/ 1000 : null,
              'now': DateTime.now().millisecondsSinceEpoch ~/ 1000
            }
          }
        }));
    if (pr.statusCode != 200) throw Exception('HTTP ${pr.statusCode}');
    for (SwapGossip en in entities) _gossiped[en.id] = en.timestamp;

    final ct = pr.headers['content-type'] ?? '';
    if (ct != 'application/json') throw Exception('HTTP Content-Type $ct');
    // NB: `http` fails to recognize that 'application/json' is UTF-8 by default.
    final body = const Utf8Decoder().convert(pr.bodyBytes);
    final Map<String, dynamic> js = json.decode(body);
    final Map<String, dynamic> components = js['components'];
    if (components == null || !components.containsKey('swap-events.1')) return;
    final List<dynamic> re = components['swap-events.1']['entities'];
    for (Map<String, dynamic> en in re) {
      final SwapGossip gen = SwapGossip.fromJson(en);
      _theirs[gen.id] = gen;
    }
  }
}

class SwapGossip {
  SwapGossip.from(this.timestamp, MmSwap mswap) {
    id = swap2id(mswap);
    gui = mswap.gui;
    mmVersion = mswap.mmVersion;
    assert(mmVersion == mmSe.mmVersion);
    mmDate = mmSe.mmDate;

    for (int ix = 0; ix < mswap.events.length - 1; ++ix) {
      final SwapEL eva = mswap.events[ix];
      final SwapEL adam = mswap.events[ix + 1];
      final String evaT = eva.event.type;
      final String adamT = adam.event.type;
      final int delta = adam.timestamp - eva.timestamp;
      if (delta < 0) {
        Log('swap_provider:318', 'Negative delta ($evaT→$adamT): $delta');
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
        myPersistentPub = data.myPersistentPub;
        assert(myPersistentPub.endsWith(mmSe.pubkey));
        taker = data.taker.isNotEmpty ? data.taker : null;
        maker = data.maker.isNotEmpty ? data.maker : null;
      }
    }
  }

  /// Load back from caretaker.
  SwapGossip.fromJson(Map<String, dynamic> en) {
    id = en['id'];
    if (!_idExp.hasMatch(id)) throw Exception('Bad id: $id');
    gui = en['gui'];
    mmVersion = en['mm_version'];
    mmDate = en['mm_date'];
    stepSpeed = LinkedHashMap<String, int>.from(en['step_speed']);
    makerCoin = en['maker_coin'];
    takerCoin = en['taker_coin'];
    makerPaymentConfirmations = en['maker_payment_confirmations'];
    takerPaymentConfirmations = en['taker_payment_confirmations'];
    final dynamic mrn = en['maker_payment_requires_nota'];
    makerPaymentRequiresNota = mrn == 1 || mrn == 0 ? false : null;
    final dynamic trn = en['taker_payment_requires_nota'];
    takerPaymentRequiresNota = trn == 1 || trn == 0 ? false : null;
    myPersistentPub = en['my_persistent_pub'];
    taker = en['taker'];
    maker = en['maker'];
  }

  static String swap2id(MmSwap mswap) =>
      mswap.uuid + '/' + (mswap.type == 'Taker' ? 't' : 'm');

  /// Gossip entity ID: “${swap_uuid}/${type}”, where $type is “t” for Taker and “m” for Maker
  String id;

  /// Ticker of maker coin
  String makerCoin;

  /// Ticker of taker coin
  String takerCoin;

  /// Time of last swap event, in milliseconds since UNIX epoch
  int timestamp;

  /// Time between swap states in milliseconds
  LinkedHashMap<String, int> stepSpeed = LinkedHashMap<String, int>.of({});

  /// Name and version of UI that has shared this gossip entity
  String gui;

  /// MM commit hash
  String mmVersion;

  // The date corresponding to the MM commit hash, YYYY-MM-DD
  String mmDate;

  // NB: These options only represent one side of the story
  // (the Taker settings for Taker swaps, the Maker settings for Maker swaps)
  int makerPaymentConfirmations, takerPaymentConfirmations;
  bool makerPaymentRequiresNota, takerPaymentRequiresNota;

  String myPersistentPub;

  /// On tracking concerns:
  /// https://gitlab.com/artemciy/mm-pubsub-db/-/blob/2342fa23/373-p2p-order-matching.md#L115
  String taker, maker;

  Map<String, dynamic> get toJson => <String, dynamic>{
        'id': id,
        'maker_coin': makerCoin,
        'taker_coin': takerCoin,
        'timestamp': timestamp,
        'step_speed': stepSpeed,
        'gui': gui,
        'mm_version': mmVersion,
        'mm_date': mmDate,
        'maker_payment_confirmations': makerPaymentConfirmations,
        'taker_payment_confirmations': takerPaymentConfirmations,
        'maker_payment_requires_nota': makerPaymentRequiresNota,
        'taker_payment_requires_nota': takerPaymentRequiresNota,
        'my_persistent_pub': myPersistentPub,
        'taker': taker,
        'maker': maker
      };
}
