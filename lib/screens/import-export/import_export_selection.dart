import 'package:flutter/material.dart';

class ImportExportSelection extends StatefulWidget {
  const ImportExportSelection(
      {Key key, this.title, this.content, this.selected, this.changedCallback})
      : super(key: key);

  final String title;
  final String content;
  final bool selected;
  final ValueChanged<bool> changedCallback;

  @override
  _ImportExportSelectionState createState() => _ImportExportSelectionState();
}

class _ImportExportSelectionState extends State<ImportExportSelection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Text((widget.title != null && widget.title.isNotEmpty)
                    ? widget.title
                    : 'Empty'),
                const SizedBox(height: 8.0),
                Text((widget.content != null && widget.content.isNotEmpty)
                    ? widget.content
                    : 'Empty'),
              ],
            ),
          ),
          Checkbox(
            value: widget.selected,
            onChanged: widget.changedCallback,
          ),
        ],
      ),
    );
  }
}
