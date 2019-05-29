import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:bip39/bip39.dart' as bip39;

class BlocLoginPage extends StatefulWidget {
  @override
  _BlocLoginPageState createState() => _BlocLoginPageState();
}

class _BlocLoginPageState extends State<BlocLoginPage> {
  TextEditingController controllerSeed = new TextEditingController();
  bool _isButtonDisabled = false;
  bool _isLogin;
  bool _isSeedShow = true;
  bool checkBox = false;

  @override
  void initState() {
    _isLogin = false;
    _isButtonDisabled = true;
    super.initState();
  }

  @override
  void dispose() {
    controllerSeed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${AppLocalizations.of(context).login[0].toUpperCase()}${AppLocalizations.of(context).login.substring(1)}'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        children: <Widget>[
          _buildTitle(),
          _buildInputSeed(),
          _buildCheckBoxCustomSeed(),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  _buildTitle() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 56,
        ),
        Center(
          child: Text(
            AppLocalizations.of(context).enterSeedPhrase,
            style: Theme.of(context).textTheme.title,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 56,
        ),
      ],
    );
  }

  _buildInputSeed() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controllerSeed,
              onChanged: (str) {
                _checkSeed(str);
              },
              autocorrect: false,
              keyboardType: TextInputType.multiline,
              obscureText: _isSeedShow,
              enableInteractiveSelection: true,
              maxLines: null,
              style: Theme.of(context).textTheme.body1,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColorLight)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).accentColor)),
                  hintStyle: Theme.of(context).textTheme.body2,
                  labelStyle: Theme.of(context).textTheme.body1,
                  hintText: AppLocalizations.of(context).exampleHintSeed,
                  labelText: null),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  _isSeedShow ? _isSeedShow = false : _isSeedShow = true;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isSeedShow
                    ? Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
              ))
        ],
      ),
    );
  }

  _checkSeed(String str) {
    if (checkBox) {
      if (str.length > 0) {
        setState(() {
          _isButtonDisabled = false;
        });
      } else {
        setState(() {
          _isButtonDisabled = true;
        });
      }
    } else {
      if (bip39.validateMnemonic(str)) {
        setState(() {
          _isButtonDisabled = false;
        });
      } else {
        setState(() {
          _isButtonDisabled = true;
        });
      }
    }
  }

  _buildCheckBoxCustomSeed() {
    return Row(
      children: <Widget>[
        Checkbox(
          value: checkBox,
          onChanged: (data) {
            setState(() {
              checkBox = !checkBox;
              _checkSeed(controllerSeed.text);
            });
          },
        ),
        Text(
          AppLocalizations.of(context).allowCustomSeed,
          style: Theme.of(context).textTheme.body2,
        )
      ],
    );
  }

  _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Container(
        width: double.infinity,
        height: 50,
        child: _isLogin
            ? Center(child: CircularProgressIndicator())
            : PrimaryButton(
                text: AppLocalizations.of(context).confirm,
                onPressed: _isButtonDisabled ? null : _onLoginPressed),
      ),
    );
  }

  _onLoginPressed() {
    setState(() {
      _isButtonDisabled = true;
      _isLogin = true;
    });
    FocusScope.of(context).requestFocus(new FocusNode());

    authBloc.loginUI(true, controllerSeed.text.toString()).then((onValue) {
      Navigator.pop(context);
    }).then((_) {
      setState(() {
        _isLogin = false;
      });
    });
  }
}
