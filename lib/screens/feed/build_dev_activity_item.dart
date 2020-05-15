import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/build_dev_avatar.dart';
import 'package:komodo_dex/screens/feed/dev.dart';
import 'package:komodo_dex/screens/feed/dev_detail_page.dart';
import 'package:komodo_dex/utils/utils.dart';

class BuildDevActivityItem extends StatefulWidget {
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
  _BuildDevActivityItemState createState() => _BuildDevActivityItemState();
}

class _BuildDevActivityItemState extends State<BuildDevActivityItem> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.selected
          ? Theme.of(context).primaryColor
          : Theme.of(context).backgroundColor,
      child: Container(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 12),
                BuildDevAvatar(widget.dev, size: 25),
                const SizedBox(width: 12),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 200,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.selected
                            ? Theme.of(context).backgroundColor
                            : Theme.of(context).primaryColor,
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
                          Text(widget.status.message),
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
                          if (widget.onMoreTap != null) widget.onMoreTap();
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
            const SizedBox(height: 8),
            _buildDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDateTime(BuildContext context) {
    return Text(
      '${humanDate(widget.status.startTime)}',
      style: TextStyle(
          fontSize: 10, color: Theme.of(context).textTheme.caption.color),
    );
  }

  Widget _buildDetails() {
    if (!widget.selected) return Container();

    final _buttonsList = <Widget>[
      _buildDetailsButton(
        iconData: Icons.thumb_up,
        title: 'React', // TODO(yurii): localization
        onTap: () {},
      ),
      _buildDetailsButton(
        iconData: Icons.attach_money,
        title: 'Tip', // TODO(yurii): localization
        onTap: () {},
      ),
      if (widget.status.issue != null)
        _buildDetailsButton(
          iconData: Icons.error_outline,
          title: 'Issue', // TODO(yurii): localization
          onTap: () {},
        ),
    ];

    return Container(
      child: Flex(
        direction: Axis.horizontal,
        children: _buttonsList,
      ),
    );
  }

  Widget _buildDetailsButton({
    @required IconData iconData,
    @required String title,
    @required Function onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Icon(iconData,
                  size: 20, color: Theme.of(context).textTheme.caption.color),
              const SizedBox(
                height: 4,
              ),
              Text(title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.caption.color,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
