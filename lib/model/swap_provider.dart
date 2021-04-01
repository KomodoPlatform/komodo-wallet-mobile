import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/get_recent_swap.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/utils.dart';

// TODO(AG): at "_goToNextScreen] swap started…" create a virtual
// swap that would allow the UI to better track
// them before they're "Started"

class SwapProvider extends ChangeNotifier {
  SwapProvider() {
    swapMonitor.linkProvider(this);
  }
  @override
  void dispose() {
    swapMonitor.unlinkProvider(this);
    super.dispose();
  }

  void notify() => notifyListeners();

  Iterable<Swap> get swaps => swapMonitor.swaps;
  Swap swap(String uuid) => swapMonitor.swap(uuid);

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
    final String makerCoin = swap?.makerCoin?.abbr,
        takerCoin = swap?.takerCoin?.abbr;
    final ens = swapMonitor._swapMetrics.values;
    for (SwapMetrics metrics in ens) {
      // Filter by coin pair and direction.
      if (makerCoin != null && makerCoin != metrics.makerCoin) continue;
      if (takerCoin != null && takerCoin != metrics.takerCoin) continue;

      for (String trans in metrics.stepSpeed.keys) {
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

  /// Based on the available metrics information
  /// tries to estimate the speed of transition [from]
  /// one step [to] another of a given [uuid] swap.
  /// Returns `null` if no estimate is currently available.
  StepSpeed stepSpeed(String uuid, String from, String to) {
    final Swap swap = this.swap(uuid);
    final String makerCoin = swap?.makerCoin?.abbr,
        takerCoin = swap?.takerCoin?.abbr;

    final String transition = '$from→$to';
    final List<double> values = [];
    final ens = swapMonitor._swapMetrics.values;
    for (SwapMetrics metrics in ens) {
      // Filter by coin pair and direction.
      if (makerCoin != null && makerCoin != metrics.makerCoin) continue;
      if (takerCoin != null && takerCoin != metrics.takerCoin) continue;

      final int speed = metrics.stepSpeed[transition];
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

SwapMonitor swapMonitor = SwapMonitor();

/// Maintains fresh swaps info from MM.
/// Collects swaps metrics in order to provide swaps stats,
/// such as estimated progress step speed, etc.
class SwapMonitor {
  SwapMonitor() {
    _loadPrefs();
  }

  SharedPreferences _prefs;

  /// [ChangeNotifier] proxies linked to this singleton.
  final Set<SwapProvider> _providers = {};

  /// Loaded from MM.
  Map<String, Swap> _swaps = {};

  /// SwapMetrics entities created from our swaps.
  final Map<String, SwapMetrics> _swapMetrics = {};

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
    final RecentSwaps rswaps =
        await MM.getRecentSwaps(GetRecentSwap(limit: 10000, fromUuid: null));

    final Map<String, Swap> swaps = {};
    for (MmSwap rswap in rswaps.result.swaps) {
      final String uuid = rswap.uuid;
      swaps[uuid] = Swap(result: rswap, status: rswap.status);
      _saveSwapMetrics(rswap);
    }

    _swaps = swaps;
    _notifyListeners();

    final List<Swap> swapList = List.from(swaps.values);
    swapList.sort((a, b) {
      if (b.result.myInfo.startedAt != null) {
        return b.result.myInfo.startedAt.compareTo(a.result.myInfo.startedAt);
      }
      return 0;
    });

    swapHistoryBloc.inSwaps.add(swapList);
  }

  /// Store swap information
  void _saveSwapMetrics(MmSwap mswap) {
    if (mswap.events.isEmpty) return;

    // See if we have already saved this version of the swap.
    final String id = SwapMetrics.swap2id(mswap);
    final int timestamp = mswap.events.last.timestamp;
    if (_swapMetrics[id]?.timestamp == timestamp) return;

    // Skip old swaps.
    final int now = DateTime.now().millisecondsSinceEpoch;
    if ((now - timestamp).abs() > 86400) return;

    final SwapMetrics metrics = SwapMetrics.from(timestamp, mswap);
    if (metrics.makerCoin == null) return; // No Start event.
    _swapMetrics[id] = metrics;
    _savePrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();

    final String encodedMetrics = _prefs.getString('swapMetrics');
    if (encodedMetrics == null) return;

    Map<String, dynamic> decodedMetrics;
    try {
      decodedMetrics = jsonDecode(encodedMetrics);
    } catch (e) {
      return;
    }

    decodedMetrics.forEach((id, dynamic item) {
      SwapMetrics fromJson;
      try {
        fromJson = SwapMetrics.fromJson(item);
      } catch (e) {
        return;
      }
      _swapMetrics[id] = fromJson;
    });
  }

  void _savePrefs() {
    if (_prefs == null) return;

    String encodedMetrics;
    try {
      encodedMetrics = jsonEncode(_swapMetrics);
    } catch (_) {
      return;
    }

    _prefs.setString('swapMetrics', encodedMetrics);
  }
}

class SwapMetrics {
  SwapMetrics.from(this.timestamp, MmSwap mswap) {
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
        taker = data.taker.isNotEmpty ? data.taker : null;
        maker = data.maker.isNotEmpty ? data.maker : null;
      }
    }
  }

  /// Load back from prefs.
  SwapMetrics.fromJson(Map<String, dynamic> en) {
    id = en['id'];
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

  /// SwapMetrics entity ID: “${swap_uuid}/${type}”, where $type is “t” for Taker and “m” for Maker
  String id;

  /// Ticker of maker coin
  String makerCoin;

  /// Ticker of taker coin
  String takerCoin;

  /// Time of last swap event, in milliseconds since UNIX epoch
  int timestamp;

  /// Time between swap states in milliseconds
  LinkedHashMap<String, int> stepSpeed = LinkedHashMap<String, int>.of({});

  /// Name and version of UI
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

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json;
    try {
      json = <String, dynamic>{
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
    } catch (_) {}

    return json;
  }
}
