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
    if (widget.dev?.activity == null) return Container();
    final List<DevStatus> _activity = List.from(widget.dev.activity.reversed);

    return ListView.builder(
      reverse: true,
      shrinkWrap: true,
      itemCount: _activity.length,
      itemBuilder: (BuildContext context, int i) {
        return Container(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: BuildDevActivityItem(
              _activity[i],
              dev: widget.dev,
              selected: _activity[i].id == _selectedItemId,
            ),
        );
      },
    );
  }
}
