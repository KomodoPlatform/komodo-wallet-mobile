import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coin_detail_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/screens/addressbook/addressbook_page.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:provider/provider.dart';

class AddressField extends StatefulWidget {
  const AddressField({
    Key key,
    this.onScan,
    this.controller,
    this.isERCToken = false,
    this.addressFormat,
    this.coin,
  }) : super(key: key);

  final Function onScan;
  final TextEditingController controller;
  final bool isERCToken;
  final Map<String, dynamic> addressFormat;
  final Coin coin;

  @override
  _AddressFieldState createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  AddressBookProvider addressBookProvider;
  bool mm2Validated = false;
  bool autovalidate = false;
  String convertMessage;

  @override
  void initState() {
    widget.controller.addListener(() {
      if (!mounted) return;
      _validate();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    addressBookProvider = Provider.of<AddressBookProvider>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (addressBookProvider.clipboard != null) {
        widget.controller.text = addressBookProvider.clipboard;
        addressBookProvider.clipboard = null;
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 60,
                child: ButtonTheme(
                  minWidth: 50,
                  child: FlatButton(
                    padding: const EdgeInsets.only(
                      left: 6,
                      right: 6,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0)),
                    onPressed: widget.onScan,
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: TextFormField(
                  key: const Key('send-address-field'),
                  controller: widget.controller,
                  autofocus: false,
                  autovalidate: autovalidate,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  style: Theme.of(context).textTheme.body1,
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColorLight)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).accentColor)),
                    hintStyle: Theme.of(context).textTheme.body1,
                    labelStyle: Theme.of(context).textTheme.body1,
                    labelText: AppLocalizations.of(context).addressSend,
                    suffixIcon: InkWell(
                      onTap: () {
                        Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) =>
                                  AddressBookPage(
                                shouldPop: true,
                                coin: widget.coin,
                              ),
                            ));
                      },
                      child: Icon(Icons.import_contacts),
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
                      return 'Invalid ${widget.coin.abbr} address';
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

  Widget _buildConvertButton() {
    if (convertMessage == null) return Container();

    return Row(
      children: <Widget>[
        Expanded(
            child: Text(
          convertMessage,
          style: Theme.of(context)
              .textTheme
              .caption
              .copyWith(color: Theme.of(context).accentColor),
        )),
        RaisedButton(
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
          child: const Text('Convert'),
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
      });
      return;
    }

    // if not valid
    setState(() {
      mm2Validated = false;
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
  }

  bool _isBchLegacyFormat(String error) {
    // if BCH address format is wrong, error message may look like this:
    // "Cashaddress address format activated for BCH,
    // but legacy format used instead. Try to call 'convertaddress'"
    return error.contains('convertaddress');
  }

  bool _isErcNonMixedCase(String error) {
    if (widget.coin.swapContractAddress.isEmpty) return false;
    if (!error.contains('Invalid address checksum')) return false;

    return true;
  }
}
