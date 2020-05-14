import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/build_dev_avatar.dart';
import 'package:komodo_dex/screens/feed/dev.dart';
import 'package:komodo_dex/screens/feed/dev_activity_list.dart';

class DevDetailsPage extends StatelessWidget {
  const DevDetailsPage({
    this.dev,
  });

  final Dev dev;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            BuildDevAvatar(dev, size: 35),
            const SizedBox(width: 12),
            Text(dev.name),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                DevActivityList(dev),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
