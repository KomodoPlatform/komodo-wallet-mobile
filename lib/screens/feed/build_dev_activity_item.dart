import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/build_dev_avatar.dart';
import 'package:komodo_dex/screens/feed/dev.dart';
import 'package:komodo_dex/utils/utils.dart';

class BuildDevActivityItem extends StatelessWidget {
  const BuildDevActivityItem(
    this.status, {
    @required this.dev,
    this.selected = false,
    this.onToggle,
  });

  final DevStatus status;
  final Dev dev;
  final bool selected;
  final Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BuildDevAvatar(dev, size: 25),
          const SizedBox(width: 12),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 200,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.only(
                  top: 8,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildStatusDateTime(context),
                    const SizedBox(height: 4),
                    Text(status.message),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Opacity(opacity: 0.5, child: Icon(Icons.more_vert, size: 18,)),
        ],
      ),
    );
  }

  Widget _buildStatusDateTime(BuildContext context) {
    return Text(
      '${humanDate(status.startTime)}',
      style: TextStyle(
          fontSize: 10, color: Theme.of(context).textTheme.caption.color),
    );
  }
}
