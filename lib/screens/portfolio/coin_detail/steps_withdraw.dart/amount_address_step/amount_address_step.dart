import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/steps_withdraw.dart/amount_address_step/address_field.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/steps_withdraw.dart/amount_address_step/amount_field.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/steps_withdraw.dart/amount_address_step/custom_fee.dart';

class AmountAddressStep extends StatefulWidget {
  const AmountAddressStep(
      {Key key,
      this.onMaxValue,
      this.focusNode,
      this.amountController,
      this.addressController,
      this.autoFocus = false,
      this.balance,
      this.isERCToken = false,
      this.onConfirm})
      : super(key: key);

  final Function onMaxValue;
  final FocusNode focusNode;
  final Function onConfirm;
  final TextEditingController amountController;
  final TextEditingController addressController;
  final bool autoFocus;
  final double balance;
  final bool isERCToken;

  @override
  _AmountAddressStepState createState() => _AmountAddressStepState();
}

class _AmountAddressStepState extends State<AmountAddressStep> {
  String barcode = '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AmountField(
              onMaxValue: widget.onMaxValue,
              focusNode: widget.focusNode,
              controller: widget.amountController,
              autoFocus: widget.autoFocus,
              balance: widget.balance,
            ),
            AddressField(
              isERCToken: widget.isERCToken,
              controller: widget.addressController,
              onScan: scan,
            ),
            CustomFee(
              amount: widget.amountController.text,
              isERCToken: widget.isERCToken,
            ),
            _buildWithdrawButton(context)
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      child: Builder(
        builder: (BuildContext mContext) {
          return RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0)),
            color: Theme.of(context).buttonColor,
            disabledColor: Theme.of(context).disabledColor,
            child: Text(
              AppLocalizations.of(context).withdraw.toUpperCase(),
              style: Theme.of(context).textTheme.button,
            ),
            onPressed: () async {
              // Validate will return true if the form is valid, or false if
              // the form is invalid.
              setState(() {
                widget.amountController.text =
                    widget.amountController.text.replaceAll(',', '.');
              });
              if (formKey.currentState.validate()) {
                widget.onConfirm();
              }
            },
          );
        },
      ),
    );
  }

  Future<void> scan() async {
    authBloc.setIsQrCodeActive(true);
    try {
      final String barcode = await BarcodeScanner.scan();
      setState(() {
        widget.addressController.text = barcode;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => barcode = 'Unknown error: $e');
    }
    authBloc.setIsQrCodeActive(false);
  }
}
