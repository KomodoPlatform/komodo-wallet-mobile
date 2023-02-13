import 'package:flutter/material.dart';
import '../../../../generic_blocs/swap_history_bloc.dart';
import '../../../../localizations.dart';
import '../../../../model/order.dart';
import '../../../../model/swap.dart';
import '../../../../model/swap_provider.dart';
import '../../../../utils/utils.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class OrderFill extends StatefulWidget {
  const OrderFill(this.order, {this.size = 30});

  final Order order;
  final double size;

  @override
  _OrderFillState createState() => _OrderFillState();
}

class _OrderFillState extends State<OrderFill> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: FillPainter(
              context: context,
              order: widget.order,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          AppLocalizations.of(context)!.orderFilled(cutTrailingZeros(
              (getFill(widget.order) * 100).toStringAsPrecision(3))!),
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }
}

class FillPainter extends CustomPainter {
  FillPainter({
    required this.context,
    required this.order,
  });

  final BuildContext context;
  final Order order;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Theme.of(context).highlightColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 2, paint);

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 1.1 / 2;

    double fillProgress = 0;
    for (String swapId in order.startedSwaps!) {
      final Swap? swap = swapMonitor.swap(swapId);
      if (swap == null) continue;

      fillPaint.color = swapHistoryBloc.getColorStatus(swap.status);

      final myInfo = extractMyInfoFromSwap(swap.result!);
      final myAmount = myInfo['myAmount']!;
      final double swapFill =
          double.parse(myAmount) / double.parse(order.baseAmount!);

      canvas.drawArc(
          Rect.fromCircle(center: center, radius: size.width / 4),
          math.radians(-90 + fillProgress * 360),
          math.radians(swapFill * 360),
          false,
          fillPaint);
      fillProgress += swapFill;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Returns fraction of maker [order] amount (same for base and rel),
/// filled by started swaps.
/// '0' if no swaps were started, '1' if order was filled in full.
double getFill(Order order) {
  if (order.startedSwaps == null || order.startedSwaps!.isEmpty) return 0;

  double fill = 0;
  for (String swapId in order.startedSwaps!) {
    final Swap? swap = swapMonitor.swap(swapId);
    if (swap == null) continue;

    final myInfo = extractMyInfoFromSwap(swap.result!);
    final myAmount = myInfo['myAmount']!;
    fill += double.parse(myAmount) / double.parse(order.baseAmount!);
  }
  return fill;
}
