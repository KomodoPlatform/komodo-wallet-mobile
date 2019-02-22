import 'package:flutter/material.dart';

class PhotoHero extends StatelessWidget {
  const PhotoHero({
    Key key,
    this.onTap,
    this.width,
    this.url,
    this.radius
  }) : super(key: key);

  final VoidCallback onTap;
  final double width;
  final String url;
  final double radius;

  Widget build(BuildContext context) {
    return Hero(
      tag: url,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(url),
          ),
        ),
      ),
    );
  }
}
