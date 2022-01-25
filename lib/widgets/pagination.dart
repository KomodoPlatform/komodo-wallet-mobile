import 'package:flutter/material.dart';

class Pagination extends StatefulWidget {
  const Pagination({
    this.total,
    this.perPage,
    this.currentPage,
    this.buttonSize,
    this.buttonMargin,
    this.onChanged,
  });

  final int total;
  final int perPage;
  final int currentPage;
  final double buttonSize;
  final double buttonMargin;
  final Function(int) onChanged;

  @override
  _PaginationState createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  int _perPage;
  int _currentPage;
  double _buttonSize;
  double _buttonMargin;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void didUpdateWidget(covariant Pagination oldWidget) {
    if (oldWidget.currentPage != widget.currentPage) {
      _scrollTo(widget.currentPage);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    _perPage = widget.perPage ?? 20;
    _currentPage = widget.currentPage ?? 1;
    _buttonSize = widget.buttonSize ?? 40;
    _buttonMargin = widget.buttonMargin ?? 2;

    if (widget.total == null || widget.total == 0) return SizedBox();
    if (widget.total <= _perPage) return SizedBox();

    int pages = widget.total ~/ _perPage;
    if (pages * _perPage < widget.total) pages++;

    final List<Widget> buttons = [];
    for (int i = 1; i < pages + 1; i++) {
      final Widget button = _buildButton(i);
      buttons.add(button);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollCtrl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ...buttons,
        ],
      ),
    );
  }

  Widget _buildButton(int i) {
    final int first = (i - 1) * _perPage + 1;
    int last = i * _perPage;
    if (last > widget.total) last = widget.total;

    return InkWell(
      onTap: i == _currentPage ? null : () => widget.onChanged(i),
      child: Container(
        padding: EdgeInsets.all(_buttonMargin),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: _buttonSize),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: i == _currentPage
                      ? Theme.of(context).colorScheme.secondary.withAlpha(120)
                      : Theme.of(context).primaryColor),
              color: i == _currentPage ? null : Theme.of(context).primaryColor,
            ),
            height: _buttonSize,
            alignment: Alignment(0, 0),
            padding: EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$i',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    color: i == _currentPage
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                    fontWeight: i == _currentPage ? FontWeight.bold : null,
                  ),
                ),
                SizedBox(height: 2),
                Row(children: [
                  Text(
                    '$first-$last',
                    style: TextStyle(
                      fontSize: 7,
                      color: i == _currentPage
                          ? Theme.of(context).colorScheme.secondary
                          : null,
                      fontWeight: i == _currentPage ? FontWeight.bold : null,
                    ),
                  )
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scrollTo(int i) {
    final RenderBox rb = context.findRenderObject();
    if (!rb.hasSize) return;

    double targetPosition = (i - 1) * (_buttonSize + _buttonMargin * 2) -
        rb.size.width / 2 +
        (_buttonSize + _buttonMargin * 2) / 2;
    if (targetPosition < 0) targetPosition = 0;
    if (targetPosition > _scrollCtrl.position.maxScrollExtent)
      targetPosition = _scrollCtrl.position.maxScrollExtent;

    _scrollCtrl.animateTo(
      targetPosition,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }
}
