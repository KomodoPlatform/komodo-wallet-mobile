import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:pin_code_view/pin_code_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinPage extends StatefulWidget {
  final String title;
  final String subTitle;
  final PinStatus isConfirmPin;

  @override
  _PinPageState createState() => _PinPageState();

  const PinPage({this.title, this.subTitle, this.isConfirmPin});
}

class _PinPageState extends State<PinPage> {
  String _error = "";

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
              codeLength: 4,
              onCodeEntered: (code) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                switch (widget.isConfirmPin) {
                  case PinStatus.CREATE_PIN:
                    authBloc.updateStatusPin(
                        PinStatus.CONFIRM_PIN, code.toString());
                    break;
                  case PinStatus.CONFIRM_PIN:
                    if (prefs.getString("pin") == code.toString()) {
                      authBloc.updateStatusPin(
                          PinStatus.NORMAL_PIN, code.toString());
                      authBloc.showPin(false);
                    } else {
                      setState(() {
                        _error = "Error try again!";
                      });
                    }
                    break;
                  case PinStatus.NORMAL_PIN:
                    if (prefs.getString("pin") == code.toString()) {
                      authBloc.showPin(false);
                    } else {
                      setState(() {
                        _error = "Error try again!";
                      });
                    }
                    break;
                  case PinStatus.CHANGE_PIN:
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
}
