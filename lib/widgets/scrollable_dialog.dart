// Padded dialog which takes a title widget and list of body widgets.
// Scrollable area with "Close" button at the bottom.
// Show close button as a footer.
// Boolean to specify if user must scroll to bottom before closing dialog.

import 'package:flutter/material.dart';

class ScrollableDialog extends StatefulWidget {
  const ScrollableDialog({
    Key key,
    this.title,
    @required this.children,
    this.padding = const EdgeInsets.all(16.0),
    this.verticalButtons,
    this.mustScrollToBottom = false,
  }) : super(key: key);

  /// The title widget, if any, keep it null for no title
  final Widget title;

  /// Same as the children you would use on SimpleDialog
  final List<Widget> children;

  /// Padding for dialog's contnents
  final EdgeInsets padding;

  /// The List of vertical button, if any, keep it null for no vertical buttons
  final Widget verticalButtons;

  /// Whether user must scroll to bottom before the "Close" button shows.
  final bool mustScrollToBottom;

  @override
  _ScrollableDialogState createState() => _ScrollableDialogState();
}

class _ScrollableDialogState extends State<ScrollableDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isScrolledToBottom = true;
      });
    }
    if (_scrollController.offset <=
            _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _isScrolledToBottom = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: widget.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(),
            _buildBody(),
            if (widget.verticalButtons != null) _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    if (widget.title == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DefaultTextStyle(
        child: widget.title,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: Scrollbar(
        controller: _scrollController,
        isAlwaysShown: true,
        child: ListView(
          controller: _scrollController,
          children: widget.children,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    if (widget.verticalButtons == null) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: (widget.mustScrollToBottom && !_isScrolledToBottom)
          ? Text(
              // TODO: Localize
              'Scroll to bottom to close',
              style: TextStyle(
                color: Colors.grey,
              ),
            )
          : ((widget.mustScrollToBottom && _isScrolledToBottom) ||
                  !widget.mustScrollToBottom)
              ? widget.verticalButtons
              : Container(),
    );
  }
}
