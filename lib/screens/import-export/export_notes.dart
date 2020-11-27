import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/widgets/import_export_selection.dart';
import 'package:path_provider/path_provider.dart';

class ExportNotesScreen extends StatefulWidget {
  @override
  _ExportNotesScreenState createState() => _ExportNotesScreenState();
}

class _ExportNotesScreenState extends State<ExportNotesScreen> {
  Future<Map<String, String>> allNotes;
  final selectedNotes = <String, bool>{};
  Map<String, String> notes;

  @override
  void initState() {
    super.initState();
    allNotes = Db.getAllNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export Notes'),
        actions: <Widget>[
          FlatButton(
            child: Text('Export'),
            onPressed: () async {
              final a = <String, String>{};
              notes.forEach((k, v) {
                if (selectedNotes[k]) {
                  a.putIfAbsent(k, () => v);
                }
              });
              print(a);
              Directory d = await getApplicationDocumentsDirectory();
              File f = File('${d.path}/a.json');
              final js = json.encode(a);
              f.writeAsStringSync(js.toString(), mode: FileMode.writeOnly);
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
          future: allNotes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            else if (!snapshot.hasData) return SizedBox();
            notes = snapshot.data;
            final widgets = <Widget>[];
            notes.forEach((k, v) {
              selectedNotes.putIfAbsent(k, () => true);
              widgets.add(ImportExportSelection(
                title: k,
                content: v,
                selected: selectedNotes[k],
                changedCallback: (val) {
                  setState(() {
                    selectedNotes[k] = val;
                  });
                },
              ));
            });
            return Column(
              children: widgets,
            );
          }),
    );
  }
}
