import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/backup.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/export_import_list_item.dart';
import 'package:komodo_dex/model/get_import_swaps.dart';
import 'package:komodo_dex/model/import_swaps.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/import-export/export_import_list.dart';
import 'package:komodo_dex/screens/import-export/export_import_success.dart';
import 'package:komodo_dex/screens/import-export/overwrite_dialog_content.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/lock_service.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';
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
  int _numSwapsImported = 0;

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: Scaffold(
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
                _buildSwaps(),
                _buildImportButton(),
              }
            ],
          ),
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
        AppLocalizations.of(context).exportSwapsTitle: _numSwapsImported,
      },
    );
  }

  Widget _buildImportButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(48, 24, 48, 24),
      child: PrimaryButton(
        onPressed: () async {
          if (_validate()) {
            await _importNotes();
            await _importContacts();
            final numSwaps = await _importSwaps();
            setState(() {
              _numSwapsImported = numSwaps;
              _done = true;
            });
          }
        },
        text: AppLocalizations.of(context).importButton,
      ),
    );
  }

  bool _validate() {
    if (_selected.notes.isEmpty &&
        _selected.contacts.isEmpty &&
        _selected.swaps.isEmpty) {
      _showError(AppLocalizations.of(context).noItemsToImport);
      return false;
    }

    return true;
  }

  Future<int> _importSwaps() async {
    final List<MmSwap> listSwaps = [];

    _selected.swaps?.forEach((uuid, swap) {
      listSwaps.add(swap);
    });

    final dynamic r = await MM.getImportSwaps(GetImportSwaps(swaps: listSwaps));

    if (r is ErrorString) {
      _showError(AppLocalizations.of(context).couldntImportError + r.error);
      return 0;
    }

    if (r is ImportSwaps) {
      if (r.result.skipped.isNotEmpty) {
        _showError(AppLocalizations.of(context).importSomeItemsSkippedWarning);
      }
      return r.result.imported.length;
    }

    return 0;
  }

  Future<void> _importContacts() async {
    final AddressBookProvider provider =
        Provider.of<AddressBookProvider>(context, listen: false);
    await provider.init();

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
      dialogBloc.dialog = Future<void>(() {});
      final choice = await showDialog<NoteImportChoice>(
        context: context,
        builder: (context) {
          return CustomSimpleDialog(
            title: const Text('Already exists'),
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
      dialogBloc.dialog = null;
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
                final List<String> coins =
                    contact.addresses?.keys?.toList() ?? [];
                final List<Widget> coinsRow = [];

                for (int i = 0; i < coins.length; i++) {
                  final String coin = coins[i];
                  coinsRow.add(Text(
                    coin + (i < coins.length - 1 ? ', ' : ''),
                    style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withOpacity(0.7)),
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

  Widget _buildSwaps() {
    final List<ExportImportListItem> items = [];

    _all.swaps.forEach((String id, MmSwap swap) {
      final myInfo = extractMyInfoFromSwap(swap);
      final myCoin = myInfo['myCoin'];
      final myAmount = myInfo['myAmount'];
      final otherCoin = myInfo['otherCoin'];
      final otherAmount = myInfo['otherAmount'];
      final startedAt = extractStartedAtFromSwap(swap);

      items.add(
        ExportImportListItem(
          checked: _selected.swaps.containsKey(id),
          onChange: (bool val) {
            setState(() {
              val ? _selected.swaps[id] = swap : _selected.swaps.remove(id);
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              truncateMiddle(
                swap.uuid,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 14),
              ),
              SizedBox(height: 2),
              Row(
                children: <Widget>[
                  Text(
                    DateFormat('dd MMM yyyy HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(startedAt * 1000)),
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontSize: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .color
                              .withOpacity(0.5),
                        ),
                  ),
                  Expanded(child: SizedBox()),
                  Text(
                    (swap.type == 'Maker' || swap.type == 'Taker')
                        ? swap.type == 'Maker'
                            ? AppLocalizations.of(context).makerOrder
                            : AppLocalizations.of(context).takerOrder
                        : swap.type +
                            AppLocalizations.of(context).orderTypePartial,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontSize: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .color
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: <Widget>[
                  Text(
                    cutTrailingZeros(formatPrice(myAmount, 4)) + ' ' + myCoin,
                  ),
                  SizedBox(width: 4),
                  Image.asset(
                    'assets/coin-icons/${myCoin.toLowerCase()}.png',
                    height: 20,
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.swap_horiz),
                  SizedBox(width: 8),
                  Text(
                    cutTrailingZeros(formatPrice(otherAmount, 4)) +
                        ' ' +
                        otherCoin,
                  ),
                  SizedBox(width: 4),
                  Image.asset(
                    'assets/coin-icons/${otherCoin.toLowerCase()}.png',
                    height: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });

    return ExportImportList(
      items: items,
      title: AppLocalizations.of(context).exportSwapsTitle,
    );
  }

  Widget _buildImportHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
      child: Text(AppLocalizations.of(context).importDesc,
          style: TextStyle(
            height: 1.3,
            color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.7),
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
                color: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .color
                    .withOpacity(0.7),
              ))
          : Text(AppLocalizations.of(context).importLoadDesc,
              style: TextStyle(
                height: 1.3,
                color: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .color
                    .withOpacity(0.7),
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

                FilePickerResult filePickerResult;
                final int lockCookie = lockService.enteringFilePicker();
                try {
                  filePickerResult = await FilePicker.platform.pickFiles();
                } catch (err) {
                  Log('import_page]', 'file picker exception: $err');
                }
                lockService.filePickerReturned(lockCookie);

                if (filePickerResult == null) {
                  setState(() => _loading = false);
                  return;
                }

                File file;
                if (filePickerResult.count != 0) {
                  final pFile = filePickerResult.files[0];
                  if (pFile == null) {
                    _showError(AppLocalizations.of(context).importFileNotFound);
                    return;
                  }

                  file = File(pFile.path);
                  if (!file.existsSync()) {
                    _showError(AppLocalizations.of(context).importFileNotFound);
                    return;
                  }
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

    dialogBloc.dialog = Future<void>(() {});
    final pass = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return CustomSimpleDialog(
          title: Text(AppLocalizations.of(context).importPassword),
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
                SizedBox(width: 12),
                RaisedButton(
                  onPressed: () => Navigator.pop(context, _passController.text),
                  child: Text(
                    AppLocalizations.of(context).importPassOk,
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
    dialogBloc.dialog = null;

    if (pass == null) return null;

    if (pass.isEmpty) {
      _showError(AppLocalizations.of(context).emptyExportPass);
      return null;
    }

    try {
      final String length32Key = md5.convert(utf8.encode(pass)).toString();
      final key = encrypt.Key.fromUtf8(length32Key);
      final iv = encrypt.IV.fromLength(16);

      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final String str = await file.readAsString();

      final encrypted = encrypt.Encrypted.fromBase64(str);

      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      return jsonDecode(decrypted);
    } catch (e) {
      Log('import_page]', 'Failed to decrypt file: $e');
      _showError(AppLocalizations.of(context).importDecryptError);
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

enum NoteImportChoice { Skip, Overwrite, Merge }
