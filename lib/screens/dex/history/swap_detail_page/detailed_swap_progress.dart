import 'package:flutter/material.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:provider/provider.dart';

class DetailedSwapProgress extends StatefulWidget {
  const DetailedSwapProgress({this.uuid});

  final String uuid;

  @override
  _DetailedSwapProgressState createState() => _DetailedSwapProgressState();
}

class _DetailedSwapProgressState extends State<DetailedSwapProgress> {
  Swap swap;
  @override
  Widget build(BuildContext context) {
    final SwapProvider _swapProvider = Provider.of<SwapProvider>(context);
    swap = _swapProvider.swap(widget.uuid);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: <Widget>[
          Text(
            'Progress details:', // TODO(yurii): localization
            style: Theme.of(context).textTheme.body2,
          ),
          Text(swap.result.events[swap.result.events.length - 1].event.type),
        ],
      ),
    );
  }
}
