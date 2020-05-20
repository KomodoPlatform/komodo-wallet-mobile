import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/build_dev_avatar.dart';
import 'package:provider/provider.dart';

class BuildIssueItem extends StatefulWidget {
  const BuildIssueItem(this.issue);

  final Issue issue;
  @override
  _BuildIssueItemState createState() => _BuildIssueItemState();
}

class _BuildIssueItemState extends State<BuildIssueItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
          top: 20,
          bottom: 20,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.error_outline),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.issue.title),
                  _buildContributors(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributors() {
    final List<String> _contributorsIds = widget.issue.devs;
    if (_contributorsIds == null || _contributorsIds.isEmpty) {
      return Container();
    }

    final FeedProvider _feedProvider = Provider.of<FeedProvider>(context);
    final List<Widget> _devList = [];

    for (int i = 0; i < _contributorsIds.length; i++) {
      final Dev _dev = _feedProvider.getDev(_contributorsIds[i]);

      _devList.add(Container(
        padding: const EdgeInsets.only(right: 4, bottom: 4),
        child: BuildDevAvatar(_dev, size: 16),
      ));
    }

    return Column(
      children: <Widget>[
        const SizedBox(height: 5),
        Wrap(  
          children: _devList.toList(),
        ),
      ],
    );
  }
}
