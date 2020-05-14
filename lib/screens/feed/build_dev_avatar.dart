import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/devops_tab.dart';

class BuildDevAvatar extends StatelessWidget {
  const BuildDevAvatar(this.dev, {this.size = 40});

  final Dev dev;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: dev.image != null ? NetworkImage(dev.image) : null,
      backgroundColor: Theme.of(context).disabledColor,
      child: dev.image == null
          ? Icon(
              Icons.account_circle,
              size: size,
            )
          : null,
    );
  }
}
