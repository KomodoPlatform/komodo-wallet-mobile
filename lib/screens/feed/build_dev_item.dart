import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/devops_tab.dart';

class BuildDevItem extends StatelessWidget {
  const BuildDevItem(this.dev);

  final Dev dev;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(dev.avatar),
      ),
      title: Text(dev.name),
      subtitle: Container(),
    );
  }
}
