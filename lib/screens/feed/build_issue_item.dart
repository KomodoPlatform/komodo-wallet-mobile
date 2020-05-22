import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/build_dev_avatar.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class BuildIssueItem extends StatefulWidget {
  const BuildIssueItem(this.issue);

  final Issue issue;
  @override
  _BuildIssueItemState createState() => _BuildIssueItemState();
}

class _BuildIssueItemState extends State<BuildIssueItem> {
  FeedProvider _feedProvider;

  @override
  Widget build(BuildContext context) {
    _feedProvider = Provider.of<FeedProvider>(context);

    return Card(
      color: Theme.of(context).primaryColor,
      elevation: 4,
      margin: const EdgeInsets.only(left: 12, right: 12, top: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(3),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.error_outline,
                  size: 30, color: Theme.of(context).disabledColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.issue.title,
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                    _buildLatestActivityDate(),
                    _buildContributors(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestActivityDate() {
    final List<Dev> _devOps = _feedProvider.getDevOps();
    int _latestActivity = 0;
    for (Dev dev in _devOps) {
      if (dev.activity == null || dev.activity.isEmpty) continue;
      for (DevStatus status in dev.activity) {
        if (status.issue == null || status.issue.id != widget.issue.id) {
          continue;
        }

        if (status.startTime != null && status.startTime > _latestActivity) {
          _latestActivity = status.startTime;
        }
        if (status.endTime != null && status.endTime > _latestActivity) {
          _latestActivity = status.endTime;
        }
      }
    }

    if (_latestActivity == null) return Container(width: 0);

    return Column(
      children: <Widget>[
        const SizedBox(height: 6),
        Text(
          'Latest activity: ${humanDate(_latestActivity)}', // TODO(yurii): localization
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).disabledColor,
          ),
        ),
      ],
    );
  }

  Widget _buildContributors() {
    final List<String> _contributorsIds = widget.issue.devs;
    if (_contributorsIds == null || _contributorsIds.isEmpty) {
      return Container();
    }

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
        const SizedBox(height: 6),
        Wrap(
          children: [
            Text('Contributors: ',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).disabledColor,
                )), // TODO(yurii): localization
            ..._devList,
          ],
        ),
      ],
    );
  }
}
