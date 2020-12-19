import 'dart:convert';
import 'dart:io';

import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/screens/import-export/import_export_selection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ImportAddressbookScreen extends StatefulWidget {
  @override
  _ImportAddressbookScreenState createState() =>
      _ImportAddressbookScreenState();
}

enum AddressbookImportChoice { Skip, Overwrite, Merge }

class _ImportAddressbookScreenState extends State<ImportAddressbookScreen> {
  List<Contact> contacts;
  final selectedContacts = <String, bool>{};
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AddressBookProvider provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AddressBookProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Import Addressbook'),
        actions: <Widget>[
          FlatButton(
            child: const Text('Load'),
            onPressed: () async {
              final sc = _scaffoldKey.currentState;

              final d = await getApplicationDocumentsDirectory();
              final filePath = '${d.path}/addressbook_crypt.json';
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
              final tmpFilePath = '${d.path}/addressbook_encrypt.tmp';
              final f1 = File(tmpFilePath);
              await f1.writeAsBytes(dbBytes, mode: FileMode.writeOnly);

              final crypt = AesCrypt(pass);

              try {
                final dbDecrypt = await crypt.decryptTextFromFile(tmpFilePath);
                final List<dynamic> list = json.decode(dbDecrypt);

                final r = <Contact>[];
                for (var a in list) {
                  final c = Contact.fromJson(a);
                  r.add(c);
                }
                print(r);
                setState(() {
                  contacts = r;
                });

                for (Contact c in contacts) {
                  selectedContacts.putIfAbsent(c.uid, () => true);
                }
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

              final n = contacts.where((c) => selectedContacts[c.uid]).toList();

              print(n);

              try {
                for (Contact c in n) {
                  provider.createContact(name: c.name, addresses: c.addresses);
                }

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
      body: contacts == null
          ? const Center(
              child: Text('Press Load to load exported contacts'),
            )
          : ListView.builder(
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
            ),
    );
  }
}
