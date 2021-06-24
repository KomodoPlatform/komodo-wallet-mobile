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
      this.paymentUriInfo})
      : super(key: key);

  final Function onCancel;
  final Function onMaxValue;
  final FocusNode focusNode;
  final Function onWithdrawPressed;
  final TextEditingController amountController;
  final TextEditingController addressController;
  final bool autoFocus;
  final Coin coin;
  final PaymentUriInfo paymentUriInfo;

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
      handlePaymentData(widget.paymentUriInfo);
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

  void handlePaymentData(PaymentUriInfo uriInfo) {
    if (uriInfo == null) return;

    if (uriInfo.abbr != widget.coin.abbr) {
      showWrongCoinDialog(uriInfo);
      return;
    }

    final Function onConfirmCallback = () {
      if (uriInfo.address != null && uriInfo.address.isNotEmpty) {
        widget.addressController.text = uriInfo.address;
      }
      if (uriInfo.amount != null) {
        final coinBalance = coinsBloc.coinBalance.firstWhere(
            (cb) => cb.coin.abbr == widget.coin.abbr,
            orElse: () => null);
        final amountDecimal = deci(uriInfo.amount);

        if (coinBalance != null &&
            coinBalance.balance.balance >= amountDecimal) {
          widget.amountController.text = uriInfo.amount;
        } else {
          showinsufficientBalanceDialog(amountDecimal);
        }
      }
    };

    if (widget.paymentUriInfo != null) {
      onConfirmCallback();
    } else {
      showUriDetailsDialog(context, uriInfo, onConfirmCallback);
    }
  }

  void handleQrAdress(String address) {
    widget.addressController.text = address;
  }

  void showWrongCoinDialog(PaymentUriInfo uriInfo) {
    dialogBloc.dialog = showDialog<void>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(24),
            title: Text(AppLocalizations.of(context).wrongCoinTitle),
            children: <Widget>[
              Text(AppLocalizations.of(context).wrongCoinSpan1 +
                  uriInfo.abbr +
                  AppLocalizations.of(context).wrongCoinSpan2 +
                  widget.coin.abbr +
                  AppLocalizations.of(context).wrongCoinSpan3),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    child: Text(AppLocalizations.of(context).okButton),
                    onPressed: () {
                      dialogBloc.closeDialog(context);
                    },
                  )
                ],
              ),
            ],
          );
        }).then((dynamic _) => dialogBloc.dialog = null);
  }

  void showinsufficientBalanceDialog(Decimal amount) {
    dialogBloc.dialog = showDialog<void>(
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
    ).then((dynamic _) => dialogBloc.dialog = null);
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
      final String address = await BarcodeScanner.scan();
      final uri = Uri.tryParse(address.trim());

      setState(() {
        final PaymentUriInfo uriInfo = PaymentUriInfo.fromUri(uri);
        if (uriInfo != null) {
          handlePaymentData(uriInfo);
        } else {
          handleQrAdress(address);
        }
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
    dialogBloc.dialog = showDialog<void>(
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
    ).then((dynamic _) => dialogBloc.dialog = null);
  }
}
