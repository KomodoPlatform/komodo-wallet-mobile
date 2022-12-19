import 'package:flutter/material.dart';
import '../../../../blocs/orders_bloc.dart';
import '../../../../blocs/swap_history_bloc.dart';
import '../../../../model/order.dart';
import '../../../../model/swap.dart';
import '../../../../model/swap_provider.dart';
import '../../../authentification/lock_screen.dart';
import '../../../dex/orders/maker/maker_order_details_page.dart';
import '../../../dex/orders/swap/final_trade_success.dart';
import '../../../dex/orders/swap/stepper_trade.dart';
import '../../../../widgets/sound_volume_button.dart';

class SwapDetailPage extends StatefulWidget {
  const SwapDetailPage({@required this.swap});

  final Swap swap;

  @override
  _SwapDetailPageState createState() => _SwapDetailPageState();
}

class _SwapDetailPageState extends State<SwapDetailPage> {
  Swap _swapData = Swap();
  bool _orderWasCreated = false;

  @override
  void initState() {
    if (widget.swap.status != null &&
        widget.swap.status == Status.SWAP_SUCCESSFUL)
      swapHistoryBloc.isAnimationStepFinalIsFinish = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
        initialData: ordersBloc.orderSwaps,
        stream: ordersBloc.outOrderSwaps,
        builder: (BuildContext context,
            AsyncSnapshot<List<dynamic>> ordersSnapshot) {
          _closeIfCancelled(ordersSnapshot);
          _switchToMakerIfConverted(ordersSnapshot);

          return LockScreen(
            context: context,
            onSuccess: () {},
            child: Scaffold(
              appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Theme.of(context).colorScheme.onBackground,
                  leading: BackButton(
                    key: const Key('swap-detail-back-button'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  actions: const <Widget>[
                    SoundVolumeButton(key: Key('swap-detail-sound-button'))
                  ]),
              body: StreamBuilder<Iterable<Swap>>(
                  stream: swapHistoryBloc.outSwaps,
                  initialData: swapMonitor.swaps,
                  builder: (BuildContext context,
                      AsyncSnapshot<Iterable<Swap>> swapsSnapshot) {
                    if (swapsSnapshot.data != null &&
                        swapsSnapshot.data.isNotEmpty) {
                      _swapData = widget.swap;
                      for (Swap swap in swapsSnapshot.data) {
                        if (swap.result.uuid == widget.swap.result.uuid) {
                          _swapData = swap;
                        }
                      }
                      if (_swapData.status == Status.SWAP_SUCCESSFUL &&
                          swapHistoryBloc.isAnimationStepFinalIsFinish) {
                        return FinalTradeSuccess(swap: _swapData);
                      } else {
                        return StepperTrade(
                            swap: _swapData,
                            onStepFinish: () {
                              setState(() {
                                swapHistoryBloc.isAnimationStepFinalIsFinish =
                                    true;
                              });
                            });
                      }
                    } else {
                      return StepperTrade(
                          swap: widget.swap,
                          onStepFinish: () {
                            setState(() {
                              swapHistoryBloc.isAnimationStepFinalIsFinish =
                                  true;
                            });
                          });
                    }
                  }),
            ),
          );
        });
  }

  // If taker order wasn't matched in 30s, and order_type.tipe is FillOrKill
  // swap will be auto-cancelled by MM.
  // So, we want to close swap details page after that.
  // In order to avoid mistaken closing at the very beginning of order-matching,
  // first trying to find existing item,
  // related to swap (taker order) and only if it was found,
  // and then disappears (not converts in swap or maker) - closing the page.
  Future<void> _closeIfCancelled(
      AsyncSnapshot<List<dynamic>> ordersSnapshot) async {
    if (!ordersSnapshot.hasData) return;

    await Future<dynamic>.delayed(Duration(seconds: 1));

    dynamic existingOrderOrSwap =
        ordersBloc.orderSwaps.firstWhere((dynamic item) {
      return item is Order && item.uuid == widget.swap.result.uuid;
    }, orElse: () => null);

    existingOrderOrSwap ??= swapMonitor.swap(widget.swap.result.uuid);

    if (_orderWasCreated && existingOrderOrSwap == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    } else if (!_orderWasCreated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _orderWasCreated = true);
      });
    }
  }

  void _switchToMakerIfConverted(AsyncSnapshot<List<dynamic>> ordersSnapshot) {
    if (!ordersSnapshot.hasData) return;

    final Order makerOrder = ordersBloc.orderSwaps.firstWhere((dynamic order) {
      return order is Order &&
          order.uuid == widget.swap.result.uuid &&
          order.orderType == OrderType.MAKER;
    }, orElse: () => null);

    if (makerOrder == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement<dynamic, dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) =>
                MakerOrderDetailsPage(makerOrder.uuid)),
      );
    });
  }
}
