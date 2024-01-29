import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../localizations.dart';
import '../../model/addressbook_provider.dart';
import '../../model/backup.dart';
import '../../model/export_import_list_item.dart';
import '../../model/recent_swaps.dart';
import '../../model/swap.dart';
import '../../model/swap_provider.dart';
import '../../services/db/database.dart';
import '../../utils/encryption_tool.dart';
import '../../utils/utils.dart';
import '../../widgets/password_visibility_control.dart';
import '../../widgets/primary_button.dart';
import '../authentification/lock_screen.dart';
import '../import-export/export_import_list.dart';
import '../import-export/export_import_success.dart';

class ExportPage extends StatefulWidget {
  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  bool _done = false;
  final TextEditingController _ctrlPass1 = TextEditingController();
  final TextEditingController _ctrlPass2 = TextEditingController();
  bool _isPassObscured = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Backup _all = Backup(contacts: {}, notes: {}, swaps: {});
  final Backup _selected = Backup(contacts: {}, notes: {}, swaps: {});

  @override
  void initState() {
    _loadNotes();
    _loadContacts();
    _loadSwaps();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).exportTitle),
        ),
        body: ListView(
          children: [
            if (_done) ...{
              _buildSuccess(),
            } else ...{
              _buildHeader(),
              _buildNotes(),
              _buildContacts(),
              _buildSwaps(),
              _buildPass(),
              _buildButton(),
            }
          ],
        ),
      ),
    );
  }

  Future<void> _loadNotes() async {
    final Map<String, String> notes = await Db.getAllNotes();

    setState(() {
      _all.notes = notes;
      _selected.notes = Map.from(_all.notes);
    });
  }

  Future<void> _loadContacts() async {
    final List<Contact> contacts =
        await Provider.of<AddressBookProvider>(context, listen: false).contacts;

    for (Contact contact in contacts) {
      setState(() {
        _all.contacts[contact.uid] = contact;
        _selected.contacts[contact.uid] = contact;
      });
    }
  }

  Future<void> _loadSwaps() async {
    final listSwaps = Provider.of<SwapProvider>(context, listen: false).swaps;
    final List<MmSwap> swaps = listSwaps
        .where((s) =>
            s.status == Status.SWAP_SUCCESSFUL ||
            s.status == Status.SWAP_FAILED)
        .map((s) => s.result)
        .toList();

    for (MmSwap swap in swaps) {
      setState(() {
        _all.swaps[swap.uuid] = swap;
        _selected.swaps[swap.uuid] = swap;
      });
    }
  }

  Widget _buildSuccess() {
    return ExportImportSuccess(
      title: AppLocalizations.of(context).exportSuccessTitle,
      items: {
        AppLocalizations.of(context).exportNotesTitle: _selected.notes.length,
        AppLocalizations.of(context).exportContactsTitle:
            _selected.contacts.length,
        AppLocalizations.of(context).exportSwapsTitle: _selected.swaps.length,
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
      child: Text(AppLocalizations.of(context).exportDesc,
          style: TextStyle(
            height: 1.3,
            color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.7),
          )),
    );
  }

  Widget _buildNotes() {
    if (_all.notes == null) return SizedBox();

    final List<ExportImportListItem> items = [];
    _all.notes.forEach((id, note) {
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
    if (_all.contacts == null) return SizedBox();

    final List<ExportImportListItem> items = [];

    _all.contacts.forEach((uid, contact) {
      items.add(ExportImportListItem(
        checked: _selected.contacts.containsKey(uid),
        onChange: (val) {
          setState(() {
            val
                ? _selected.contacts[uid] = contact
                : _selected.contacts.remove(uid);
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
                          .withOpacity(0.5)),
                ));
              }

              return Wrap(
                children: coinsRow,
              );
            }),
          ],
        ),
      ));
    });

    return ExportImportList(
      title: AppLocalizations.of(context).exportContactsTitle,
      items: items,
    );
  }

  Widget _buildSwaps() {
    if (_all.swaps == null) return SizedBox();

    final List<ExportImportListItem> items = [];

    _all.swaps.forEach((uuid, swap) {
      final myInfo = extractMyInfoFromSwap(swap);
      final myCoin = myInfo['myCoin'];
      final myAmount = myInfo['myAmount'];
      final otherCoin = myInfo['otherCoin'];
      final otherAmount = myInfo['otherAmount'];
      final startedAt = extractStartedAtFromSwap(swap);

      items.add(ExportImportListItem(
        checked: _selected.swaps.containsKey(uuid),
        onChange: (val) {
          setState(() {
            val ? _selected.swaps[uuid] = swap : _selected.swaps.remove(uuid);
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            truncateMiddle(
              swap.uuid,
              style:
                  Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 14),
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
                  getCoinIconPath(myCoin),
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
                  getCoinIconPath(otherCoin),
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ));
    });
    return ExportImportList(
      title: AppLocalizations.of(context).exportSwapsTitle,
      items: items,
    );
  }

  Widget _buildButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 24, 12, 48),
      child: Row(
        children: [
          Expanded(child: SizedBox()),
          Expanded(
            child: PrimaryButton(
              onPressed: isValidPassword
                  ? () async {
                      if (_validate()) _export();
                    }
                  : null,
              text: AppLocalizations.of(context).exportButton,
            ),
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  bool _validate() {
    if (_selected.notes.isEmpty &&
        _selected.contacts.isEmpty &&
        _selected.swaps.isEmpty) {
      _showError(AppLocalizations.of(context).noItemsToExport);
      return false;
    }

    return true;
  }

  Future<void> _export() async {
    final Directory tmpDir = await getApplicationDocumentsDirectory();

    final String encoded = jsonEncode(_selected);
    final tmpFilePath = '${tmpDir.path}/atomicDEX_backup';
    final File tempFile = File(tmpFilePath);
    if (tempFile.existsSync()) await tempFile.delete();

    final encrypted = EncryptionTool().encryptData(_ctrlPass1.text, encoded);
    await tempFile.writeAsString(encrypted);

    await Share.shareXFiles(
      [XFile(tempFile.path, mimeType: 'application/octet-stream')],
      subject: 'atomicDEX_backup',
    );
    setState(() {
      _done = true;
    });
  }

  bool isValidPassword = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onChange() {
    final String text = _ctrlPass1.text;
    final String text2 = _ctrlPass2.text;
    _formKey.currentState.validate();
    if (text.isEmpty ||
        text2.isEmpty ||
        !_formKey.currentState.validate() ||
        _ctrlPass1.text != _ctrlPass2.text) {
      setState(() {
        isValidPassword = false;
      });
    } else {
      setState(() {
        isValidPassword = true;
      });
    }
  }

  Widget _buildPass() {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
      child: Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            controller: _ctrlPass1,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableInteractiveSelection: true,
            onChanged: (a) {
              if (_ctrlPass2.text.isNotEmpty) {
                _onChange();
              }
            },
            toolbarOptions: ToolbarOptions(
              paste: _ctrlPass1.text.isEmpty,
              copy: false,
              cut: false,
              selectAll: false,
            ),
            obscureText: _isPassObscured,
            style: Theme.of(context).textTheme.bodyText2,
            validator: (a) {
              if (a.isEmpty) {
                return AppLocalizations.of(context).hintEnterPassword;
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
              errorMaxLines: 6,
              hintText: AppLocalizations.of(context).hintCreatePassword,
              suffixIcon: PasswordVisibilityControl(
                onVisibilityChange: (bool isPasswordObscured) {
                  setState(() {
                    _isPassObscured = isPasswordObscured;
                  });
                },
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          TextFormField(
            controller: _ctrlPass2,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            obscureText: _isPassObscured,
            enableInteractiveSelection: true,
            onChanged: (a) {
              if (_ctrlPass1.text.isNotEmpty) {
                _onChange();
              }
            },
            toolbarOptions: ToolbarOptions(
              paste: _ctrlPass2.text.isEmpty,
              copy: false,
              cut: false,
              selectAll: false,
            ),
            style: Theme.of(context).textTheme.bodyText2,
            validator: (a) {
              if (a.isEmpty) {
                return AppLocalizations.of(context).hintEnterPassword;
              } else if (_ctrlPass1.text != _ctrlPass2.text) {
                return AppLocalizations.of(context).matchExportPass;
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).hintConfirmPassword,
            ),
          ),
        ]),
      ),
    );
  }

  void _showError(String e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      e,
      style: TextStyle(color: Theme.of(context).errorColor),
    )));
  }
}
