import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/issues_list.dart';

class IssuesTab extends StatefulWidget {
  @override
  _IssuesTabState createState() => _IssuesTabState();
}

class _IssuesTabState extends State<IssuesTab> {
  @override
  Widget build(BuildContext context) {
    return const IssuesList();
  }
}