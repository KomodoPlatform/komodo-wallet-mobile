import 'dart:convert';
import 'dart:io';

import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/model/export_import_list_item.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/import-export/export_import_list.dart';
import 'package:path_provider/path_provider.dart';

class ExportPage extends StatefulWidget {
  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, String> _allNotes;
  Map<String, String> _selectedNotes;

  @override
  void initState() {
    Db.getAllNotes().then((value) {
      setState(() {
        _allNotes = value;
        _selectedNotes = Map.from(_allNotes);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
            _buildButton(),
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
    if (_allNotes == null) return SizedBox();

    final List<ExportImportListItem> items = [];
    _allNotes.forEach((id, note) {
      items.add(ExportImportListItem(
          checked: _selectedNotes.containsKey(id),
          onChange: (bool val) {
            setState(() {
              val ? _selectedNotes[id] = note : _selectedNotes.remove(id);
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

  Widget _buildButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 48, 12, 48),
      child: RaisedButton(
        onPressed: () async {
          final String dir = await _selectDir();
          final String pass = await _enterPass();
          if (pass == null) return;
          if (pass.isEmpty) {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(
                AppLocalizations.of(context).emptyExportPass,
              ),
            ));
            return;
          }

          _export(pass, dir);
        },
        child: Text(AppLocalizations.of(context).exportButton),
      ),
    );
  }

  Future<String> _selectDir() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<String> _enterPass() async {
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
                  onPressed: () => Navigator.pop(context, passController.text),
                  child: const Text('Ok'),
                ),
              ],
            ),
          ],
        );
      },
    );

    return pass;
  }

  Future<void> _export(String pass, String dir) async {
    final crypt = AesCrypt(pass);

    final String encoded = jsonEncode(_selectedNotes);
    final tmpFilePath = '$dir/notes_encrypt.tmp';
    final File tempFile = File(tmpFilePath);
    if (tempFile.existsSync()) await tempFile.delete();
    await crypt.encryptTextToFile(encoded, tmpFilePath);

    final file = File(tmpFilePath);
    final bytes = await file.readAsBytes();
    final b64 = base64.encode(bytes);
    final rjs = jsonEncode({
      'version': 1,
      'db': b64,
    });
    final rf = File('$dir/notes_crypt.json');
    await rf.writeAsString(rjs.toString(), mode: FileMode.writeOnly);
    tempFile.delete();

    _scaffoldKey.currentState
        .showSnackBar(const SnackBar(content: Text('Exported successfully')));
  }
}
