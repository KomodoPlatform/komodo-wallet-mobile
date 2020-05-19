import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/build_dev_avatar.dart';
import 'package:komodo_dex/screens/feed/dev_activity_list.dart';
import 'package:komodo_dex/screens/feed/issues_list.dart';
import 'package:komodo_dex/utils/utils.dart';

class DevDetailsPage extends StatefulWidget {
  const DevDetailsPage({
    this.dev,
  });

  final Dev dev;

  @override
  _DevDetailsPageState createState() => _DevDetailsPageState();
}

class _DevDetailsPageState extends State<DevDetailsPage> {
  int _activeTab = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            BuildDevAvatar(widget.dev, size: 35),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.dev.name),
                const SizedBox(height: 2),
                _buildCurrentStatus(context),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildPageContent()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _activeTab,
          onTap: (int i) {
            if (i == 2) {
              setState(() {
                _activeTab = 2;
              });
            }
            if (i == 3) {
              setState(() {
                _activeTab = 3;
              });
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.thumb_up),
              title: const Text('React'),
            ), // TODO(yurii): localization
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              title: const Text('Tip'),
            ), // TODO(yurii): localization
            BottomNavigationBarItem(
              icon: Icon(Icons.playlist_add_check),
              title: const Text('Activity'),
            ), // TODO(yurii): localization
            BottomNavigationBarItem(
              icon: Icon(Icons.error_outline),
              title: const Text('Issues'),
            ), // TODO(yurii): localization
          ]),
    );
  }

  Widget _buildCurrentStatus(BuildContext context) {
    final TextStyle _textStyle = TextStyle(
      color: Theme.of(context).highlightColor,
      fontWeight: FontWeight.normal,
      fontSize: 13,
    );

    switch (widget.dev.onlineStatus) {
      case OnlineStatus.active:
        {
          return Text('Active now', style: _textStyle);
        }
      case OnlineStatus.inactive:
        {
          return Text(
            'Last active: ${humanDate(widget.dev.latestStatus.endTime)}',
            style: _textStyle,
          );
        }
      default:
        return Container();
    }
  }

  Widget _buildPageContent() {
    switch (_activeTab) {
      case 2: return DevActivityList(widget.dev);
      case 3: return IssuesList(filterDevId: widget.dev.id);
      default: return Container();
    }
  }
}
