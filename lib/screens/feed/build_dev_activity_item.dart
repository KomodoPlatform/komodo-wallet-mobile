import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/build_dev_avatar.dart';
import 'package:komodo_dex/screens/feed/dev.dart';
import 'package:komodo_dex/utils/utils.dart';

class BuildDevActivityItem extends StatelessWidget {
  const BuildDevActivityItem(
    this.status, {
    @required this.dev,
    this.selected = false,
    this.onMoreTap,
  });

  final DevStatus status;
  final Dev dev;
  final bool selected;
  final Function onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Theme.of(context).primaryColorDark : Theme.of(context).backgroundColor,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 12),
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
            Column(
              children: <Widget>[
                const SizedBox(height: 2),
                Container(
                  height: 40,
                  width: 40,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      if (onMoreTap != null) onMoreTap();
                    },
                    child: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
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
