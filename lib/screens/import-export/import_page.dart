import 'dart:convert';
import 'dart:io';

import 'package:aes_crypt/aes_crypt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/backup.dart';
import 'package:komodo_dex/model/export_import_list_item.dart';
import 'package:komodo_dex/screens/import-export/export_import_list.dart';
import 'package:komodo_dex/screens/import-export/import_notes.dart';
import 'package:komodo_dex/screens/import-export/overwrite_dialog_content.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/lock_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class ImportPage extends StatefulWidget {
  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Backup _all;
  Backup _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).importTitle,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_all == null) ...{
              _buildLoadHeader(),
              _buildFilePickerButton(),
            } else ...{
              _buildImportHeader(),
              _buildNotes(),
              _buildImportButton(),
            }
          ],
        ),
      ),
    );
  }

  Widget _buildImportButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(48, 24, 48, 24),
      child: PrimaryButton(
        onPressed: () async {
          await _importNotes();
        },
        text: AppLocalizations.of(context).importButton,
      ),
    );
  }

  Future<void> _importNotes() async {
    try {
      for (String id in _selected.notes.keys) {
        final String note = _selected.notes[id];

        final String existingNote = await Db.getNote(id);
        if (existingNote == null) {
          await Db.saveNote(id, note);
          continue;
        }

        String mergedValue = '';
        final choice = await showDialog<NoteImportChoice>(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text('Already exists'),
              titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              children: <Widget>[
                OverwriteDialogContent(
                    currentValue: existingNote,
                    newValue: note,
                    onSkip: () {
                      Navigator.pop(context, NoteImportChoice.Skip);
                    },
                    onOverwrite: () {
                      Navigator.pop(context, NoteImportChoice.Overwrite);
                    },
                    onMerge: (String merged) {
                      mergedValue = merged;
                      Navigator.pop(context, NoteImportChoice.Merge);
                    })
              ],
            );
          },
        );
        if (choice == NoteImportChoice.Overwrite) {
          await Db.saveNote(id, note);
        } else if (choice == NoteImportChoice.Merge) {
          await Db.saveNote(id, mergedValue);
        }
      }

      _scaffoldKey.currentState
          .showSnackBar(const SnackBar(content: Text('Imported successfully')));
    } catch (e) {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Error:  $e')));
      return;
    }
  }

  Widget _buildNotes() {
    final List<ExportImportListItem> items = [];
    _all.notes.forEach((String id, dynamic note) {
      items.add(ExportImportListItem(
          checked: _selected.notes.containsKey(id),
          onChange: (bool val) {
            setState(() {
              val ? _selected.notes[id] = note : _selected.notes.remove(id);
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

  Widget _buildImportHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
      child: Text(AppLocalizations.of(context).importDesc,
          style: TextStyle(
            height: 1.3,
            color: Theme.of(context).disabledColor,
          )),
    );
  }

  Widget _buildLoadHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
      child: Text(AppLocalizations.of(context).importLoadDesc,
          style: TextStyle(
            height: 1.3,
            color: Theme.of(context).disabledColor,
          )),
    );
  }

  Widget _buildFilePickerButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(48, 24, 48, 24),
      child: PrimaryButton(
        onPressed: () async {
          String path;
          final int lockCookie = lockService.enteringFilePicker();
          try {
            path = await FilePicker.getFilePath();
          } catch (err) {
            Log('import_page]', 'file picker exception: $err');
          }
          lockService.filePickerReturned(lockCookie);

          if (path == null) return;

          final File file = File(path);
          if (!file.existsSync()) {
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context).importFileNotFound),
            ));
            return;
          }

          final Map<String, dynamic> decrypted = await _decrypt(file);
          if (decrypted == null) return;

          setState(() {
            _all = Backup.fromJson(decrypted);
            _selected = Backup.fromJson(decrypted);
          });
        },
        text: AppLocalizations.of(context).selectFileImport,
      ),
    );
  }

  Future<Map<String, dynamic>> _decrypt(File file) async {
    final pass = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final passController = TextEditingController();
        return SimpleDialog(
          title: Text(AppLocalizations.of(context).importPassword),
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
                  child: Text(AppLocalizations.of(context).importPassCancel),
                ),
                FlatButton(
                  onPressed: () => Navigator.pop(context, passController.text),
                  child: Text(AppLocalizations.of(context).importPassOk),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (pass == null) return null;

    if (pass.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).emptyExportPass)));
      return null;
    }

    final AesCrypt crypt = AesCrypt(pass);

    try {
      final String decrypted = await crypt.decryptTextFromFile(file.path);
      return jsonDecode(decrypted);
    } catch (e) {
      Log('import_page]', 'Failed to decrypt file: $e');
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          e,
          style: TextStyle(
            color: Theme.of(context).errorColor,
          ),
        ),
      ));
      return null;
    }
  }
}
