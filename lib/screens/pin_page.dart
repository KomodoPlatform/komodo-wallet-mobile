import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:pin_code_view/pin_code_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinPage extends StatefulWidget {
  final bool firstCreationPin;
  @required
  final String title;
  @required
  final String subTitle;
  @required
  final PinStatus isConfirmPin;
  final String code;

  @override
  _PinPageState createState() => _PinPageState();

  const PinPage({
    this.firstCreationPin,
    this.title,
    this.subTitle,
    this.isConfirmPin,
    this.code});
}

class _PinPageState extends State<PinPage> {
  String _error = "";


  @override
  void initState() {
    if (widget.isConfirmPin == PinStatus.CONFIRM_PIN) {
      authBloc.showPin(false);
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            new PinCode(
              obscurePin: true,
              title: Text(
                widget.title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
              error: _error,
              subTitle: Text(
                widget.subTitle,
                style: TextStyle(color: Colors.white),
              ),
              codeLength: 6,
              onCodeEntered: (code) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                switch (widget.isConfirmPin) {
                  case PinStatus.CREATE_PIN:
                    await prefs.setString("pin_create", code);
                    MaterialPageRoute materialPage = MaterialPageRoute(
                        builder: (context) =>
                            PinPage(
                              title: AppLocalizations
                                  .of(context)
                                  .confirmPin,
                              subTitle: AppLocalizations
                                  .of(context)
                                  .enterPinCode,
                              code: code,
                              isConfirmPin: PinStatus.CONFIRM_PIN,));

                    if (widget.firstCreationPin != null &&
                        widget.firstCreationPin) {
                      Navigator.push(context, materialPage);
                    } else {
                      Navigator.pushReplacement(context, materialPage);
                    }
                    break;
                  case PinStatus.CONFIRM_PIN:
                    if (prefs.getString('pin_create') == code.toString()) {
                      await prefs.setString("pin", code.toString());
                      authBloc.showPin(false);
                      authBloc.updateStatusPin(PinStatus.NORMAL_PIN);
                      Navigator.pop(context);
                    } else {
                      _errorPin();
                    }
                    break;
                  case PinStatus.NORMAL_PIN:
                    if (await _isPinCorrect(code)) {
                      authBloc.showPin(false);
                    } else {
                      _errorPin();
                    }
                    break;
                  case PinStatus.DISABLED_PIN:
                    if (await _isPinCorrect(code)) {
                      SharedPreferences.getInstance().then((data) {
                        data.setBool("switch_pin", false);
                      });
                      Navigator.pop(context);
                    } else {
                      _errorPin();
                    }
                    break;
                  case PinStatus.CHANGE_PIN:
                    if (await _isPinCorrect(code)) {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) =>
                              PinPage(
                                title: AppLocalizations
                                    .of(context)
                                    .createPin,
                                subTitle: AppLocalizations
                                    .of(context)
                                    .enterPinCode,
                                isConfirmPin: PinStatus.CREATE_PIN,)));
                    } else {
                      _errorPin();
                    }
                    break;
                }
              },
            ),
            Positioned(
              bottom: 28,
              left: 75,
              child: InkWell(
                onTap: () {
                  authBloc.logout();
                  if (widget.isConfirmPin == PinStatus.CONFIRM_PIN) {
                    Navigator.pop(context);
                  }
                },
                child: Icon(
                  Icons.exit_to_app,
                  color: Colors.red.withOpacity(0.7),
                  size: 32,
                ),
              ),
            )
          ],
        ));
  }

  _errorPin() {
    setState(() {
      _error = AppLocalizations
          .of(context)
          .errorTryAgain;
    });
  }

  Future<bool> _isPinCorrect(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("pin") == code.toString();
  }

}
