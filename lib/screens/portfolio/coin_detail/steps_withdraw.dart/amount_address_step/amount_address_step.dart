import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:komodo_dex/blocs/coin_detail_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/steps_withdraw.dart/amount_address_step/address_field.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/steps_withdraw.dart/amount_address_step/amount_field.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/steps_withdraw.dart/amount_address_step/custom_fee.dart';
import 'package:komodo_dex/services/lock_service.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';

class AmountAddressStep extends StatefulWidget {
  const AmountAddressStep(
      {Key key,
      this.onMaxValue,
      this.focusNode,
      this.amountController,
      this.addressController,
      this.autoFocus = false,
      this.onWithdrawPressed,
      this.onCancel,
      this.coin})
      : super(key: key);

  final Function onCancel;
  final Function onMaxValue;
  final FocusNode focusNode;
  final Function onWithdrawPressed;
  final TextEditingController amountController;
  final TextEditingController addressController;
  final bool autoFocus;
  final Coin coin;

  @override
  _AmountAddressStepState createState() => _AmountAddressStepState();
}

class _AmountAddressStepState extends State<AmountAddressStep> {
  String barcode = '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isCancel = false;

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
              coinAbbr: widget.coin.abbr,
            ),
            AddressField(
              addressFormat: widget.coin.addressFormat,
              controller: widget.addressController,
              onScan: scan,
              coin: widget.coin,
            ),
            // Temporary disable custom fee for qrc20 tokens
            if (!(widget.coin.type == 'qrc'))
              CustomFee(
                coin: widget.coin,
                amount: widget.amountController.text,
              ),
            Row(
              children: <Widget>[
                Expanded(
                  child: SecondaryButton(
                    text: AppLocalizations.of(context).cancel,
                    onPressed: () {
                      widget.amountController.clear();
                      widget.addressController.clear();
                      coinsDetailBloc.setIsCancel(true);
                      formKey.currentState.validate();
                      coinsDetailBloc.setIsCancel(false);
                      widget.onCancel();
                    },
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(child: _buildWithdrawButton(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawButton(BuildContext context) {
    return Builder(
      builder: (BuildContext mContext) {
        return PrimaryButton(
          key: const Key('primary-button-withdraw'),
          text: AppLocalizations.of(context).withdraw.toUpperCase(),
          onPressed: () async {
            // Validate will return true if the form is valid, or false if
            // the form is invalid.
            setState(() {
              widget.amountController.text =
                  widget.amountController.text.replaceAll(',', '.');
            });
            if (formKey.currentState.validate()) {
              widget.onWithdrawPressed();
            }
          },
        );
      },
    );
  }

  Future<void> scan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool haveCameraAccess =
        !(await MMService.nativeC.invokeMethod<bool>('is_camera_denied'));
    final bool wasDeniedByUser = prefs.getBool('camera_denied_by_user') == true;
    if (!haveCameraAccess) {
      if (wasDeniedByUser) {
        _showCameraPermissionDialog();
        return;
      }
    } else {
      prefs.setBool('camera_denied_by_user', false);
    }

    final int lockCookie = lockService.enteringQrScanner();
    try {
      final String barcode = await BarcodeScanner.scan();
      setState(() {
        widget.addressController.text = barcode;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        prefs.setBool('camera_denied_by_user', true);
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
    lockService.qrScannerReturned(lockCookie);
  }

  void _showCameraPermissionDialog() {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          title: Text(AppLocalizations.of(context).withdrawCameraAccessTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).withdrawCameraAccessText,
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12),
              RaisedButton(
                child: Text(AppLocalizations.of(context).okButton),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
