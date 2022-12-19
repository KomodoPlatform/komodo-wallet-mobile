import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../blocs/orders_bloc.dart';
import '../../../../model/order.dart';

class BuildTakerCountdown extends StatefulWidget {
  const BuildTakerCountdown(this.uuid, {this.style});

  final String uuid;
  final TextStyle style;

  @override
  _BuildTakerCountdownState createState() => _BuildTakerCountdownState();
}

class _BuildTakerCountdownState extends State<BuildTakerCountdown> {
  Timer _timer;
  TextStyle _style;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _style ??= widget.style ??
        Theme.of(context).textTheme.bodyText2.copyWith(
            fontWeight: FontWeight.w300,
            color:
                Theme.of(context).textTheme.bodyText2.color.withOpacity(0.5));

    final Order takerOrder = ordersBloc.orderSwaps.firstWhere((dynamic order) {
      return order is Order &&
          order.uuid == widget.uuid &&
          order.orderType == OrderType.TAKER;
    }, orElse: () => null);

    if (takerOrder == null) return SizedBox();

    final int secondsLeft = 30 -
        (DateTime.now().millisecondsSinceEpoch / 1000).floor() +
        takerOrder.createdAt;

    return Row(
      children: [
        Text(
          ': ',
          style: _style,
        ),
        secondsLeft > 0
            ? Text(
                '$secondsLeft',
                style: _style,
              )
            : SizedBox(
                height: 13,
                width: 13,
                child: CircularProgressIndicator(strokeWidth: 1)),
      ],
    );
  }
}
