import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/devops/build_dev_activity_item.dart';

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
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      reverse: true,
      shrinkWrap: true,
      itemCount: _activity.length,
      itemBuilder: (BuildContext context, int i) {
        final bool _isSelected = _selectedItemId == _activity[i].id;

        return BuildDevActivityItem(
            _activity[i],
            dev: widget.dev,
            selected: _activity[i].id == _selectedItemId,
            onMoreTap: () {
              setState(() {
              _selectedItemId = _isSelected ? null : _activity[i].id;
              });
            },
          );
      },
    );
  }
}
