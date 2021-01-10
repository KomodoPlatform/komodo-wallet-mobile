import 'dart:convert';
import 'dart:io';

import 'package:aes_crypt/aes_crypt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/backup.dart';
import 'package:komodo_dex/model/export_import_list_item.dart';
import 'package:komodo_dex/screens/import-export/export_import_list.dart';
import 'package:komodo_dex/screens/import-export/export_import_success.dart';
import 'package:komodo_dex/screens/import-export/import_notes.dart';
import 'package:komodo_dex/screens/import-export/overwrite_dialog_content.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/lock_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/password_visibility_control.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class ImportPage extends StatefulWidget {
  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;
  final _passController = TextEditingController();
  bool _isPassObscured = true;
  bool _done = false;
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
            if (_done) ...{
              _buildSuccess(),
            } else if (_all == null) ...{
              _buildLoadHeader(),
              _buildFilePickerButton(),
            } else ...{
              _buildImportHeader(),
              _buildNotes(),
              _buildContacts(),
              _buildImportButton(),
            }
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return ExportImportSuccess(
      title: AppLocalizations.of(context).importSuccessTitle,
      items: {
        AppLocalizations.of(context).exportNotesTitle: _selected.notes.length,
        AppLocalizations.of(context).exportContactsTitle:
            _selected.contacts.length,
      },
    );
  }

  Widget _buildImportButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(48, 24, 48, 24),
      child: PrimaryButton(
        onPressed: () async {
          await _importNotes();
          await _importContacts();
          setState(() => _done = true);
        },
        text: AppLocalizations.of(context).importButton,
      ),
    );
  }

  Future<void> _importContacts() async {
    final AddressBookProvider provider =
        Provider.of<AddressBookProvider>(context, listen: false);

    _selected.contacts?.forEach((uid, contact) {
      final Contact existing = provider.contactByUid(uid);
      if (existing == null) {
        provider.addContact(contact);
      } else {
        provider.updateContact(contact);
      }
    });
  }

  Future<void> _importNotes() async {
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

  Widget _buildContacts() {
    final List<ExportImportListItem> items = [];
    _all.contacts.forEach((String id, dynamic contact) {
      items.add(ExportImportListItem(
          checked: _selected.contacts.containsKey(id),
          onChange: (bool val) {
            setState(() {
              val
                  ? _selected.contacts[id] = contact
                  : _selected.contacts.remove(id);
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contact.name),
              SizedBox(height: 2),
              Builder(builder: (context) {
                final List<String> coins = contact.addresses.keys.toList();
                final List<Widget> coinsRow = [];

                for (int i = 0; i < coins.length; i++) {
                  final String coin = coins[i];
                  coinsRow.add(Text(
                    coin + (i < coins.length - 1 ? ', ' : ''),
                    style: TextStyle(
                        fontSize: 10, color: Theme.of(context).disabledColor),
                  ));
                }

                return Wrap(
                  children: coinsRow,
                );
              }),
            ],
          )));
    });

    return ExportImportList(
      items: items,
      title: AppLocalizations.of(context).exportContactsTitle,
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
      child: _loading
          ? Text(AppLocalizations.of(context).importLoading,
              style: TextStyle(
                height: 1.3,
                color: Theme.of(context).disabledColor,
              ))
          : Text(AppLocalizations.of(context).importLoadDesc,
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
        onPressed: _loading
            ? null
            : () async {
                setState(() => _loading = true);

                String path;
                final int lockCookie = lockService.enteringFilePicker();
                try {
                  path = await FilePicker.getFilePath();
                } catch (err) {
                  Log('import_page]', 'file picker exception: $err');
                }
                lockService.filePickerReturned(lockCookie);

                if (path == null) {
                  setState(() => _loading = false);
                  return;
                }

                final File file = File(path);
                if (!file.existsSync()) {
                  _showError(AppLocalizations.of(context).importFileNotFound);
                  return;
                }

                final Map<String, dynamic> decrypted = await _decrypt(file);
                setState(() => _loading = false);
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
    setState(() => _isPassObscured = true);
    _passController.text = '';

    final pass = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return SimpleDialog(
          title: Text(AppLocalizations.of(context).importPassword),
          contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 12),
          children: <Widget>[
            TextField(
              controller: _passController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              enableInteractiveSelection: true,
              toolbarOptions: ToolbarOptions(
                paste: _passController.text.isEmpty,
                copy: false,
                cut: false,
                selectAll: false,
              ),
              obscureText: _isPassObscured,
              style: Theme.of(context).textTheme.bodyText2,
              decoration: InputDecoration(
                errorMaxLines: 6,
                errorStyle: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontSize: 12, color: Theme.of(context).errorColor),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColorLight)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor)),
                hintStyle: Theme.of(context).textTheme.bodyText1,
                labelStyle: Theme.of(context).textTheme.bodyText2,
                hintText: AppLocalizations.of(context).hintPassword,
                labelText: null,
                suffixIcon: PasswordVisibilityControl(
                  onVisibilityChange: (bool isPasswordObscured) {
                    setState(() {
                      _isPassObscured = isPasswordObscured;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).importPassCancel),
                ),
                RaisedButton(
                  onPressed: () => Navigator.pop(context, _passController.text),
                  child: Text(AppLocalizations.of(context).importPassOk),
                ),
              ],
            ),
          ],
        );
      }),
    );

    if (pass == null) return null;

    if (pass.isEmpty) {
      _showError(AppLocalizations.of(context).emptyExportPass);
      return null;
    }

    final AesCrypt crypt = AesCrypt(pass);

    try {
      final String decrypted = await crypt.decryptTextFromFile(file.path);
      return jsonDecode(decrypted);
    } catch (e) {
      Log('import_page]', 'Failed to decrypt file: $e');
      _showError(e);
      return null;
    }
  }

  void _showError(String e) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
      '$e',
      style: TextStyle(color: Theme.of(context).errorColor),
    )));
  }
}
