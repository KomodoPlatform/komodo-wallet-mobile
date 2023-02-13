// Padded dialog which takes a title widget and list of body widgets.
// Scrollable area with "Close" button at the bottom.
// Show close button as a footer.
// Boolean to specify if user must scroll to bottom before closing dialog.

import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';

class ScrollableDialog extends StatefulWidget {
  const ScrollableDialog({
    Key? key,
    this.title,
    required this.children,
    this.padding = const EdgeInsets.all(16.0),
    this.verticalButtons,
    this.mustScrollToBottom = false,
  })  :
        // If mustScrollToBottom is true, verticalButtons should be provided since
        // there the purpose of specifying mustScrollToBottom is to control
        // when verticalButtons are shown.
        assert(
          (!mustScrollToBottom) ||
              (mustScrollToBottom && verticalButtons != null),
          'If mustScrollToBottom is true, verticalButtons should be provided since '
          'the buttons will only be shown once the user has scrolled to the bottom.',
        ),
        super(key: key);

  /// The title widget, if any, keep it null for no title. Title is shown
  /// above the scrollable area.
  final Widget? title;

  /// Same as the children you would use on SimpleDialog
  final List<Widget> children;

  /// Padding for dialog's contnents
  final EdgeInsets padding;

  /// The List of vertical buttons. If mustScrollToBottom is true, this is only
  /// shown once the user has scrolled to the bottom.
  final Widget? verticalButtons;

  /// Whether user must scroll to bottom before the vertical buttons are shown.
  /// NB: If using this widget in a dialog with mustScrollToBottom set to true
  /// remember to set the dialog's barrierDismissible to false.
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

    // Run scroll listener even on first frame. This is to take into
    // consideration if the scrollable contents are too short to scroll.
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollListener();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // If the content is too short to scroll then we consider it scrolled to
    // the bottom.
    if (_scrollController.position.maxScrollExtent == 0.0) {
      setState(() {
        _isScrolledToBottom = true;
      });

      return;
    }

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
            _buildFooter(),
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
        child: widget.title!,
        style: Theme.of(context).textTheme.headline6!,
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
              AppLocalizations.of(context)!.accepteula,
              style: TextStyle(
                color: Colors.grey,
              ),
            )
          : widget.verticalButtons,
    );
  }
}
