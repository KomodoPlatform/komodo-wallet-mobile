import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/build_dev_avatar.dart';
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
                        _buildDateTime(context),
                        _buildStatus(),
                        _buildIssue(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildMoreButton(),
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

  Widget _buildDateTime(BuildContext context) {
    return Text(
      '${humanDate(widget.status.startTime)}',
      style: TextStyle(
          fontSize: 10, color: Theme.of(context).textTheme.caption.color),
    );
  }

  Widget _buildStatus() {
    if (widget.status.message == null) {
      return Container(width: 0,);
    }

    return Column(
      children: <Widget>[
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildStatusIcon(),
            const SizedBox(width: 4),
            Flexible(child: Text(widget.status.message)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIcon() {
    Icon _icon;
    if (widget.dev.latestStatus == widget.status &&
        widget.dev.onlineStatus == OnlineStatus.active) {
      _icon = Icon(Icons.directions_run, size: 15, color: Colors.green);
    } else {
      _icon = Icon(
        Icons.playlist_add_check,
        size: 15,
        color: Theme.of(context).disabledColor,
      );
    }

    return Container(
      padding: const EdgeInsets.only(top: 3),
      child: _icon,
    );
  }

  Widget _buildIssue() {
    if (widget.status.issue == null) return Container(width: 0);

    return Column(
      children: <Widget>[
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.error_outline,
                size: 15,
                color: Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(child: Text(widget.status.issue.title)),
          ],
        ),
      ],
    );
  }

  Widget _buildMoreButton() {
    return Column(
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
              color: Theme.of(context).disabledColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    if (!widget.selected) return Container();

    final _buttonsList = <Widget>[
      if (widget.status.issue != null)
        _buildDetailsButton(
          iconData: Icons.error_outline,
          title: 'Go to Issue', // TODO(yurii): localization
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData,
                  size: 20, color: Theme.of(context).textTheme.caption.color),
              const SizedBox(
                width: 4,
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
