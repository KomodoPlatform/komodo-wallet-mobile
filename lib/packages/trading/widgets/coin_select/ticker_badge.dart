import 'package:flutter/material.dart';

class TickerBadge extends StatelessWidget {
  const TickerBadge({
    Key key,
    @required this.coinImageProvider,
    this.chainImageProvider,
  }) : super(key: key);

  const TickerBadge.placeholder({
    Key key,
  })  : chainImageProvider = null,
        coinImageProvider = null;

  final ImageProvider chainImageProvider;
  final ImageProvider coinImageProvider;

  @override
  Widget build(BuildContext context) {
    final isEmpty = coinImageProvider == null;
    return Container(
      padding: EdgeInsets.zero,
      color: Colors.transparent,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            LimitedBox(
              maxWidth: 24,
              maxHeight: 24,
              child: CircleAvatar(
                minRadius: 12,
                foregroundImage: isEmpty ? null : coinImageProvider,
                backgroundColor: isEmpty
                    ? Theme.of(context).inputDecorationTheme.fillColor
                    : Colors.transparent,
                child: isEmpty
                    ? Icon(
                        Icons.attach_money,
                        color:
                            Theme.of(context).iconTheme.color.withOpacity(0.5),
                      )
                    : null,
              ),
            ),
            if (chainImageProvider != null && !isEmpty)
              Positioned(
                top: -3,
                right: -3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54.withOpacity(0.2),
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ),
                    ],
                    shape: BoxShape.circle,
                  ),
                  child: Image(
                    image: chainImageProvider,
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
