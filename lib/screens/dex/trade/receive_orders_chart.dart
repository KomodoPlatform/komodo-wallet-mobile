import 'dart:math';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:provider/provider.dart';

class ReceiveOrdersChart extends StatefulWidget {
  const ReceiveOrdersChart({
    this.ordersList,
    this.sellAmount,
    this.lineHeight,
  });

  final List<Ask> ordersList;
  final double sellAmount;
  final double lineHeight;

  @override
  _ReceiveOrdersChartState createState() => _ReceiveOrdersChartState();
}

class _ReceiveOrdersChartState extends State<ReceiveOrdersChart> {
  OrderBookProvider orderBookProvider;
  Coin sellCoin;

  @override
  Widget build(BuildContext context) {
    orderBookProvider = Provider.of<OrderBookProvider>(context);
    sellCoin = orderBookProvider.activePair.sell;

    return Container(
      child: CustomPaint(
        painter: _ChartPainter(widget),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.widget);

  final ReceiveOrdersChart widget;

  @override
  void paint(Canvas canvas, Size size) {
    double maxBaseVolume = _baseVolumes().reduce(max);
    if (maxBaseVolume < widget.sellAmount) maxBaseVolume = widget.sellAmount;
    final double baseVolumeRatio = size.width / maxBaseVolume;

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green.withAlpha(70);

    for (int i = 0; i < widget.ordersList.length; i++) {
      final Ask ask = widget.ordersList[i];
      double barWidth = _baseVolume(ask) * baseVolumeRatio;
      if (barWidth < 1) barWidth = 1;

      canvas.drawRect(
          Rect.fromLTRB(
            size.width - barWidth,
            widget.lineHeight * i,
            size.width,
            widget.lineHeight * i + widget.lineHeight,
          ),
          paint);
    }

    paint
      ..color = Colors.green.withAlpha(200)
      ..strokeWidth = 1;

    double sellVolumeWidth = widget.sellAmount * baseVolumeRatio;
    if (sellVolumeWidth < 1) sellVolumeWidth = 1;
    final double sellVolumeX = size.width - sellVolumeWidth;
    double startY = -5;
    while (startY < size.height + 6) {
      canvas.drawLine(
        Offset(sellVolumeX, startY),
        Offset(sellVolumeX, startY + 3),
        paint,
      );
      startY += 6;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  List<double> _baseVolumes() {
    return widget.ordersList.map((ask) => _baseVolume(ask)).toList();
  }

  double _baseVolume(Ask ask) {
    return ask.maxvolume.toDouble() * double.parse(ask.price);
  }
}
