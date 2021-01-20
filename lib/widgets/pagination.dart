import 'package:flutter/material.dart';

class Pagination extends StatefulWidget {
  const Pagination({
    this.total,
    this.perPage,
    this.currentPage,
    this.onChanged,
  });

  final int total;
  final int perPage;
  final int currentPage;
  final Function(int) onChanged;

  @override
  _PaginationState createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  int _perPage;
  int _currentPage;

  @override
  Widget build(BuildContext context) {
    _perPage = widget.perPage ?? 20;
    _currentPage = widget.currentPage ?? 1;
    if (widget.total == null || widget.total == 0) return SizedBox();
    if (widget.total <= _perPage) return SizedBox();

    int pages = widget.total ~/ _perPage;
    if (pages * _perPage < widget.total) pages++;

    final List<Widget> buttons = [];
    for (int i = 1; i < pages + 1; i++) {
      final Widget button = _buildButton(i);
      buttons.add(button);
    }

    final RenderBox rb = context.findRenderObject();

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('${rb.size.width}'),
          ...buttons,
        ],
      ),
    );
  }

  Widget _buildButton(int i) {
    return InkWell(
      onTap: i == _currentPage
          ? null
          : () {
              widget.onChanged(i);
            },
      child: Container(
        padding: EdgeInsets.all(2),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 40),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: i == _currentPage
                      ? Theme.of(context).accentColor.withAlpha(120)
                      : Theme.of(context).primaryColor),
              color: i == _currentPage ? null : Theme.of(context).primaryColor,
            ),
            height: 40,
            alignment: Alignment(0, 0),
            padding: EdgeInsets.all(4),
            child: Text(
              '$i',
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                color: i == _currentPage ? Theme.of(context).accentColor : null,
                fontWeight: i == _currentPage ? FontWeight.bold : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
