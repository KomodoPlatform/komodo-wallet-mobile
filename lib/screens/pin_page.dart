import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_code_view/pin_code_view.dart';

class PinPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          FutureBuilder(
            future: loadWidget(context),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data) {
                return Positioned(
                  bottom: 100,
                  child: Icon(Icons.fingerprint),
                );
              } else {
                return Container();
              }
            },
          ),
          PinCode(
            obscurePin: true,
            title: Text(
              "Lock Screen",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
            ),
            subTitle: Text(
              "Enter the pin code",
              style: TextStyle(color: Colors.white),
            ),
            codeLength: 4,
            onCodeEntered: (code) {
              print(code);
              authBloc.showPin(false);
            },
          ),
        ],
      ),
    );
  }

  Future<bool> loadWidget(BuildContext context) async {
    var localAuth = LocalAuthentication();
    bool canCheckBiometrics =
    await localAuth.canCheckBiometrics;
    print("--------------------------");
    print(canCheckBiometrics);
    print("--------------------------");
    return canCheckBiometrics;
  }
}
