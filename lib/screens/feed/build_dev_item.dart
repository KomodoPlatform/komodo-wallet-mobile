import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/build_dev_avatar.dart';
import 'package:komodo_dex/screens/feed/dev.dart';
import 'package:komodo_dex/screens/feed/dev_detail_page.dart';

class BuildDevItem extends StatefulWidget {
  const BuildDevItem(
    this.dev, {
    this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  final Dev dev;
  final Function onTap;
  final Function onLongPress;
  final bool selected;

  @override
  _BuildDevItemState createState() => _BuildDevItemState();
}

class _BuildDevItemState extends State<BuildDevItem> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.selected
          ? Theme.of(context).backgroundColor
          : Theme.of(context).primaryColor,
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          width: 1,
          color: widget.selected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
        ))),
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                if (widget.onTap != null) widget.onTap();
              },
              onLongPress: () {
                if (widget.onLongPress != null) widget.onLongPress();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    BuildDevAvatar(
                      widget.dev,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.dev.name,
                            style: TextStyle(
                              color: widget.selected
                                  ? Theme.of(context).accentColor
                                  : Theme.of(context).textTheme.body1.color,
                              //fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildCurrentStatus(),
                          const SizedBox(height: 4),
                          _buildCurrentIssue(),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ),
            _buildDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails() {
    if (!widget.selected) return Container();

    final DevStatus _latest = widget.dev.latestStatus;
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
      if (_latest?.issue != null)
        _buildDetailsButton(
          iconData: Icons.error_outline,
          title: 'Issue', // TODO(yurii): localization
          onTap: () {},
        ),
      _buildDetailsButton(
        iconData: Icons.list,
        title: 'Activity', // TODO(yurii): localization
        onTap: () {
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) =>
                    DevDetailsPage(dev: widget.dev)),
          );
        },
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

  Widget _buildCurrentStatus() {
    final OnlineStatus _online = widget.dev.onlineStatus;
    final String _message = widget.dev.currentStatusMessage;

    if (_message.isEmpty) return Container();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.only(right: 5, top: 1),
            child: Icon(
              _online == OnlineStatus.active
                  ? Icons.playlist_add_check
                  : Icons.access_time,
              size: 15,
              color: Theme.of(context).textTheme.caption.color,
            )),
        Expanded(
          child: Text(
            _message,
            overflow: widget.selected ? null : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.caption.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentIssue() {
    final DevStatus _latest = widget.dev.latestStatus;
    if (_latest?.issue == null) return Container();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.only(right: 5, top: 1),
            child: Icon(
              Icons.error_outline,
              size: 15,
              color: Theme.of(context).textTheme.caption.color,
            )),
        Expanded(
          child: Text(
            _latest.issue.title,
            overflow: widget.selected ? null : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.caption.color,
            ),
          ),
        ),
      ],
    );
  }
}
