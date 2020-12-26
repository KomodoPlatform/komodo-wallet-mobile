import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';

class ExportPage extends StatefulWidget {
  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  bool isNotesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).exportTitle,
        ),
      ),
      body: ListView(
        children: [
          _buildHeader(),
          ..._buildNotes(),
          ..._buildContacts(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
      child: Text(AppLocalizations.of(context).exportDesc,
          style: TextStyle(
            height: 1.3,
            color: Theme.of(context).disabledColor,
          )),
    );
  }

  List<Widget> _buildNotes() {
    final List<Widget> list = [
      Container(
        color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            Checkbox(
              value: _isAllNotesSelected(),
              onChanged: (bool val) {},
            ),
            Expanded(
                child: Text(AppLocalizations.of(context).exportNotesTitle)),
            InkWell(
              child: isNotesExpanded
                  ? Icon(Icons.keyboard_arrow_up)
                  : Icon(Icons.keyboard_arrow_down),
              onTap: () {
                setState(() {
                  isNotesExpanded = !isNotesExpanded;
                });
              },
            ),
          ],
        ),
      ),
    ];
    return list;
  }

  bool _isAllNotesSelected() {
    return false;
  }

  List<Widget> _buildContacts() {
    final List<Widget> list = [];
    return list;
  }
}
