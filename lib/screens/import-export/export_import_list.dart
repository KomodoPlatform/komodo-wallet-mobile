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
              child: Row(
                children: [
                  Checkbox(
                    value: _areAllItemsChecked(),
                    onChanged: (bool val) {
                      _setAllItems(val);
                    },
                  ),
                  Expanded(
                      child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(widget.title),
                      Text(
                        ' (${_getCheckedQtt()}/${_haveItems() ? widget.items.length : '0'})',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  )),
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Icon(isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down),
                    ),
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                  ),
                ],
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

    final List<Widget> list = [];
    for (ExportImportListItem item in widget.items) {
      list.add(
        Padding(
          padding: EdgeInsets.only(
            top: 4,
            bottom: 4,
          ),
          child: Row(
            children: [
              Checkbox(
                  value: item.checked,
                  onChanged: (bool val) {
                    item.onChange(val);
                  }),
              Expanded(
                  child: Container(
                padding: EdgeInsets.only(right: 12),
                child: item.child,
              )),
            ],
          ),
        ),
      );
      list.add(Divider());
    }

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
