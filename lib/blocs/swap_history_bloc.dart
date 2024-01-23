import 'dart:async';

import 'package:flutter/material.dart';
import '../localizations.dart';
import '../model/get_recover_funds_of_swap.dart';
import '../model/recent_swaps.dart';
import '../model/swap.dart';
import '../services/mm.dart';
import '../services/mm_service.dart';
import '../widgets/bloc_provider.dart';

SwapHistoryBloc swapHistoryBloc = SwapHistoryBloc();

class SwapHistoryBloc implements BlocBase {
  // BLoC list of swaps.
  // AG: Should eventually refactor the UI code to use the `SwapProvider` instead.
  final StreamController<Iterable<Swap>> _swapsController =
      StreamController<Iterable<Swap>>.broadcast();
  Sink<Iterable<Swap>> get inSwaps => _swapsController.sink;
  Stream<Iterable<Swap>> get outSwaps => _swapsController.stream;

  bool isAnimationStepFinalIsFinish = false;
  bool isSwapsOnGoing = false;
  @override
  void dispose() {
    _swapsController.close();
  }

  Future<dynamic> recoverFund(Swap swap) async => await MM.recoverFundsOfSwap(
      mmSe.client,
      GetRecoverFundsOfSwap(params: Params(uuid: swap.result.uuid)));

  /// Deprecated: should be using `errorEvents` and `successEvents` (`MmSwap::status`)
  /// instead of hardcoding all the present **and future** status events
  Status getStatusSwap(MmSwap resultSwap) {
    Status status = Status.ORDER_MATCHING;

    for (SwapEL event in resultSwap.events) {
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
        case 'MakerPaymentSpentByWatcher':
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
        return String.fromCharCode(0x221A);
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
