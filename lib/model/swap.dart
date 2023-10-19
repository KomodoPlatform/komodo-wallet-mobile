// To parse this JSON data, do
//
//     final swap = swapFromJson(jsonString);

import 'dart:convert';

import '../blocs/coins_bloc.dart';
import '../model/coin.dart';
import '../model/order.dart';
import '../model/recent_swaps.dart';
import '../utils/utils.dart';

enum Status {
  ORDER_MATCHING,
  ORDER_MATCHED,
  SWAP_ONGOING,
  SWAP_SUCCESSFUL,
  SWAP_FAILED,
  TIME_OUT
}

Swap swapFromJson(String str) {
  final dynamic jsonData = json.decode(str);
  return Swap.fromJson(jsonData);
}

class Swap {
  Swap({
    this.result,
    this.status,
  });

  factory Swap.fromJson(Map<String, dynamic> json) => Swap(
        result: MmSwap.fromJson(json['result']) ?? MmSwap(),
      );

  MmSwap result;
  Status status;

  Map<String, dynamic> get toJson => <String, dynamic>{
        'result': result.toJson() ?? MmSwap().toJson,
      };

  int compareToSwap(Swap other) {
    int order = 0;

    order = extractStartedAtFromSwap(other.result)
        .compareTo(extractStartedAtFromSwap(result));
    if (order == 0)
      order = extractStartedAtFromSwap(result)
          .compareTo(extractStartedAtFromSwap(other.result));

    return order;
  }

  int compareToOrder(Order other) {
    int order = 0;
    order = other.createdAt.compareTo(extractStartedAtFromSwap(result));
    if (order == 0)
      order = extractStartedAtFromSwap(result).compareTo(other.createdAt);

    return order;
  }

  /// Total number of expected simplyfied swap steps,
  /// based on swap status changes.
  int get statusSteps => 3;

  /// Number of current status-based swap step.
  int get statusStep {
    switch (status) {
      case Status.ORDER_MATCHING:
        return 0;
        break;
      case Status.ORDER_MATCHED:
        return 1;
        break;
      case Status.SWAP_ONGOING:
        return 2;
        break;
      case Status.SWAP_SUCCESSFUL:
        return 3;
        break;
      case Status.TIME_OUT:
        return 0;
        break;
      case Status.SWAP_FAILED:
        return 0;
        break;
      default:
    }
    return 0;
  }

  /// Total number of detailed successful steps in the swap.
  int get steps => result?.successEvents?.length ?? statusSteps;

  /// If user acts as a Taker during current
  /// swap then returns [true], [false] otherwise.
  bool get isTaker {
    if (result.type == 'Taker') return true;
    return false;
  }

  /// If user acts as a Maker during current
  /// swap then returns [true], [false] otherwise.
  bool get isMaker {
    if (result.type == 'Maker') return true;
    return false;
  }

  bool get doWeNeed0xPrefixForMaker {
    if (makerCoin.swapContractAddress.startsWith('0x')) return true;
    return false;
  }

  bool get doWeNeed0xPrefixForTaker {
    if (takerCoin.swapContractAddress.startsWith('0x')) return true;
    return false;
  }

  /// Returns a maker explorer url if
  /// it exists, otherwise an empty string.
  String get makerExplorerUrl {
    if (makerCoin != null) {
      String middle =
          makerCoin.explorerTxUrl.isEmpty ? 'tx/' : makerCoin.explorerTxUrl;
      return makerCoin.explorerUrl + middle;
    }
    return '';
  }

  /// Returns a taker explorer url if
  /// it exists, otherwise an empty string.
  String get takerExplorerUrl {
    if (takerCoin != null) {
      String middle =
          takerCoin.explorerTxUrl.isEmpty ? 'tx/' : takerCoin.explorerTxUrl;
      return takerCoin.explorerUrl + middle;
    }
    return '';
  }

  /// Index of current swap step.
  int get step => result?.events?.length ?? 0;

  /// 'Started' event data
  SwapEL get started =>
      result?.events?.firstWhere((SwapEL ev) => ev.event.type == 'Started',
          orElse: () => null);

  /// Maker ticker abbriviation
  String get makerAbbr => started?.event?.data?.makerCoin ?? result.makerCoin;

  /// Taker ticker abbriviation
  String get takerAbbr => started?.event?.data?.takerCoin ?? result.takerCoin;

  /// Maker coin instance
  Coin get makerCoin {
    final c = coinsBloc.getCoinByAbbr(makerAbbr ?? result.makerCoin);
    if (c != null) return c;
    final kc = coinsBloc.getKnownCoinByAbbr(makerAbbr ?? result.makerCoin);
    return kc;
  }

  /// Taker coin instance
  Coin get takerCoin {
    final c = coinsBloc.getCoinByAbbr(takerAbbr ?? result.takerCoin);
    if (c != null) return c;
    final kc = coinsBloc.getKnownCoinByAbbr(takerAbbr ?? result.takerCoin);
    return kc;
  }
}
