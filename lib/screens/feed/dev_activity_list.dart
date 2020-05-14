import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/build_dev_activity_item.dart';
import 'package:komodo_dex/screens/feed/dev.dart';

class DevActivityList extends StatefulWidget {
  const DevActivityList(this.dev);

  final Dev dev;

  @override
  _DevActivityListState createState() => _DevActivityListState();
}

class _DevActivityListState extends State<DevActivityList> {
  String _selectedItemId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.dev.activity.length,
      itemBuilder: (BuildContext context, int i) {
        return BuildDevActivityItem(
          widget.dev.activity[i],
          dev: widget.dev,
          selected: widget.dev.activity[i].id == _selectedItemId,
        );
      },
    );
  }
}
