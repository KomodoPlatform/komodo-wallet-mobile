//              Directory d = await getApplicationDocumentsDirectory();
//            File f = File('${d.path}/a.json');

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/widgets/import_export_selection.dart';
import 'package:path_provider/path_provider.dart';

class ImportNotesScreen extends StatefulWidget {
  @override
  _ImportNotesScreenState createState() => _ImportNotesScreenState();
}

class _ImportNotesScreenState extends State<ImportNotesScreen> {
  Future<Map<String, String>> allNotes;
  final selectedNotes = <String, bool>{};
  Map<String, String> notes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() async {
      Directory d = await getApplicationDocumentsDirectory();
      File f = File('${d.path}/a.json');
      String str = f.readAsStringSync();
      final dynamic j = json.decode(str);
      final a = Map<String, String>.from(j);
      setState(() {
        allNotes = Future.delayed(Duration(seconds: 5), () => a);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Notes'),
        actions: <Widget>[
          FlatButton(
            child: Text('Import'),
            onPressed: () async {
              final a = <String, String>{};
              notes.forEach((k, v) {
                if (selectedNotes[k]) {
                  a.putIfAbsent(k, () => v);
                }
              });
              print(a);
              await Db.addAllNotes(a);
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
