import 'package:flutter/material.dart';
import '../../localizations.dart';

class ExportImportSuccess extends StatefulWidget {
  const ExportImportSuccess({this.title, this.items});

  final String? title;
  final Map<String, int>? items;

  @override
  _ExportImportSuccessState createState() => _ExportImportSuccessState();
}

class _ExportImportSuccessState extends State<ExportImportSuccess> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(48, 24, 48, 24),
      child: Column(
        children: [
          Text(widget.title!),
          SizedBox(height: 24),
          Table(
            columnWidths: const {
              1: IntrinsicColumnWidth(),
            },
            children: _buildItemRows(),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.okButton,
            ),
          ),
        ],
      ),
    );
  }

  List<TableRow> _buildItemRows() {
    final List<TableRow> rows = [];

    widget.items?.forEach((item, count) {
      if (count == null || count == 0) return;

      rows.add(TableRow(children: [
        Text(
          item,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        Text(
          '$count',
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ]));
    });

    return rows;
  }
}
