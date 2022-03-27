import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_import_swaps.dart';
import 'package:komodo_dex/model/import_swaps.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/import-export/export_import_success.dart';
import 'package:komodo_dex/services/lock_service.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class ImportSwapPage extends StatefulWidget {
  @override
  _ImportSwapPageState createState() => _ImportSwapPageState();
}

class _ImportSwapPageState extends State<ImportSwapPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;
  bool _done = false;
  bool _success = false;
  MmSwap _swap;

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).importSingleSwapTitle),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (_done) ...{
                _buildResultImport(),
              } else if (_swap == null) ...{
                _buildLoadHeader(),
                _buildFilePickerButton(),
              } else ...{
                _buildImportHeader(),
                _buildSwap(),
                _buildImportButton(),
              }
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultImport() {
    if (!_success) {
      return Container(
        padding: EdgeInsets.fromLTRB(48, 24, 48, 24),
        child: Center(
          child: Text(AppLocalizations.of(context).importSwapFailed),
        ),
      );
    }
    return ExportImportSuccess(
      title: AppLocalizations.of(context).importSuccessTitle,
      items: {
        AppLocalizations.of(context).exportSwapsTitle: 1,
      },
    );
  }

  Widget _buildImportButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(48, 24, 48, 24),
      child: PrimaryButton(
        onPressed: () async {
          if (_validate()) {
            final r = await _importSwaps();
            setState(() {
              _done = true;
              _success = r;
            });
          }
        },
        text: AppLocalizations.of(context).importButton,
      ),
    );
  }

  bool _validate() {
    if (_swap == null) {
      _showError(AppLocalizations.of(context).noItemsToImport);
      return false;
    }

    return true;
  }

  Future<bool> _importSwaps() async {
    final List<MmSwap> listSwaps = [];

    listSwaps.add(_swap);

    final dynamic r = await MM.getImportSwaps(GetImportSwaps(swaps: listSwaps));

    if (r is ErrorString) {
      _showError(AppLocalizations.of(context).couldntImportError + r.error);
      return false;
    }

    if (r is ImportSwaps) {
      if (r.result.skipped.isNotEmpty) {
        _showError(AppLocalizations.of(context).couldntImportError +
            r.result.skipped[_swap.uuid]);
        return false;
      }

      return true;
    }

    return false;
  }

  Widget _buildSwap() {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          truncateMiddle(
            _swap.uuid,
            style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 14),
          ),
          SizedBox(height: 2),
          Text(
            _swap.type == 'Maker'
                ? AppLocalizations.of(context).makerOrder
                : AppLocalizations.of(context).takerOrder,
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: 14,
                  color: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .color
                      .withOpacity(0.5),
                ),
          ),
          SizedBox(height: 2),
          Builder(builder: (context) {
            final myInfo = extractMyInfoFromSwap(_swap);
            final myCoin = myInfo['myCoin'];
            final myAmount = myInfo['myAmount'];
            final otherCoin = myInfo['otherCoin'];
            final otherAmount = myInfo['otherAmount'];

            return Row(
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
            );
          }),
        ],
      ),
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
          : Text(AppLocalizations.of(context).importLoadSwapDesc,
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

                final Map<String, dynamic> data = await _getSwapData(file);
                setState(() => _loading = false);

                try {
                  final s = MmSwap.fromJson(data);
                  _validateSwapData(s);
                  setState(() {
                    _swap = s;
                  });
                } catch (e) {
                  _showError(
                      AppLocalizations.of(context).importInvalidSwapData);
                  Log('import_swap_page:281]', e.toString());
                }
              },
        text: AppLocalizations.of(context).selectFileImport,
      ),
    );
  }

  void _validateSwapData(MmSwap data) {
    const String error = 'Invalid swap data';

    if ((data.uuid ?? '').isEmpty) throw error;
    if (data.type != 'Taker' && data.type != 'Maker') throw error;

    if (data.myInfo != null) {
      if ((data.myInfo.myCoin ?? '').isEmpty) throw error;
      if ((data.myInfo.myAmount ?? '').isEmpty) throw error;
      if ((data.myInfo.otherCoin ?? '').isEmpty) throw error;
      if ((data.myInfo.otherAmount ?? '').isEmpty) throw error;
    } else {
      if ((data.makerCoin ?? '').isEmpty) throw error;
      if ((data.takerCoin ?? '').isEmpty) throw error;
      if ((data.makerAmount ?? '').isEmpty) throw error;
      if ((data.takerAmount ?? '').isEmpty) throw error;
    }
  }

  Future<Map<String, dynamic>> _getSwapData(File file) async {
    try {
      final String str = await file.readAsString();
      return jsonDecode(str);
    } catch (e) {
      Log('import_swap_page]', 'Failed to get swap data: $e');
      _showError(AppLocalizations.of(context).importSwapJsonDecodingError);
      return null;
    }
  }

  void _showError(String e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      e,
      style: TextStyle(color: Theme.of(context).errorColor),
    )));
  }
}
