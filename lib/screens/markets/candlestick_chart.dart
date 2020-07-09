import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' hide TextStyle;
import 'package:intl/intl.dart';

Size _canvasSize;
double _priceScaleFactor;
double _originPrice;
double _priceDivision;
Map<int, CandlePosition> _renderedCandles = {};

class CandleChart extends StatefulWidget {
  const CandleChart(
    this.data, {
    this.candleWidth = 7,
    this.strokeWidth = 1,
    this.textColor = Colors.black,
    this.gridColor = Colors.grey,
    this.upColor = Colors.green,
    this.downColor = Colors.red,
    this.filled = true,
    this.allowDynamicRescale = true,
    this.allowDynamicPriceGrid = false,
  });

  final List<CandleData> data;
  final double candleWidth;
  final double strokeWidth;
  final bool allowDynamicRescale;
  final bool allowDynamicPriceGrid;
  final Color textColor;
  final Color gridColor;
  final Color upColor;
  final Color downColor;
  final bool filled;

  @override
  CandleChartState createState() => CandleChartState();
}

class CandleChartState extends State<CandleChart>
    with TickerProviderStateMixin {
  List<CandleData> sortedByTime;
  int period;
  double timeAxisShift = 0;
  double prevTimeAxisShift = 0;
  double dynamicZoom;
  double staticZoom;
  bool isZooming = false;
  bool shouldRescalePrice = true;

  @override
  void initState() {
    dynamicZoom = 1;
    staticZoom = 1;

    sortedByTime = _sortByTime(widget.data);
    final List<int> periods = [];
    for (int i = 0; i < sortedByTime.length - 1; i++) {
      periods.add(sortedByTime[i].closeTime - sortedByTime[i + 1].closeTime);
    }
    period = (periods.reduce((a, b) => a + b) / periods.length).round();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRect(
        child: GestureDetector(
          onHorizontalDragStart: (_) {
            setState(() {
              shouldRescalePrice = false;
            });
          },
          onHorizontalDragEnd: (_) {
            setState(() {
              shouldRescalePrice = true;
            });
          },
          onHorizontalDragUpdate: (DragUpdateDetails drag) {
            if (isZooming) return;

            setState(() {
              timeAxisShift =
                  timeAxisShift + drag.delta.dx / staticZoom / dynamicZoom;
              if (timeAxisShift < 0) timeAxisShift = 0;
            });
          },
          onScaleStart: (_) {
            setState(() {
              isZooming = true;
              shouldRescalePrice = false;
              prevTimeAxisShift = timeAxisShift;
            });
          },
          onScaleEnd: (_) {
            setState(() {
              isZooming = false;
              staticZoom = staticZoom * dynamicZoom;
              dynamicZoom = 1;
              shouldRescalePrice = true;
            });
          },
          onScaleUpdate: (ScaleUpdateDetails scale) {
            setState(() {
              dynamicZoom = scale.scale;
              timeAxisShift = prevTimeAxisShift -
                  _canvasSize.width /
                      2 *
                      (1 - dynamicZoom) /
                      (staticZoom * dynamicZoom);

              if (timeAxisShift < 0) timeAxisShift = 0;
            });
          },
          child: CustomPaint(
            painter: _ChartPainter(
              widget: widget,
              data: sortedByTime,
              period: period,
              timeAxisShift: timeAxisShift,
              candleWidth: widget.candleWidth,
              shouldRescalePrice:
                  widget.allowDynamicRescale || shouldRescalePrice,
              zoom: staticZoom * dynamicZoom,
            ),
            child: Center(
              child: Container(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    @required this.widget,
    @required this.data,
    @required this.period,
    @required this.candleWidth,
    this.timeAxisShift = 0,
    this.shouldRescalePrice,
    this.zoom = 1,
  });

  final CandleChart widget;
  final List<CandleData> data;
  final int period;
  final double candleWidth;
  final double timeAxisShift;
  bool shouldRescalePrice;
  double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    _canvasSize = size;
    const double pricePaddingPercent = 15;
    const double pricePreferredDivisions = 4;
    const double gap = 2;
    const double topMargin = 20;
    const double bottomMargin = 30;
    final double fieldHeight = size.height - bottomMargin - topMargin;

    double visibleCandlesNumber = size.width / (candleWidth + gap) / zoom;
    if (visibleCandlesNumber < 1) visibleCandlesNumber = 1;
    final double timeRange = visibleCandlesNumber * period;
    final double timeScaleFactor = size.width / timeRange;
    final double timeAxisMax =
        data[0].closeTime - timeAxisShift * zoom / timeScaleFactor;
    final double timeAxisMin = timeAxisMax - timeRange;

    final List<CandleData> visibleCandlesData = [];
    for (int i = 0; i < data.length; i++) {
      final CandleData candle = data[i];
      final double dx = (candle.closeTime - timeAxisMin) * timeScaleFactor;
      if (dx > size.width + candleWidth * zoom) continue;
      if (dx < 0) break;
      visibleCandlesData.add(candle);
    }

    // price axis auto scale
    if (_priceScaleFactor == null || shouldRescalePrice) {
      final double minPrice = _getMinPrice(visibleCandlesData);
      final double maxPrice = _getMaxPrice(visibleCandlesData);
      final double priceRange = maxPrice - minPrice;
      final double priceAxis =
          priceRange + (2 * priceRange * pricePaddingPercent / 100);
      _priceScaleFactor = fieldHeight / priceAxis;
      _priceDivision = widget.allowDynamicPriceGrid
          ? _roundedPriceDivision(priceAxis, pricePreferredDivisions)
          : _exactPriceDivision(priceAxis, pricePreferredDivisions);
      _originPrice = ((minPrice - (priceRange * pricePaddingPercent / 100)) /
                  _priceDivision)
              .round() *
          _priceDivision;
    }

    double _price2dy(double price) {
      return size.height -
          bottomMargin -
          ((price - _originPrice) * _priceScaleFactor);
    }

    double _time2dx(int time) {
      return (time.toDouble() - timeAxisMin) * timeScaleFactor -
          (candleWidth + gap) * zoom / 2;
    }

    final Paint paint = Paint()
      ..style = widget.filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = widget.strokeWidth
      ..strokeCap = StrokeCap.round;

    // calculate candles position
    final Map<int, CandlePosition> candlesToRender = {};
    for (CandleData candle in visibleCandlesData) {
      final double dx = _time2dx(candle.closeTime);

      final double top = _price2dy(max(candle.closePrice, candle.openPrice));
      double bottom = _price2dy(min(candle.closePrice, candle.openPrice));
      if (bottom - top < widget.strokeWidth) bottom = top + widget.strokeWidth;

      candlesToRender[candle.closeTime] = CandlePosition(
        color: candle.closePrice < candle.openPrice
            ? widget.downColor
            : widget.upColor,
        high: Offset(dx, _price2dy(candle.highPrice)),
        low: Offset(dx, _price2dy(candle.lowPrice)),
        left: dx - candleWidth * zoom / 2,
        right: dx + candleWidth * zoom / 2,
        top: top,
        bottom: bottom,
      );
    }

    // draw candles
    candlesToRender.forEach((int timeStamp, CandlePosition candle) {
      final CandlePosition existingCandle = _renderedCandles[timeStamp];
      if (existingCandle != null) {
        _drawCandle(canvas, paint, candle);
      } else {
        _drawCandle(canvas, paint, candle);
      }
    });
    _renderedCandles = candlesToRender;

    // draw price grid
    final int visibleDivisions =
        (size.height / (_priceDivision * _priceScaleFactor)).floor() + 1;
    for (int i = 0; i < visibleDivisions; i++) {
      paint.color = widget.gridColor;
      final double price = _originPrice + i * _priceDivision;
      final double dy = _price2dy(price);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
      final String formattedPrice =
          double.parse(price.toStringAsPrecision(6)).toString();
      paint.color = widget.textColor;
      _drawText(
        canvas: canvas,
        point: Offset(4, dy),
        text: formattedPrice,
        color: widget.textColor,
        align: TextAlign.start,
      );
    }

    // draw time grid
    final DateTime axisMax =
        DateTime.fromMillisecondsSinceEpoch(timeAxisMax.round() * 1000);
    final DateTime axisMin =
        DateTime.fromMillisecondsSinceEpoch(timeAxisMin.round() * 1000);
    _drawText(
      canvas: canvas,
      color: widget.textColor,
      point: Offset(
        size.width - 100 - 4,
        size.height - 7,
      ),
      text: _formatTime(axisMax.millisecondsSinceEpoch, 'M/d/yy HH:mm'),
      align: TextAlign.end,
    );
    final bool sameDay = axisMax.year == axisMin.year &&
        axisMax.month == axisMin.month &&
        axisMax.day == axisMin.day;
    _drawText(
      canvas: canvas,
      color: widget.textColor,
      point: Offset(
        4,
        size.height - 7,
      ),
      text: _formatTime(axisMin.millisecondsSinceEpoch,
          sameDay ? 'M/d/yy HH:mm' : 'M/d/yy HH:mm'),
      align: TextAlign.start,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double _exactPriceDivision(double range, double divisions) {
    return range / divisions;
  }

  double _roundedPriceDivision(double range, double divisions) {
    final double division = range / divisions;

    final String exponential =
        division.toStringAsExponential(); // e.q. 0.004567 -> '4.567e-3'
    final RegExpMatch match = RegExp(r'^(.*)e(.\d*)$').firstMatch(exponential);
    final double coeff = double.parse(match[1]); // e.q. '4.567e-3' -> 4.567
    final double exponent = double.parse(match[2]); // e.q. '4.567e-3' -> -3.0
    int roundedCoeff = coeff.round();
    if (roundedCoeff > 2) roundedCoeff = 5;
    if (roundedCoeff > 7) roundedCoeff = 10;

    return roundedCoeff *
        pow(10, exponent); // e.q. 0.004567 -> 0.005, 1.97 -> 2
  }

  void _drawCandle(Canvas canvas, Paint paint, CandlePosition candle) {
    paint.color = candle.color;

    final Rect rect = Rect.fromLTRB(
      candle.left,
      candle.top,
      candle.right,
      candle.bottom,
    );

    canvas.drawLine(
      candle.high,
      Offset(candle.high.dx, candle.top),
      paint,
    );
    canvas.drawRect(rect, paint);
    canvas.drawLine(
      Offset(candle.low.dx, candle.bottom),
      candle.low,
      paint,
    );
  }
}

double _getMinPrice(List<CandleData> data) {
  double minPrice;

  for (CandleData candle in data) {
    final double lowest =
        [candle.openPrice, candle.lowPrice, candle.closePrice].reduce(min);

    if (minPrice == null || lowest < minPrice) {
      minPrice = lowest;
    }
  }

  return minPrice;
}

double _getMaxPrice(List<CandleData> data) {
  double maxPrice;

  for (CandleData candle in data) {
    final double highest =
        [candle.openPrice, candle.highPrice, candle.closePrice].reduce(max);

    if (maxPrice == null || highest > maxPrice) {
      maxPrice = highest;
    }
  }

  return maxPrice;
}

String _formatTime(int millisecondsSinceEpoch, String format) {
  final DateTime local =
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

  return DateFormat(format).format(local.toLocal());
}

void _drawText({
  Canvas canvas,
  Offset point,
  String text,
  Color color,
  TextAlign align,
}) {
  final ParagraphBuilder builder =
      ParagraphBuilder(ParagraphStyle(textAlign: align))
        ..pushStyle(TextStyle(color: color, fontSize: 10))
        ..addText(text);
  final Paragraph paragraph = builder.build()
    ..layout(const ParagraphConstraints(width: 100));
  canvas.drawParagraph(
      paragraph, Offset(point.dx, point.dy - paragraph.height));
}

List<CandleData> _sortByTime(List<CandleData> data) {
  final List<CandleData> sortedByTime =
      data.where((CandleData candle) => candle.closeTime != null).toList();

  sortedByTime.sort((a, b) {
    if (a.closeTime < b.closeTime) return 1;
    if (a.closeTime > b.closeTime) return -1;
    return 0;
  });

  return sortedByTime;
}

class CandleData {
  CandleData({
    @required this.closeTime,
    @required this.openPrice,
    @required this.highPrice,
    @required this.lowPrice,
    @required this.closePrice,
    this.volume,
    this.quoteVolume,
  });

  int closeTime;
  double openPrice;
  double highPrice;
  double lowPrice;
  double closePrice;
  double volume;
  double quoteVolume;
}

class CandlePosition {
  CandlePosition({
    this.color,
    this.high,
    this.low,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  Color color;
  Offset high;
  Offset low;
  double top;
  double bottom;
  double left;
  double right;
}
