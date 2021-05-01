import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_import_swaps.dart';
import 'package:komodo_dex/model/import_swaps.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).importSingleSwapTitle,
        ),
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
            (_swap.type == 'Maker' || _swap.type == 'Taker')
                ? _swap.type == 'Maker'
                    ? AppLocalizations.of(context).makerOrder
                    : AppLocalizations.of(context).takerOrder
                : _swap.type + AppLocalizations.of(context).orderTypePartial,
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
            String myCoin, myAmount, otherCoin, otherAmount;
            if (_swap.myInfo != null) {
              myCoin = _swap.myInfo.myCoin;
              myAmount = _swap.myInfo.myAmount;
              otherCoin = _swap.myInfo.otherCoin;
              otherAmount = _swap.myInfo.otherAmount;
            } else {
              myCoin =
                  _swap.type == 'Maker' ? _swap.makerCoin : _swap.takerCoin;
              myAmount =
                  _swap.type == 'Maker' ? _swap.makerAmount : _swap.takerAmount;

              // Same as previous, just swapped around
              otherCoin =
                  _swap.type == 'Maker' ? _swap.takerCoin : _swap.makerCoin;
              otherAmount =
                  _swap.type == 'Maker' ? _swap.takerAmount : _swap.makerAmount;
            }
            return Row(
              children: <Widget>[
                Text(
                  cutTrailingZeros(formatPrice(myAmount, 4)) + ' ' + myCoin,
                ),
                SizedBox(width: 4),
                Image.asset(
                  'assets/${myCoin.toLowerCase()}.png',
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
                  'assets/${otherCoin.toLowerCase()}.png',
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

                final Map<String, dynamic> data = await _getSwapData(file);
                setState(() => _loading = false);

                try {
                  final s = MmSwap.fromJson(data);
                  setState(() {
                    _swap = s;
                  });
                } catch (e) {
                  _showError(
                      AppLocalizations.of(context).importInvalidSwapData +
                          e.toString());
                }
              },
        text: AppLocalizations.of(context).selectFileImport,
      ),
    );
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
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
      '$e',
      style: TextStyle(color: Theme.of(context).errorColor),
    )));
  }
}
