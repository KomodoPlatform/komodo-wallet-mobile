import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/utils/utils.dart';
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
import 'package:decimal/decimal.dart';

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
      this.coin,
      this.paymentUri})
      : super(key: key);

  final Function onCancel;
  final Function onMaxValue;
  final FocusNode focusNode;
  final Function onWithdrawPressed;
  final TextEditingController amountController;
  final TextEditingController addressController;
  final bool autoFocus;
  final Coin coin;
  final Uri paymentUri;

  @override
  _AmountAddressStepState createState() => _AmountAddressStepState();
}

class _AmountAddressStepState extends State<AmountAddressStep> {
  String barcode = '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isCancel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleUri(widget.paymentUri);
    });
  }

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

  void handleUri(Uri uri, [String barcode]) {
    final r = parsePaymentUri(uri);

    if (r.scheme == null) return;

    if (r.abbr != widget.coin.abbr) {
      showWrongCoinDialog(r);
      return;
    }

    showUriDetailsDialog(context, uri, () {
      if (r.address != null && r.address.isNotEmpty) {
        widget.addressController.text = r.address;
      } else if (barcode != null) {
        widget.addressController.text = barcode;
      }
      if (r.amount != null) {
        final coinBalance = coinsBloc.coinBalance.firstWhere(
            (cb) => cb.coin.abbr == widget.coin.abbr,
            orElse: () => null);
        final amountDecimal = deci(r.amount);

        if (coinBalance != null &&
            coinBalance.balance.balance >= amountDecimal) {
          widget.amountController.text = r.amount;
        } else {
          showinsufficientBalanceDialog(amountDecimal);
        }
      }
    });
  }

  void showWrongCoinDialog(PaymentUriInfo r) {
    dialogBloc.dialog = showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(24),
            title: Text('Wrong coin'),
            children: <Widget>[
              Text('You are trying to scan a payment QR code for ' +
                  r.abbr +
                  ' but you are on the ' +
                  widget.coin.abbr +
                  ' withdraw screen'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ],
          );
        });
  }

  void showinsufficientBalanceDialog(Decimal amount) {
    dialogBloc.dialog = showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(AppLocalizations.of(context).uriInsufficientBalanceTitle),
          contentPadding: EdgeInsets.all(24),
          children: <Widget>[
            Text(
              AppLocalizations.of(context).uriInsufficientBalanceSpan1 +
                  '${deci2s(amount)} ${widget.coin.abbr}' +
                  AppLocalizations.of(context).uriInsufficientBalanceSpan2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context).warningOkBtn,
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Colors.white),
                  ),
                )
              ],
            )
          ],
        );
      },
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
      final uri = Uri.tryParse(barcode.trim());

      setState(() {
        handleUri(uri, barcode);
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
