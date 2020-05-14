import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/dev.dart';

class BuildOnlineStatus extends StatelessWidget {
  const BuildOnlineStatus(this.dev, {this.size = 10});

  final Dev dev;
  final double size;

  @override
  Widget build(BuildContext context) {
    Color color;
    Color borderColor;

    switch (dev.onlineStatus) {
      case OnlineStatus.active:
        {
          color = Colors.green;
          borderColor = Colors.green;
          break;
        }
      case OnlineStatus.inactive:
        {
          color = const Color.fromRGBO(201, 201, 201, 1);
          borderColor = const Color.fromRGBO(201, 201, 201, 1);
          break;
        }
      case OnlineStatus.unknown:
        {
          color = Colors.transparent;
          borderColor = const Color.fromRGBO(201, 201, 201, 1);
          break;
        }
    }

    return Container(
      padding: EdgeInsets.all(size / 5),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(width: size / 10, color: borderColor),
        ),
      ),
    );
  }
}
