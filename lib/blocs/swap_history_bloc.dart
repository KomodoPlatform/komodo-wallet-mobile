import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

SwapHistoryBloc swapHistoryBloc = SwapHistoryBloc();

class SwapHistoryBloc implements BlocBase {
  List<Swap> swaps = <Swap>[];

  // Streams to handle the list coin
  final StreamController<List<Swap>> _swapsController =
      StreamController<List<Swap>>.broadcast();
  Sink<List<Swap>> get _inSwaps => _swapsController.sink;
  Stream<List<Swap>> get outSwaps => _swapsController.stream;

  bool isAnimationStepFinalIsFinish = false;
  bool isSwapsOnGoing = false;
  @override
  void dispose() {
    _swapsController.close();
  }

  Future<List<Swap>> updateSwaps(int limit, String fromUuid) async {
    isSwapsOnGoing = false;
    setSwaps(await fetchSwaps(limit, fromUuid));
    return swaps;
  }

  Future<List<Swap>> fetchSwaps(int limit, String fromUuid) async {
    try {
      final RecentSwaps recentSwaps = await MarketMakerService().getRecentSwaps(limit, fromUuid);
      final List<Swap> newSwaps = <Swap>[];

      for (ResultSwap swap in recentSwaps.result.swaps) {
        final dynamic nSwap = Swap(result: swap, status: getStatusSwap(swap));
        if (nSwap is Swap) {
          if (swap.myInfo != null &&
              swap.myInfo.startedAt + 3600 <
                  DateTime.now().millisecondsSinceEpoch ~/ 1000 &&
              getStatusSwap(swap) != Status.SWAP_SUCCESSFUL) {
            nSwap.status = Status.TIME_OUT;
          }
          newSwaps.add(nSwap);
          if (nSwap.status == Status.ORDER_MATCHED ||
              nSwap.status == Status.ORDER_MATCHING ||
              nSwap.status == Status.SWAP_ONGOING) {
            isSwapsOnGoing = true;
          }
        } else if (nSwap is ErrorString) {
          if (swap.myInfo != null &&
              swap.myInfo.startedAt + 600 <
                  DateTime.now().millisecondsSinceEpoch ~/ 1000) {
            newSwaps.add(Swap(
              status: Status.TIME_OUT,
              result: swap,
            ));
          }
        }
      }
      return newSwaps;
    } catch (e) {
      print(e);
      return <Swap>[];
    }
  }

  void setSwaps(List<Swap> newSwaps) {
    if (newSwaps == null) {
      swaps.clear();
    } else {
      if (swaps.isEmpty) {
        swaps.addAll(newSwaps);
      } else {
        for (Swap newSwap in newSwaps) {
          bool isSwapAlreadyExist = false;
          swaps.asMap().forEach((int index, Swap currentSwap) {
            if (newSwap.result.uuid == currentSwap.result.uuid) {
              isSwapAlreadyExist = true;
              if (newSwap.status != currentSwap.status) {
                swaps.removeAt(index);
                swaps.add(newSwap);
              }
            }
          });
          if (!isSwapAlreadyExist) {
            swaps.add(newSwap);
          }
        }
      }
    }
    _inSwaps.add(swaps);
  }

  Status getStatusSwap(ResultSwap resultSwap) {
    Status status = Status.ORDER_MATCHING;

    for (EventElement event in resultSwap.events) {
      print(event.event.type);
      switch (event.event.type) {
        case 'Started':
          status = Status.ORDER_MATCHED;
          break;
        case 'TakerFeeSent':
          status = Status.SWAP_ONGOING;
          break;
        case 'TakerFeeValidated':
          status = Status.SWAP_ONGOING;
          break;
        case 'MakerPaymentSpent':
          status = Status.SWAP_SUCCESSFUL;
          break;
        case 'TakerPaymentSpent':
          status = Status.SWAP_SUCCESSFUL;
          break;
        case 'StartFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'NegotiateFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'MakerPaymentValidateFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'TakerPaymentTransactionFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'TakerPaymentDataSendFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'TakerPaymentWaitForSpendFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'MakerPaymentSpendFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'TakerPaymentRefunded':
          status = Status.SWAP_FAILED;
          break;
        case 'TakerPaymentRefundFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'TakerFeeSendFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'TakerFeeValidateFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'MakerPaymentTransactionFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'MakerPaymentDataSendFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'TakerPaymentValidateFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'TakerPaymentSpendFailed':
          status = Status.SWAP_FAILED;
          break;
        case 'MakerPaymentRefunded':
          status = Status.SWAP_FAILED;
          break;
        case 'MakerPaymentRefundFailed':
          status = Status.SWAP_FAILED;
          break;
        default:
      }
    }
    print('STATUS: ' + status.toString());
    return status;
  }

  String getSwapStatusString(BuildContext context, Status status) {
    switch (status) {
      case Status.ORDER_MATCHING:
        return AppLocalizations.of(context).orderMatching;
        break;
      case Status.ORDER_MATCHED:
        return AppLocalizations.of(context).orderMatched;
        break;
      case Status.SWAP_ONGOING:
        return AppLocalizations.of(context).swapOngoing;
        break;
      case Status.SWAP_SUCCESSFUL:
        return AppLocalizations.of(context).swapSucceful;
        break;
      case Status.TIME_OUT:
        return AppLocalizations.of(context).timeOut;
        break;
      case Status.SWAP_FAILED:
        return AppLocalizations.of(context).swapFailed;
        break;
      default:
    }
    return '';
  }

  Color getColorStatus(Status status) {
    switch (status) {
      case Status.ORDER_MATCHING:
        return Colors.grey;
        break;
      case Status.ORDER_MATCHED:
        return Colors.yellowAccent.shade700.withOpacity(0.7);
        break;
      case Status.SWAP_ONGOING:
        return Colors.orangeAccent;
        break;
      case Status.SWAP_SUCCESSFUL:
        return Colors.green.shade500;
        break;
      case Status.TIME_OUT:
        return Colors.redAccent;
        break;
      case Status.SWAP_FAILED:
        return Colors.redAccent;
        break;
      default:
    }
    return Colors.redAccent;
  }

  String getStepStatus(Status status) {
    switch (status) {
      case Status.ORDER_MATCHING:
        return '0/3';
        break;
      case Status.ORDER_MATCHED:
        return '1/3';
        break;
      case Status.SWAP_ONGOING:
        return '2/3';
        break;
      case Status.SWAP_SUCCESSFUL:
        return '✓';
        break;
      case Status.TIME_OUT:
        return '';
        break;
      case Status.SWAP_FAILED:
        return '';
        break;
      default:
    }
    return '';
  }

  int getStepStatusNumber(Status status) {
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

  double getNumberStep() {
    return 3;
  }
}
