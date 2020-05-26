import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/issues/issue_activity_list.dart';

class IssueDetailPage extends StatefulWidget {
  const IssueDetailPage(this.issue);

  final Issue issue;
  @override
  _IssueDetailPageState createState() => _IssueDetailPageState();
}

class _IssueDetailPageState extends State<IssueDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Issue #${widget.issue.id}'),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 10, right: 12, bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.issue.title,
                        style: Theme.of(context).textTheme.title.copyWith(
                            fontWeight: FontWeight.normal, fontSize: 25),
                      ),
                    ),
                  ],
                ),
              ),
              IssueActivityList(widget.issue),
            ],
          ),
        ),
      ),
    );
  }
}
