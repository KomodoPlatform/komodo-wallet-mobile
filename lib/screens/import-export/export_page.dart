import 'package:flutter/material.dart';
import 'package:komodo_dex/model/export_import_list_item.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/import-export/export_import_list.dart';

class ExportPage extends StatefulWidget {
  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  Map<String, String> allNotes;
  Map<String, String> selectedNotes;

  @override
  void initState() {
    Db.getAllNotes().then((value) {
      setState(() {
        allNotes = value;
        selectedNotes = Map.from(allNotes);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).exportTitle,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildNotes(),
            _buildContacts(),
          ],
        ),
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

  Widget _buildNotes() {
    if (allNotes == null) return SizedBox();

    final List<ExportImportListItem> items = [];
    allNotes.forEach((id, note) {
      items.add(ExportImportListItem(
          checked: selectedNotes.containsKey(id),
          onChange: (bool val) {
            setState(() {
              val ? selectedNotes[id] = note : selectedNotes.remove(id);
            });
          },
          child: Text(
            note,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.caption,
          )));
    });

    return ExportImportList(
      items: items,
      title: AppLocalizations.of(context).exportNotesTitle,
    );
  }

  Widget _buildContacts() {
    return ExportImportList(
      title: AppLocalizations.of(context).exportContactsTitle,
      items: [],
    );
  }
}
