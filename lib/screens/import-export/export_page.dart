import 'dart:convert';
import 'dart:io';

import 'package:aes_crypt/aes_crypt.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/widgets/password_visibility_control.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:komodo_dex/model/export_import_list_item.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/import-export/export_import_list.dart';

class ExportPage extends StatefulWidget {
  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final TextEditingController _ctrlPass1 = TextEditingController();
  final TextEditingController _ctrlPass2 = TextEditingController();
  bool _isPassObscured = true;
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
            _buildPass(),
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
      padding: EdgeInsets.fromLTRB(12, 24, 12, 48),
      child: Row(
        children: [
          Expanded(child: SizedBox()),
          Expanded(
            child: PrimaryButton(
              onPressed: () async {
                if (_validate()) _export();
              },
              text: AppLocalizations.of(context).exportButton,
            ),
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  bool _validate() {
    if (_selectedNotes.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
        AppLocalizations.of(context).noItemsToExport,
        style: TextStyle(color: Theme.of(context).errorColor),
      )));
      return false;
    }

    if (_ctrlPass1.text.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
        AppLocalizations.of(context).emptyExportPass,
        style: TextStyle(color: Theme.of(context).errorColor),
      )));
      return false;
    }

    if (_ctrlPass1.text != _ctrlPass2.text) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
        AppLocalizations.of(context).matchExportPass,
        style: TextStyle(color: Theme.of(context).errorColor),
      )));
      return false;
    }

    return true;
  }

  Future<void> _export() async {
    final Directory tmpDir = await getApplicationDocumentsDirectory();
    final crypt = AesCrypt(_ctrlPass1.text);

    final String encoded = jsonEncode(_selectedNotes);
    final tmpFilePath = '${tmpDir.path}/atomicDEX_backup';
    final File tempFile = File(tmpFilePath);
    if (tempFile.existsSync()) await tempFile.delete();
    await crypt.encryptTextToFile(encoded, tmpFilePath);

    await Share.shareFile(tempFile,
        mimeType: 'application/octet-stream', subject: 'atomicDEX backup');
    tempFile.delete();
  }

  Widget _buildPass() {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
      child: Column(children: [
        TextField(
          controller: _ctrlPass1,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          enableInteractiveSelection: true,
          toolbarOptions: ToolbarOptions(
            paste: _ctrlPass1.text.isEmpty,
            copy: false,
            cut: false,
            selectAll: false,
          ),
          obscureText: _isPassObscured,
          style: Theme.of(context).textTheme.bodyText2,
          decoration: InputDecoration(
            errorMaxLines: 6,
            errorStyle: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontSize: 12, color: Theme.of(context).errorColor),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorLight)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
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
        const SizedBox(
          height: 8,
        ),
        TextField(
          controller: _ctrlPass2,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          obscureText: _isPassObscured,
          enableInteractiveSelection: true,
          toolbarOptions: ToolbarOptions(
            paste: _ctrlPass2.text.isEmpty,
            copy: false,
            cut: false,
            selectAll: false,
          ),
          style: Theme.of(context).textTheme.bodyText2,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorLight)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
            hintStyle: Theme.of(context).textTheme.bodyText1,
            labelStyle: Theme.of(context).textTheme.bodyText2,
            hintText: AppLocalizations.of(context).hintConfirmPassword,
            labelText: null,
          ),
        ),
      ]),
    );
  }
}
