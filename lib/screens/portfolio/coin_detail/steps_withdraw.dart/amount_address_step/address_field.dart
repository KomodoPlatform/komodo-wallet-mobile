import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coin_detail_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:bs58check/bs58check.dart' as bs58check;

class AddressField extends StatefulWidget {
  const AddressField(
      {Key key, this.onScan, this.controller, this.isERCToken = false})
      : super(key: key);

  final Function onScan;
  final TextEditingController controller;
  final bool isERCToken;

  @override
  _AddressFieldState createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: <Widget>[
          Container(
            height: 60,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)),
              onPressed: widget.onScan,
              child: Icon(
                Icons.add_a_photo,
                color: Colors.white,
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
                  labelText: AppLocalizations.of(context).addressSend),
              // The validator receives the text the user has typed in
              validator: (String value) {
                print(coinsDetailBloc.isCancel);
                if (value.isEmpty && coinsDetailBloc.isCancel) {
                  return null;
                }
                if (value.isEmpty) {
                  return AppLocalizations.of(context).errorValueNotEmpty;
                }
                if (widget.isERCToken) {
                  if (!isAddress(value)) {
                    return AppLocalizations.of(context).errorNotAValidAddress;
                  }
                } else {
                  try {
                    final Uint8List decoded = bs58check.decode(value);
                    Log.println('address_field:80', bs58check.encode(decoded));
                  } catch (e) {
                    Log.println('address_field:82', e);
                    if (value.length > 3 &&
                        (value.startsWith('bc1') ||
                            value.startsWith('3') ||
                            value.startsWith('M') ||
                            value.startsWith('ltc1'))) {
                      return AppLocalizations.of(context)
                          .errorNotAValidAddressSegWit;
                    }
                    return AppLocalizations.of(context).errorNotAValidAddress;
                  }
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
