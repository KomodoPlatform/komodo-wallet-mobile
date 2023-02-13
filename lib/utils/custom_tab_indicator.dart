import 'package:flutter/material.dart';

class CustomTabIndicator extends Decoration {
  const CustomTabIndicator({this.context});

  final BuildContext? context;

  @override
  _CustomPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomPainter(context, this, onChanged);
  }
}

class _CustomPainter extends BoxPainter {
  _CustomPainter(this.context, this.decoration, VoidCallback? onChanged)
      : assert(decoration != null),
        super(onChanged);

  final CustomTabIndicator decoration;
  final BuildContext? context;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    const double indicatorHeight = 38.0;
    //offset is the position from where the decoration should be drawn.
    //configuration.size tells us about the height and width of the tab.
    // final Rect rect = offset & configuration.size;
    final Rect rect = Offset(offset.dx - 1,
            (configuration.size!.height / 2) - indicatorHeight / 2) &
        Size(configuration.size!.width + 2, indicatorHeight);

    final Paint paint = Paint();
    paint.color = Theme.of(context!).colorScheme.secondary;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;

    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(30.0)), paint);
  }
}
