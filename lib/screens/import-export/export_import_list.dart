import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/export_import_list_item.dart';

class ExportImportList extends StatefulWidget {
  const ExportImportList({
    this.title,
    this.items,
  });

  final String title;
  final List<ExportImportListItem> items;

  @override
  _ExportImportListState createState() => _ExportImportListState();
}

class _ExportImportListState extends State<ExportImportList> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !_haveItems(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Theme.of(context).canvasColor,
            child: Opacity(
              opacity: _haveItems() ? 1 : 0.2,
              child: CheckboxListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                controlAffinity: ListTileControlAffinity.leading,
                value: _areAllItemsChecked(),
                onChanged: (bool val) {
                  _setAllItems(val);
                },
                title: Row(
                  children: [
                    Text(widget.title),
                    Text(
                      ' (${_getCheckedQtt()}/${_haveItems() ? widget.items.length : '0'})',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
                secondary: IconButton(
                  icon: Icon(isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ),
            ),
          ),
          if (isExpanded) _buildItems(),
        ],
      ),
    );
  }

  Widget _buildItems() {
    if (!_haveItems()) {
      return Container(
        padding: EdgeInsets.fromLTRB(24, 24, 12, 24),
        color: Theme.of(context).primaryColor,
        child: Text(
          AppLocalizations.of(context).nothingFound,
          style: Theme.of(context).textTheme.caption,
        ),
      );
    }

    final List<Widget> list = ListTile.divideTiles(
      color: Theme.of(context).dividerColor,
      tiles: widget.items.map(
        (item) => Padding(
          padding: EdgeInsets.only(left: 4),
          child: CheckboxListTile(
            value: item.checked,
            onChanged: (bool val) {
              item.onChange(val);
            },
            title: item.child,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ),
    ).toList();

    return Container(
      padding: EdgeInsets.fromLTRB(6, 12, 4, 12),
      color: Theme.of(context).canvasColor,
      child: Column(
        children: list,
      ),
    );
  }

  void _setAllItems(bool checked) {
    for (ExportImportListItem item in widget.items) {
      item.onChange(checked);
    }
  }

  bool _areAllItemsChecked() {
    if (!_haveItems()) return false;
    return _getCheckedQtt() == widget.items.length;
  }

  bool _haveItems() {
    return widget.items != null && widget.items.isNotEmpty;
  }

  int _getCheckedQtt() {
    if (!_haveItems()) return 0;

    return widget.items.where((item) => item.checked).length;
  }
}
