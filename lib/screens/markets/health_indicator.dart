import 'dart:math';

import 'package:flutter/material.dart';

class HealthIndicator extends StatelessWidget {
  const HealthIndicator(
    this.value, {
    this.min,
    this.max,
    this.color,
    this.size,
  });

  final double value;
  final double min;
  final double max;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color _color = color ?? Theme.of(context).disabledColor;
    final double _size = size ?? 12.0;
    final double _min = min ?? 0;
    final double _max = max ?? 100;
    double _value = value;
    if (_value != null && _value < _min) _value = _min;
    if (_value != null && _value > _max) _value = _max;

    return Container(
      width: _size,
      height: _size * 0.8,
      child: Stack(children: [
        Positioned(
          width: _size,
          height: _size,
          child: Opacity(
            opacity: _value == null ? 0.5 : 1,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: _size / 10,
                    color: _color,
                  )),
            ),
          ),
        ),
        Positioned(
          width: _size,
          height: _size,
          child: Opacity(
            opacity: _value == null ? 0.5 : 1,
            child: Center(
              child: Container(
                width: _size / 5,
                height: _size / 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _color,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          height: _size,
          width: _size,
          child: _value != null
              ? Transform.rotate(
                  angle: (-130 * (pi / 180)) +
                      260 * (pi / 180) / (_max - _min) * _value,
                  child: Align(
                    alignment: const Alignment(0, -1),
                    child: Container(
                      height: _size / 2,
                      width: _size / 10,
                      color: _color,
                    ),
                  ),
                )
              : Container(),
        )
      ]),
    );
  }
}
