import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/feed/devops/activity_item_button.dart';
import 'package:komodo_dex/screens/feed/devops/build_dev_avatar.dart';
import 'package:komodo_dex/screens/feed/devops/dev_detail_page.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class BuildIssueActivityItem extends StatefulWidget {
  const BuildIssueActivityItem(
    this.status, {
    this.selected = false,
    this.onMoreTap,
  });

  final DevStatus status;
  final bool selected;
  final Function onMoreTap;

  @override
  _BuildIssueActivityItemState createState() => _BuildIssueActivityItemState();
}

class _BuildIssueActivityItemState extends State<BuildIssueActivityItem> {
  Dev _dev;

  @override
  Widget build(BuildContext context) {
    final FeedProvider _feedProvider = Provider.of<FeedProvider>(context);
    _dev = widget.status.devId == null
        ? null
        : _feedProvider.getDev(widget.status.devId);

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
                _dev == null ? Container() : BuildDevAvatar(_dev, size: 25),
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
      return Container(
        width: 0,
      );
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
    if (_dev?.latestStatus == widget.status &&
        _dev?.onlineStatus == OnlineStatus.active) {
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
      if (_dev != null)
        BuildActivityItemDetailsButton(
            iconData: Icons.playlist_add_check,
            title: 'View Activity',
            onTap: () {
              Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => DevDetailsPage(
                          dev: _dev,
                        )),
              );
            }),
    ];

    return Container(
      child: Flex(
        direction: Axis.horizontal,
        children: _buttonsList,
      ),
    );
  }
}
