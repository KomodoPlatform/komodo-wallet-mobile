import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/issues/build_issue_activity_item.dart';
import 'package:provider/provider.dart';

class IssueActivityList extends StatefulWidget {
  const IssueActivityList(this.issue);

  final Issue issue;

  @override
  _IssueActivityListState createState() => _IssueActivityListState();
}

class _IssueActivityListState extends State<IssueActivityList> {
  String _selectedStatus; // 'devId-statusId'

  @override
  Widget build(BuildContext context) {
    final FeedProvider _feedProvider = Provider.of<FeedProvider>(context);
    final List<Dev> _devOps = _feedProvider.getDevOps();

    List<DevStatus> _timeLine = [];
    for (Dev _dev in _devOps) {
      if (_dev.activity == null || _dev.activity.isEmpty) continue;

      for (DevStatus _status in _dev.activity) {
        if (_status.issue == null || _status.issue.id != widget.issue.id)
          continue;

        _status.devId = _dev.id;
        _timeLine.add(_status);
      }
    }

    _timeLine = _feedProvider.sortTimeLine(_timeLine);

    return Container(
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _timeLine.length,
          itemBuilder: (BuildContext context, int i) {
            final bool _isSelected =
                _selectedStatus == '${_timeLine[i].devId}-${_timeLine[i].id}';
            return BuildIssueActivityItem(
              _timeLine[i],
              selected: _isSelected,
              onMoreTap: () {
                setState(() {
                  _selectedStatus = _isSelected
                      ? null
                      : '${_timeLine[i].devId}-${_timeLine[i].id}';
                });
              },
            );
          }),
    );
  }
}
