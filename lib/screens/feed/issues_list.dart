import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/build_issue_item.dart';
import 'package:provider/provider.dart';

class IssuesList extends StatefulWidget {
  const IssuesList({this.filterDevId});

  final String filterDevId;

  @override
  _IssuesListState createState() => _IssuesListState();
}

class _IssuesListState extends State<IssuesList> {
  @override
  Widget build(BuildContext context) {
    final List<Issue> _issues = _getIssues();
    if (_issues == null) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        itemCount: _issues.length,
        itemBuilder: (BuildContext context, int i) {
          return BuildIssueItem(_issues[i]);
        });
  }

  List<Issue> _getIssues() {
    final List<Issue> _all = Provider.of<FeedProvider>(context).getIssues();

    if (_all == null) return null;
    if (widget.filterDevId == null) return _all;

    return _all
        .where((Issue issue) => issue.devs.contains(widget.filterDevId))
        .toList();
  }
}
