import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/build_dev_avatar.dart';
import 'package:komodo_dex/screens/feed/dev.dart';
import 'package:komodo_dex/screens/feed/dev_activity_list.dart';
import 'package:komodo_dex/utils/utils.dart';

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(dev.name),
                const SizedBox(height: 2),
                _buildCurrentStatus(context),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: DevActivityList(dev)),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus(BuildContext context) {
    final TextStyle _textStyle = TextStyle(
      color: Theme.of(context).highlightColor,
      fontWeight: FontWeight.normal,
      fontSize: 13,
    );

    switch (dev.onlineStatus) {
      case OnlineStatus.active:
        {
          return Text('Active now', style: _textStyle);
        }
      case OnlineStatus.inactive:
        {
          return Text(
            'Last active: ${humanDate(dev.latestStatus.endTime)}',
            style: _textStyle,
          );
        }
      default:
        return Container();
    }
  }
}
