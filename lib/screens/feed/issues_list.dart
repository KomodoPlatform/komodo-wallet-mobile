import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';

class IssuesList extends StatelessWidget {
  const IssuesList({this.filterDevId});

  final String filterDevId;

  @override
  Widget build(BuildContext context) {
    List<Issue> _issues = _getIssues();
    return Container();
  }

  List<Issue> _getIssues() {
    return [];
  }
}
