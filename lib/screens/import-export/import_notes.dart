//              Directory d = await getApplicationDocumentsDirectory();
//            File f = File('${d.path}/a.json');

import 'dart:convert';
import 'dart:io';

import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/widgets/import_export_selection.dart';
import 'package:path_provider/path_provider.dart';

class ImportNotesScreen extends StatefulWidget {
  @override
  _ImportNotesScreenState createState() => _ImportNotesScreenState();
}

class _ImportNotesScreenState extends State<ImportNotesScreen> {
  Map<String, String> allNotes;
  final selectedNotes = <String, bool>{};
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Import Notes'),
        actions: <Widget>[
          FlatButton(
            child: const Text('Load'),
            onPressed: () async {
              final sc = _scaffoldKey.currentState;

              final d = await getApplicationDocumentsDirectory();
              final filePath = '${d.path}/notes_crypt.json';
              final f = File(filePath);
              final fExists = f.existsSync();
              if (!fExists) {
                sc.showSnackBar(
                    const SnackBar(content: Text('Exported file not found')));
                return;
              }

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
                },
              );

              if (pass == null) return;
              if (pass.isEmpty) {
                sc.showSnackBar(const SnackBar(
                    content: Text("Decryption password can't be empty")));

                return;
              }
              print('Decryption password: $pass');

              final str = f.readAsStringSync();
              final dynamic j = json.decode(str);
              final String db = j['db'];
              final dbBytes = base64.decode(db);
              final tmpFilePath = '${d.path}/notes_decrypt.tmp';
              final f1 = File(tmpFilePath);
              await f1.writeAsBytes(dbBytes, mode: FileMode.writeOnly);

              final crypt = AesCrypt(pass);

              try {
                final dbDecrypt = await crypt.decryptTextFromFile(tmpFilePath);
                final dynamic dbJson = json.decode(dbDecrypt);
                final a = Map<String, String>.from(dbJson);
                setState(() {
                  allNotes = a;
                });
              } catch (e) {
                print(e);
                sc.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
          ),
          FlatButton(
            child: const Text('Import'),
            onPressed: () async {
              final sc = _scaffoldKey.currentState;

              final a = <String, String>{};
              allNotes.forEach((k, v) {
                if (selectedNotes[k]) {
                  a.putIfAbsent(k, () => v);
                }
              });
              print(a);
              try {
                await Db.addAllNotes(a);
                sc.showSnackBar(
                    const SnackBar(content: Text('Imported successfully')));
              } catch (e) {
                sc.showSnackBar(SnackBar(content: Text('Error:  $e')));
                return;
              }
            },
          ),
        ],
      ),
      body: allNotes == null
          ? const Center(
              child: Text('Press Load to load exported notes'),
            )
          : Builder(builder: (context) {
              final widgets = <Widget>[];
              allNotes?.forEach((k, v) {
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
