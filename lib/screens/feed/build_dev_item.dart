import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/feed/dev_detail_page.dart';
import 'package:komodo_dex/screens/feed/devops_tab.dart';

class BuildDevItem extends StatefulWidget {
  const BuildDevItem(this.dev, {this.onToggle, this.selected = false});

  final Dev dev;
  final Function(bool) onToggle;
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
                if (widget.onToggle != null) widget.onToggle(!widget.selected);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: widget.dev.image != null
                          ? NetworkImage(widget.dev.image)
                          : null,
                      backgroundColor: Theme.of(context).disabledColor,
                      child: widget.dev.image == null
                          ? Icon(
                              Icons.account_circle,
                              size: 40,
                            )
                          : null,
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
                    const SizedBox(width: 12),
                    _buildOnlineStatus(),
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

    final DevStatus _latest = _getLatestStatus();
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
    final OnlineStatus _online = _getOnlineStatus();
    final String _message = _getCurrentStatusMessage();

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
    final DevStatus _latest = _getLatestStatus();
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

  Widget _buildOnlineStatus() {
    Color color;
    Color borderColor;

    switch (_getOnlineStatus()) {
      case OnlineStatus.active:
        {
          color = Colors.green;
          borderColor = Colors.green;
          break;
        }
      case OnlineStatus.inactive:
        {
          color = const Color.fromRGBO(201, 201, 201, 1);
          borderColor = const Color.fromRGBO(201, 201, 201, 1);
          break;
        }
      case OnlineStatus.unknown:
        {
          color = Colors.transparent;
          borderColor = const Color.fromRGBO(201, 201, 201, 1);
          break;
        }
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(width: 1, color: borderColor),
      ),
    );
  }

  OnlineStatus _getOnlineStatus() {
    final DevStatus _latest = _getLatestStatus();
    if (_latest == null) return OnlineStatus.unknown;

    switch (_latest.endTime) {
      case null:
        {
          return OnlineStatus.active;
        }
      default:
        {
          return OnlineStatus.inactive;
        }
    }
  }

  String _getCurrentStatusMessage() {
    final DevStatus _latest = _getLatestStatus();
    if (_latest == null) return '';

    switch (_latest.endTime) {
      case null:
        {
          return _latest.message ?? 'Active now'; // TODO(yurii): localization
        }
      default:
        {
          return 'Last active: ${DateTime.fromMillisecondsSinceEpoch(_latest.endTime)}'; // TODO(yurii): localization
        }
    }
  }

  DevStatus _getLatestStatus() {
    final List<DevStatus> _sortedHistory =
        _getSortedHistory(widget.dev.statusHistory);

    if (_sortedHistory == null || _sortedHistory.isEmpty) return null;

    return _sortedHistory[0];
  }

  List<DevStatus> _getSortedHistory(List<DevStatus> history) {
    final List<DevStatus> _sorted = history;
    if (_sorted == null) return null;
    if (_sorted.isEmpty) return _sorted;

    _sorted.sort((a, b) {
      if (a.startTime < b.startTime) return 1;
      if (a.startTime > b.startTime) return -1;
      return 0;
    });

    return _sorted;
  }
}
