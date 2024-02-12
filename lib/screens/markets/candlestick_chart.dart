import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart' hide TextStyle;
import 'package:intl/intl.dart';
import '../../model/cex_provider.dart';
import '../../utils/utils.dart';

class CandleChart extends StatefulWidget {
  const CandleChart({
    this.data,
    this.duration,
    this.candleWidth = 8,
    this.strokeWidth = 1,
    this.textColor = const Color.fromARGB(200, 255, 255, 255),
    this.gridColor = const Color.fromARGB(50, 255, 255, 255),
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
  final Color upColor;
  final Color downColor;
  final bool filled;
  final bool quoted;
  final Color gridColor;

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
  double maxTimeShift;
  Size canvasSize;
  Offset tapPosition;
  Map<String, dynamic> selectedPoint; // {'timestamp': int, 'price': double}
  int scrollDragFactor = 5;

  @override
  void initState() {
    dynamicZoom = 1;
    staticZoom = 1;

    super.initState();
  }

  @override
  void didUpdateWidget(CandleChart oldWidget) {
    if (oldWidget.quoted != widget.quoted) {
      selectedPoint = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    double _constrainedTimeShift(double timeShift) {
      const overScroll = 70;

      if (timeShift * staticZoom * dynamicZoom < -overScroll)
        return -overScroll / staticZoom / dynamicZoom;

      if (maxTimeShift == null) return timeShift;

      if (timeShift * staticZoom * dynamicZoom > maxTimeShift + overScroll)
        return (maxTimeShift + overScroll) / staticZoom / dynamicZoom;

      return timeShift;
    }

    double _constrainedZoom(double scale) {
      double constrained = scale;

      final double maxZoom = canvasSize.width / 5 / widget.candleWidth;
      if (staticZoom * scale > maxZoom) {
        constrained = maxZoom / staticZoom;
      }
      final double minZoom = canvasSize.width / 500 / widget.candleWidth;
      if (staticZoom * scale < minZoom) {
        constrained = minZoom / staticZoom;
      }

      return constrained;
    }

    return SizedBox(
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
                timeAxisShift +
                    drag.delta.dx / scrollDragFactor / staticZoom / dynamicZoom,
              );
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
              dynamicZoom = _constrainedZoom(scale.scale);
              timeAxisShift = _constrainedTimeShift(
                prevTimeAxisShift -
                    canvasSize.width /
                        2 *
                        (1 - dynamicZoom) /
                        (staticZoom * dynamicZoom),
              );
            });
          },
          onTapDown: (TapDownDetails details) {
            tapPosition = null;

            setState(() {
              tapDownPosition = details.localPosition;
            });
          },
          onTap: () {
            tapPosition = tapDownPosition;
          },
          child: CustomPaint(
            painter: _ChartPainter(
              widget: widget,
              timeAxisShift: timeAxisShift,
              zoom: staticZoom * dynamicZoom,
              tapPosition: tapPosition,
              selectedPoint: selectedPoint,
              setWidgetState: (String prop, dynamic value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    switch (prop) {
                      case 'maxTimeShift':
                        {
                          maxTimeShift = value;
                          break;
                        }
                      case 'canvasSize':
                        {
                          canvasSize = value;
                          break;
                        }
                      case 'tapPosition':
                        {
                          tapPosition = value;
                          break;
                        }
                      case 'selectedPoint':
                        {
                          selectedPoint = value;
                          break;
                        }
                    }
                  });
                });
              },
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
    this.timeAxisShift = 0,
    this.zoom = 1,
    this.tapPosition,
    this.selectedPoint,
    this.setWidgetState,
  });

  final CandleChart widget;
  final double timeAxisShift;
  final double zoom;
  final Offset tapPosition;
  final Map<String, dynamic> selectedPoint;
  final Function(String, dynamic) setWidgetState;

  @override
  void paint(Canvas canvas, Size size) {
    setWidgetState('canvasSize', size);
    final List<CandleData> data = _sortByTime(widget.data);
    final double candleWidth = widget.candleWidth;
    const double pricePaddingPercent = 15;
    const double pricePreferredDivisions = 4;
    const double gap = 2;
    const double marginTop = 14;
    const double marginBottom = 30;
    const double labelWidth = 100;
    final double fieldHeight = size.height - marginBottom - marginTop;

    // adjust time axis
    final int maxVisibleCandles =
        (size.width / (candleWidth + gap) / zoom).floor();
    final int firstCandleIndex =
        timeAxisShift.floor().clamp(0, data.length - maxVisibleCandles);
    final int lastVisibleCandleIndex = (firstCandleIndex + maxVisibleCandles)
        .clamp(maxVisibleCandles, data.length - 1);

    final int firstCandleCloseTime = data[firstCandleIndex].closeTime;
    final int lastCandleCloseTime = data[lastVisibleCandleIndex].closeTime;
    final int timeRange = firstCandleCloseTime - lastCandleCloseTime;
    final double timeScaleFactor = size.width / timeRange;
    setWidgetState(
      'maxTimeShift',
      (data.length - maxVisibleCandles).toDouble(),
    );
    final double timeAxisMax = firstCandleCloseTime - zoom / timeScaleFactor;
    final double timeAxisMin = timeAxisMax - timeRange;

    //collect visible candles data
    final List<CandleData> visibleCandlesData = [];
    for (int i = firstCandleIndex; i < lastVisibleCandleIndex; i++) {
      final CandleData candle = data[i];
      final double dx = (candle.closeTime - timeAxisMin) * timeScaleFactor;
      if (dx > size.width + candleWidth * zoom) {
        continue;
      }
      if (dx < 0) {
        break;
      }
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
      final String formattedPrice = formatPrice(price, 8);
      paint.color = widget.textColor;
      if (i < 1) continue;
      _drawText(
        canvas: canvas,
        point: Offset(4, dy),
        text: formattedPrice,
        color: widget.textColor, // widget.textColor,
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
      text: ' ${formatPrice(currentPrice, 8)} ',
      color: Colors.black,
      backgroundColor: currentPriceColor,
      align: TextAlign.end,
      width: labelWidth,
    );

    // draw time grid
    double rightMarkerPosition = size.width;
    if (timeAxisShift < 0) {
      rightMarkerPosition = rightMarkerPosition -
          (candleWidth / 2 + gap / 2 - timeAxisShift) * zoom;
    }
    _drawText(
      canvas: canvas,
      color: widget.textColor, //widget.textColor,
      point: Offset(
        rightMarkerPosition - labelWidth - 4,
        size.height - 7,
      ),
      text: _formatTime(visibleCandlesData.first.closeTime),
      align: TextAlign.end,
      width: labelWidth,
    );
    _drawText(
      canvas: canvas,
      color: widget.textColor, //widget.textColor,
      point: Offset(
        4,
        size.height - 7,
      ),
      text: _formatTime(visibleCandlesData.last.closeTime),
      align: TextAlign.start,
      width: labelWidth,
    );
    paint.color = widget.gridColor;
    for (CandleData candleData in visibleCandlesData) {
      final double dx = _time2dx(candleData.closeTime);
      canvas.drawLine(Offset(dx, size.height - marginBottom),
          Offset(dx, size.height - marginBottom + 5), paint);
    }
    paint.color = widget.textColor; //widget.textColor;
    canvas.drawLine(Offset(0, size.height - marginBottom),
        Offset(0, size.height - marginBottom + 5), paint);
    canvas.drawLine(Offset(rightMarkerPosition, size.height - marginBottom),
        Offset(rightMarkerPosition, size.height - marginBottom + 5), paint);

    // select point on Tap
    if (tapPosition != null) {
      setWidgetState('selectedPoint', null);
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
              pow(tapPosition.dx - _time2dx(candle.closeTime), 2) +
                  pow(tapPosition.dy - _price2dy(price), 2));
          if (distance > 30) continue;
          if (minDistance != null && distance > minDistance) continue;

          minDistance = distance;
          setWidgetState('selectedPoint', <String, dynamic>{
            'timestamp': candle.closeTime,
            'price': price,
          });
        }
      }
      setWidgetState('tapPosition', null);
    }

    // draw selected point
    if (selectedPoint != null) {
      CandleData selectedCandle;
      try {
        selectedCandle = visibleCandlesData.firstWhere((CandleData candle) {
          return candle.closeTime == selectedPoint['timestamp'];
        });
      } catch (_) {}

      if (selectedCandle != null) {
        const double radius = 3;
        final double dx = _time2dx(selectedCandle.closeTime);
        final double dy = _price2dy(selectedPoint['price']);
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
          color: widget.textColor == Colors.black ? Colors.white : Colors.black,
          backgroundColor: widget.textColor,
          text: ' ${formatPrice(selectedPoint['price'], 8)} ',
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
          color: widget.textColor == Colors.black ? Colors.white : Colors.black,
          backgroundColor: widget.textColor,
          text: ' ${_formatTime(selectedCandle.closeTime)} ',
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

  String _formatTime(int millisecondsSinceEpoch) {
    final DateTime utc = DateTime.fromMillisecondsSinceEpoch(
      millisecondsSinceEpoch,
      isUtc: true,
    );
    final bool thisYear = DateTime.now().year == utc.year;

    String format = 'MMM dd yyyy';
    if (widget.duration < 60 * 60 * 24) {
      format = 'MMM dd${thisYear ? '' : ' yyyy'}, HH:00';
    }
    if (widget.duration < 60 * 60) {
      format = 'MMM dd${thisYear ? '' : ' yyyy'}, HH:mm';
    }

    return DateFormat(format).format(utc);
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
