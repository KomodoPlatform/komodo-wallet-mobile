import 'package:flutter/material.dart';

class PhotoHero extends StatelessWidget {
  const PhotoHero({Key key, this.onTap, this.width, this.tag, this.radius})
      : super(key: key);

  final VoidCallback onTap;
  final double width;
  final String tag;
  final double radius;

  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: CircleAvatar(
            radius: radius,
            backgroundImage: AssetImage(tag),
          ),
        ),
      ),
    );
  }
}
