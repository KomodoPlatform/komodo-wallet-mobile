import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/final_trade_success.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/stepper_trade.dart';
import 'package:komodo_dex/widgets/sound_volume_button.dart';

class SwapDetailPage extends StatefulWidget {
  const SwapDetailPage({@required this.swap});

  final Swap swap;

  @override
  _SwapDetailPageState createState() => _SwapDetailPageState();
}

class _SwapDetailPageState extends State<SwapDetailPage> {
  Swap swapData = Swap();

  @override
  void initState() {
    if (widget.swap.status != null &&
        widget.swap.status == Status.SWAP_SUCCESSFUL)
      swapHistoryBloc.isAnimationStepFinalIsFinish = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      onSuccess: () {},
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).backgroundColor,
            leading: IconButton(
              key: const Key('swap-detail-back-button'),
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            ),
            actions: const <Widget>[
              SoundVolumeButton(key: Key('swap-detail-sound-button'))
            ]),
        body: StreamBuilder<Iterable<Swap>>(
            stream: swapHistoryBloc.outSwaps,
            initialData: syncSwaps.swaps,
            builder:
                (BuildContext context, AsyncSnapshot<Iterable<Swap>> snapshot) {
              if (snapshot.data != null && snapshot.data.isNotEmpty) {
                swapData = widget.swap;
                for (Swap swap in snapshot.data) {
                  if (swap.result.uuid == widget.swap.result.uuid) {
                    swapData = swap;
                  }
                }
                if (swapData.status == Status.SWAP_SUCCESSFUL &&
                    swapHistoryBloc.isAnimationStepFinalIsFinish) {
                  return FinalTradeSuccess(swap: swapData);
                } else {
                  return StepperTrade(
                      swap: swapData,
                      onStepFinish: () {
                        setState(() {
                          swapHistoryBloc.isAnimationStepFinalIsFinish = true;
                        });
                      });
                }
              } else {
                return StepperTrade(
                    swap: widget.swap,
                    onStepFinish: () {
                      setState(() {
                        swapHistoryBloc.isAnimationStepFinalIsFinish = true;
                      });
                    });
              }
            }),
      ),
    );
  }
}
