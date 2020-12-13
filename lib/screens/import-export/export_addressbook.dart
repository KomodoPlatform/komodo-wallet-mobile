import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/import-export/import_export_selection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:aes_crypt/aes_crypt.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:provider/provider.dart';

class ExportAddressbookScreen extends StatefulWidget {
  @override
  _ExportAddressbookScreenState createState() =>
      _ExportAddressbookScreenState();
}

class _ExportAddressbookScreenState extends State<ExportAddressbookScreen> {
  final selectedContacts = <String, bool>{};
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  AddressBookProvider provider;
  List<Contact> contacts;
  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AddressBookProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Export Addressbook'),
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
                },
              );

              final sc = _scaffoldKey.currentState;

              if (pass == null) return;
              if (pass.isEmpty) {
                sc.showSnackBar(const SnackBar(
                    content: Text("Encryption password can't be empty")));

                return;
              }
              print('Encryption password: $pass');
              final crypt = AesCrypt(pass);

              final n = contacts.where((c) => selectedContacts[c.uid]).toList();

              final d = await getApplicationDocumentsDirectory();
              final js = json.encode(n);
              final tmpFilePath = '${d.path}/addressbook_encrypt.tmp';
              final File f = File(tmpFilePath);
              if (f.existsSync()) await f.delete();
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
              final rf = File('${d.path}/addressbook_crypt.json');
              await rf.writeAsString(rjs.toString(), mode: FileMode.writeOnly);

              sc.showSnackBar(
                  const SnackBar(content: Text('Exported successfully')));
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: provider.contacts,
        builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          contacts = List.from(snapshot.data);
          contacts.sort((Contact a, Contact b) {
            return a.name.compareTo(b.name);
          });

          if (contacts.isEmpty) return Center(child: Text('No contacts'));

          for (Contact c in contacts) {
            selectedContacts.putIfAbsent(c.uid, () => true);
          }
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, i) => ImportExportSelection(
              title: contacts[i].name,
              content: '${contacts[i].addresses.length} addresses',
              selected: selectedContacts[contacts[i].uid],
              changedCallback: (v) {
                setState(() {
                  selectedContacts[contacts[i].uid] = v;
                });
              },
            ),
          );
        },
      ),
    );
  }
}
