import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/widgets/import_export_selection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:aes_crypt/aes_crypt.dart';

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
        title: const Text('Export Notes'),
        actions: <Widget>[
          FlatButton(
            child: const Text('Export'),
            onPressed: () async {
              final pass = await showDialog<String>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    final passController = TextEditingController();
                    return SimpleDialog(
                      title: const Text('Type encryption key'),
                      children: <Widget>[
                        TextField(
                          controller: passController,
                        ),
                        const Divider(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FlatButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            FlatButton(
                              onPressed: () =>
                                  Navigator.pop(context, passController.text),
                              child: const Text('Ok'),
                            ),
                          ],
                        ),
                      ],
                    );
                  });
              if (pass == null) return;
              final crypt = AesCrypt(pass);

              final n = <String, String>{};
              notes.forEach((k, v) {
                if (selectedNotes[k]) {
                  n.putIfAbsent(k, () => v);
                }
              });
              print(n);

              final d = await getApplicationDocumentsDirectory();
              final js = json.encode(n);
              final tmpFilePath = '${d.path}/notes_encrypt.tmp';
              await File(tmpFilePath).delete();
              await crypt.encryptTextToFile(js, tmpFilePath);
              final f2 = File(tmpFilePath);
              final bytes = await f2.readAsBytes();
              final b64 = base64.encode(bytes);
              final r = <String, dynamic>{
                'version': 1,
                'db': b64,
              };
              final rjs = json.encode(r);
              print(rjs);
              final rf = File('${d.path}/notes_crypt.json');
              await rf.writeAsString(rjs.toString(), mode: FileMode.writeOnly);
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
          future: allNotes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const CircularProgressIndicator();
            else if (!snapshot.hasData) return const SizedBox();
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
