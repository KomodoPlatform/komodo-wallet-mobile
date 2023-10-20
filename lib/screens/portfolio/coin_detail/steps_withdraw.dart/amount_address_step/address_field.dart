import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../../blocs/coin_detail_bloc.dart';
import '../../../../../localizations.dart';
import '../../../../../model/addressbook_provider.dart';
import '../../../../../model/coin.dart';
import '../../../../addressbook/addressbook_page.dart';
import '../../../../../services/mm.dart';
import '../../../../../utils/utils.dart';
import 'package:provider/provider.dart';

class AddressField extends StatefulWidget {
  const AddressField({
    Key key,
    this.onScan,
    this.controller,
    this.addressFormat,
    this.coin,
    this.onChanged,
  }) : super(key: key);

  final Function onScan;
  final TextEditingController controller;
  final Map<String, dynamic> addressFormat;
  final Coin coin;
  final Function(String) onChanged;

  @override
  _AddressFieldState createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  bool mm2Validated = false;
  bool autovalidate = false;
  String convertMessage;

  @override
  void initState() {
    _isCoinActive();
    widget.controller.addListener(() {
      if (!mounted) return;
      _validate();
    });

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAddressFromClipboard();
    });
  }

  @override
  void dispose() {
    _coinIsActiveCountdown?.cancel();
    super.dispose();
  }

  Timer _coinIsActiveCountdown;

  Future<void> _isCoinActive() async {
    _coinIsActiveCountdown =
        Timer.periodic(Duration(milliseconds: 300), (_) async {
      if (widget.controller.text.isEmpty) return;
      final dynamic error = await MM.validateAddress(
        address: widget.controller.text,
        coin: widget.coin.abbr,
      );
      if (error == null) {
        _coinIsActiveCountdown.cancel();
        _validate();
      } else {
        await Future.delayed(Duration(milliseconds: 300));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localisations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                height: 60,
                child: IconButton(
                  splashRadius: 24,
                  padding: EdgeInsets.all(0),
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onScan,
                  icon: Icon(Icons.add_a_photo),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  key: const Key('send-address-field'),
                  controller: widget.controller,
                  autofocus: false,
                  autovalidateMode: autovalidate
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  autocorrect: false,
                  onChanged: widget.onChanged,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  style: Theme.of(context).textTheme.bodyText2,
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).addressSend,
                    suffixIcon: IconButton(
                      splashRadius: 24,
                      onPressed: () => Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => AddressBookPage(
                              shouldPop: true,
                              coin: widget.coin,
                            ),
                          )).then((dynamic _) => _updateAddressFromClipboard()),
                      icon: Icon(
                        Icons.import_contacts,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // The validator receives the text the user has typed in
                  validator: (String value) {
                    if (value.isEmpty && coinsDetailBloc.isCancel) {
                      return null;
                    }
                    if (value.isEmpty) {
                      return AppLocalizations.of(context).errorValueNotEmpty;
                    }
                    if (!mm2Validated) {
                      return localisations.invalidCoinAddress(widget.coin.abbr);
                    }

                    return null;
                  },
                ),
              ),
            ],
          ),
          _buildConvertButton(),
        ],
      ),
    );
  }

  void _updateAddressFromClipboard() {
    final AddressBookProvider addressBookProvider =
        Provider.of<AddressBookProvider>(context, listen: false);
    if (addressBookProvider.clipboard != null) {
      widget.controller.text = addressBookProvider.clipboard;
      addressBookProvider.clipboard = null;
    }
  }

  Widget _buildConvertButton() {
    if (convertMessage == null) return SizedBox();

    return Row(
      children: <Widget>[
        Expanded(
            child: Text(
          convertMessage,
          style: Theme.of(context)
              .textTheme
              .caption
              .copyWith(color: Theme.of(context).colorScheme.secondary),
        )),
        ElevatedButton(
          onPressed: () async {
            final String converted = await MM.convertLegacyAddress(
              address: widget.controller.text,
              coin: widget.coin.abbr,
            );
            if (converted == null) return;

            setState(() {
              autovalidate = true;
            });
            widget.controller.text = converted;
            await Future<dynamic>.delayed(const Duration(milliseconds: 100));
            setState(() {
              autovalidate = false;
            });
          },
          child: Text(AppLocalizations.of(context).convert),
        ),
      ],
    );
  }

  Future<void> _validate() async {
    final dynamic error = await MM.validateAddress(
      address: widget.controller.text,
      coin: widget.coin.abbr,
    );

    // if valid
    if (error == null) {
      setState(() {
        mm2Validated = true;
        convertMessage = null;
        autovalidate = true;
      });
      return;
    }

    // if not valid
    setState(() {
      mm2Validated = false;
      autovalidate = false;
    });
    if (_isBchLegacyFormat(error)) {
      setState(() {
        convertMessage = 'It seems like you are using legacy'
            ' address format. Please try to convert.';
      });
    } else if (_isErcNonMixedCase(error)) {
      setState(() {
        convertMessage = 'If you are using non mixed case'
            ' address, please try to convert to mixed case one.';
      });
    } else {
      setState(() {
        convertMessage = null;
      });
    }

    if (widget.controller.text.isEmpty) {
      setState(() {
        autovalidate = false;
      });
    }
  }

  bool _isBchLegacyFormat(String error) {
    // if BCH address format is wrong, error message may look like this:
    // "Cashaddress address format activated for BCH,
    // but legacy format used instead. Try to call 'convertaddress'"
    return error.contains('convertaddress');
  }

  bool _isErcNonMixedCase(String error) {
    if (!isErcType(widget.coin)) {
      return false;
    }
    if (!error.contains('Invalid address checksum')) return false;

    return true;
  }
}
