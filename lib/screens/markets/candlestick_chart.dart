import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' hide TextStyle;
import 'package:intl/intl.dart';
import 'package:komodo_dex/model/cex_provider.dart';

double _maxTimeShift;
Size _canvasSize;
Offset _tapPosition;
Map<String, dynamic> _selectedPoint; // {'timestamp': int, 'price': double}

class CandleChart extends StatefulWidget {
  const CandleChart({
    this.data,
    this.duration,
    this.candleWidth = 7,
    this.strokeWidth = 1,
    this.textColor = Colors.black,
    this.gridColor = Colors.grey,
    this.upColor = Colors.green,
    this.downColor = Colors.red,
    this.filled = true,
    this.quoted = false,
  });

  final List<CandleData> data;
  final int duration; // sec
  final double candleWidth;
  final double strokeWidth;
  final Color textColor;
  final Color gridColor;
  final Color upColor;
  final Color downColor;
  final bool filled;
  final bool quoted;

  @override
  CandleChartState createState() => CandleChartState();
}

class CandleChartState extends State<CandleChart>
    with TickerProviderStateMixin {
  double timeAxisShift = 0;
  double prevTimeAxisShift = 0;
  double dynamicZoom;
  double staticZoom;
  Offset tapDownPosition;
  int touchCounter = 0;

  @override
  void initState() {
    dynamicZoom = 1;
    staticZoom = 1;

    super.initState();
  }

  @override
  void didUpdateWidget(CandleChart oldWidget) {
    if (oldWidget.quoted != widget.quoted) {
      _selectedPoint = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    double _constrainedTimeShift(double timeShift) {
      const overScroll = 70;

      if (timeShift * staticZoom * dynamicZoom < -overScroll)
        return -overScroll / staticZoom / dynamicZoom;

      if (_maxTimeShift == null) return timeShift;

      if (timeShift * staticZoom * dynamicZoom > _maxTimeShift + overScroll)
        return (_maxTimeShift + overScroll) / staticZoom / dynamicZoom;

      return timeShift;
    }

    return Container(
      child: ClipRect(
        child: Listener(
          onPointerDown: (_) {
            setState(() {
              touchCounter++;
            });
          },
          onPointerUp: (_) {
            setState(() {
              touchCounter--;
            });
          },
          child: GestureDetector(
            onHorizontalDragUpdate: (DragUpdateDetails drag) {
              if (touchCounter > 1) return;

              setState(() {
                timeAxisShift = _constrainedTimeShift(
                    timeAxisShift + drag.delta.dx / staticZoom / dynamicZoom);
              });
            },
            onScaleStart: (_) {
              setState(() {
                prevTimeAxisShift = timeAxisShift;
              });
            },
            onScaleEnd: (_) {
              setState(() {
                staticZoom = staticZoom * dynamicZoom;
                dynamicZoom = 1;
              });
            },
            onScaleUpdate: (ScaleUpdateDetails scale) {
              setState(() {
                final double maxZoom =
                    _canvasSize.width / 5 / widget.candleWidth;
                if (staticZoom * scale.scale > maxZoom) {
                  dynamicZoom = maxZoom / staticZoom;
                } else {
                  dynamicZoom = scale.scale;
                }
                timeAxisShift = _constrainedTimeShift(prevTimeAxisShift -
                    _canvasSize.width /
                        2 *
                        (1 - dynamicZoom) /
                        (staticZoom * dynamicZoom));
              });
            },
            onTapDown: (TapDownDetails details) {
              _tapPosition = null;

              setState(() {
                tapDownPosition = details.localPosition;
              });
            },
            onTap: () {
              _tapPosition = tapDownPosition;
            },
            child: CustomPaint(
              painter: _ChartPainter(
                widget: widget,
                timeAxisShift: timeAxisShift,
                zoom: staticZoom * dynamicZoom,
              ),
              child: Center(
                child: Container(),
              ),
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
    this.timeAxisShift = 0,
    this.zoom = 1,
  });

  final CandleChart widget;
  final double timeAxisShift;
  double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    _canvasSize = size;
    final List<CandleData> data = _sortByTime(widget.data);
    final double candleWidth = widget.candleWidth;
    const double pricePaddingPercent = 15;
    const double pricePreferredDivisions = 4;
    const double gap = 2;
    const double marginTop = 14;
    const double marginBottom = 30;
    const double labelWidth = 100;
    final double fieldHeight = size.height - marginBottom - marginTop;

    // adjust time asix
    double visibleCandlesNumber = size.width / (candleWidth + gap) / zoom;
    if (visibleCandlesNumber < 1) visibleCandlesNumber = 1;
    final double timeRange = visibleCandlesNumber * widget.duration;
    final double timeScaleFactor = size.width / timeRange;
    _maxTimeShift =
        (data.first.closeTime - data.last.closeTime) * timeScaleFactor -
            timeRange * timeScaleFactor;
    final double timeAxisMax =
        data[0].closeTime - timeAxisShift * zoom / timeScaleFactor;
    final double timeAxisMin = timeAxisMax - timeRange;

    //collect visible candles data
    final List<CandleData> visibleCandlesData = [];
    for (int i = 0; i < data.length; i++) {
      final CandleData candle = data[i];
      final double dx = (candle.closeTime - timeAxisMin) * timeScaleFactor;
      if (dx > size.width + candleWidth * zoom) continue;
      if (dx < 0) break;
      visibleCandlesData.add(candle);
    }

    // adjust price axis
    final double minPrice = _minPrice(visibleCandlesData);
    final double maxPrice = _maxPrice(visibleCandlesData);
    final double priceRange = maxPrice - minPrice;
    final double priceAxis =
        priceRange + (2 * priceRange * pricePaddingPercent / 100);
    final double priceScaleFactor = fieldHeight / priceAxis;
    final double priceDivision =
        _priceDivision(priceAxis, pricePreferredDivisions);
    final double originPrice =
        ((minPrice - (priceRange * pricePaddingPercent / 100)) / priceDivision)
                .round() *
            priceDivision;

    // returns dy for given price
    double _price2dy(double price) {
      return size.height -
          marginBottom -
          ((price - originPrice) * priceScaleFactor);
    }

    // returns dx for given time
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

      final double top =
          _price2dy(max(_price(candle.closePrice), _price(candle.openPrice)));
      double bottom =
          _price2dy(min(_price(candle.closePrice), _price(candle.openPrice)));
      if (bottom - top < widget.strokeWidth) bottom = top + widget.strokeWidth;

      candlesToRender[candle.closeTime] = CandlePosition(
        color: _price(candle.closePrice) < _price(candle.openPrice)
            ? widget.downColor
            : widget.upColor,
        high: Offset(dx, _price2dy(_price(candle.highPrice))),
        low: Offset(dx, _price2dy(_price(candle.lowPrice))),
        left: dx - candleWidth * zoom / 2,
        right: dx + candleWidth * zoom / 2,
        top: top,
        bottom: bottom,
      );
    }

    // draw candles
    candlesToRender.forEach((int timeStamp, CandlePosition candle) {
      _drawCandle(canvas, paint, candle);
    });

    // draw price grid
    final int visibleDivisions =
        (size.height / (priceDivision * priceScaleFactor)).floor() + 1;
    for (int i = 0; i < visibleDivisions; i++) {
      paint.color = widget.gridColor;
      final double price = originPrice + i * priceDivision;
      final double dy = _price2dy(price);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
      final String formattedPrice =
          double.parse(price.toStringAsPrecision(6)).toString();
      paint.color = widget.textColor;
      if (i < 1) continue;
      _drawText(
        canvas: canvas,
        point: Offset(4, dy),
        text: formattedPrice,
        color: widget.textColor,
        align: TextAlign.start,
        width: labelWidth,
      );
    }

    //draw current price
    final double currentPrice = _price(data.first.closePrice);
    double currentPriceDy = _price2dy(currentPrice);
    bool outside = false;
    if (currentPriceDy > size.height - marginBottom) {
      outside = true;
      currentPriceDy = size.height - marginBottom;
    }
    if (currentPriceDy < size.height - marginBottom - fieldHeight) {
      outside = true;
      currentPriceDy = size.height - marginBottom - fieldHeight;
    }
    final Color currentPriceColor = outside
        ? const Color.fromARGB(120, 200, 200, 150)
        : const Color.fromARGB(255, 200, 200, 150);
    paint.color = currentPriceColor;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, currentPriceDy),
          Offset(startX + 5, currentPriceDy), paint);
      startX += 10;
    }

    _drawText(
      canvas: canvas,
      point: Offset(size.width - labelWidth - 2, currentPriceDy - 2),
      text: ' ${double.parse(currentPrice.toStringAsPrecision(6)).toString()} ',
      color: Colors.black,
      backgroundColor: currentPriceColor,
      align: TextAlign.end,
      width: labelWidth,
    );

    // draw time grid
    final DateTime axisMax =
        DateTime.fromMillisecondsSinceEpoch(timeAxisMax.round() * 1000);
    final DateTime axisMin =
        DateTime.fromMillisecondsSinceEpoch(timeAxisMin.round() * 1000);
    double rightMarkerPosition = size.width;
    int rightMarkerTime = axisMax.millisecondsSinceEpoch;
    if (timeAxisShift < 0) {
      rightMarkerPosition = rightMarkerPosition -
          (candleWidth / 2 + gap / 2 - timeAxisShift) * zoom;
      rightMarkerTime = visibleCandlesData.first.closeTime * 1000;
    }
    _drawText(
      canvas: canvas,
      color: widget.textColor,
      point: Offset(
        rightMarkerPosition - labelWidth - 4,
        size.height - 7,
      ),
      text: _formatTime(rightMarkerTime, 'M/d/yy HH:mm'),
      align: TextAlign.end,
      width: labelWidth,
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
      text: _formatTime(
          axisMin.millisecondsSinceEpoch, sameDay ? 'HH:mm' : 'M/d/yy HH:mm'),
      align: TextAlign.start,
      width: labelWidth,
    );
    paint.color = widget.gridColor;
    for (CandleData candleData in visibleCandlesData) {
      final double dx = _time2dx(candleData.closeTime);
      canvas.drawLine(Offset(dx, size.height - marginBottom),
          Offset(dx, size.height - marginBottom + 5), paint);
    }
    paint.color = widget.textColor;
    canvas.drawLine(Offset(0, size.height - marginBottom),
        Offset(0, size.height - marginBottom + 5), paint);
    canvas.drawLine(Offset(rightMarkerPosition, size.height - marginBottom),
        Offset(rightMarkerPosition, size.height - marginBottom + 5), paint);

    // select point on Tap
    if (_tapPosition != null) {
      _selectedPoint = null;
      double minDistance;
      for (CandleData candle in visibleCandlesData) {
        final List<double> prices = [
          _price(candle.openPrice),
          _price(candle.closePrice),
          _price(candle.highPrice),
          _price(candle.lowPrice),
        ].toList();

        for (double price in prices) {
          final double distance = sqrt(
              pow(_tapPosition.dx - _time2dx(candle.closeTime), 2) +
                  pow(_tapPosition.dy - _price2dy(price), 2));
          if (distance > 30) continue;
          if (minDistance != null && distance > minDistance) continue;

          minDistance = distance;
          _selectedPoint = <String, dynamic>{
            'timestamp': candle.closeTime,
            'price': price,
          };
        }
      }
      _tapPosition = null;
    }

    // draw selected point
    if (_selectedPoint != null) {
      CandleData selectedCandle;
      try {
        selectedCandle = visibleCandlesData.firstWhere((CandleData candle) {
          return candle.closeTime == _selectedPoint['timestamp'];
        });
      } catch (_) {}

      if (selectedCandle != null) {
        const double radius = 3;
        final double dx = _time2dx(selectedCandle.closeTime);
        final double dy = _price2dy(_selectedPoint['price']);
        paint.style = PaintingStyle.stroke;

        canvas.drawCircle(Offset(dx, dy), radius, paint);

        double startX = dx + radius;
        while (startX < size.width) {
          canvas.drawLine(Offset(startX, dy), Offset(startX + 5, dy), paint);
          startX += 10;
        }

        _drawText(
          canvas: canvas,
          align: TextAlign.right,
          color: Colors.black,
          backgroundColor: Colors.white,
          text:
              ' ${double.parse(_selectedPoint['price'].toStringAsPrecision(6)).toString()} ',
          point: Offset(size.width - labelWidth - 2, dy - 2),
          width: labelWidth,
        );

        double startY = dy + radius;
        while (startY < size.height - marginBottom + 10) {
          canvas.drawLine(Offset(dx, startY), Offset(dx, startY + 5), paint);
          startY += 10;
        }

        _drawText(
          canvas: canvas,
          align: TextAlign.center,
          color: Colors.black,
          backgroundColor: Colors.white,
          text:
              ' ${_formatTime(selectedCandle.closeTime * 1000, 'M/d/yy HH:mm')} ',
          point: Offset(dx - 50, size.height - 7),
          width: labelWidth,
        );
      }
    }
  } // paint

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double _priceDivision(double range, double divisions) {
    return range / divisions;
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

  double _price(double price) {
    if (widget.quoted) return 1 / price;
    return price;
  }

  double _minPrice(List<CandleData> data) {
    double minPrice;

    for (CandleData candle in data) {
      final double lowest = [
        _price(candle.openPrice),
        _price(candle.lowPrice),
        _price(candle.closePrice),
      ].reduce(min);

      if (minPrice == null || lowest < minPrice) {
        minPrice = lowest;
      }
    }

    return minPrice;
  }

  double _maxPrice(List<CandleData> data) {
    double maxPrice;

    for (CandleData candle in data) {
      final double highest = [
        _price(candle.openPrice),
        _price(candle.highPrice),
        _price(candle.closePrice),
      ].reduce(max);

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
    Color backgroundColor = Colors.transparent,
    TextAlign align,
    double width,
  }) {
    final ParagraphBuilder builder =
        ParagraphBuilder(ParagraphStyle(textAlign: align))
          ..pushStyle(TextStyle(
            color: color,
            fontSize: 10,
            background: Paint()..color = backgroundColor,
          ))
          ..addText(text);
    final Paragraph paragraph = builder.build()
      ..layout(ParagraphConstraints(width: width));
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
