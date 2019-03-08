import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';

class BlocLoginPage extends StatefulWidget {
  @override
  _BlocLoginPageState createState() => _BlocLoginPageState();
}

class _BlocLoginPageState extends State<BlocLoginPage> {
  TextEditingController controllerSeed = new TextEditingController();
  bool _isButtonDisabled;

  @override
  void initState() {
    _isButtonDisabled = false;
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
            '${AppLocalizations
                .of(context)
                .login[0].toUpperCase()}${AppLocalizations
                .of(context)
                .login
                .substring(1)}'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Column(
        children: <Widget>[
          _buildTitle(),
          _buildInputSeed(),
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
            AppLocalizations
                .of(context)
                .enterSeedPhrase,
            style: Theme
                .of(context)
                .textTheme
                .title,
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
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controllerSeed,
        onChanged: (str) {
          if (str.length == 0) {
            setState(() {
              _isButtonDisabled = true;
            });
          } else {
            setState(() {
              _isButtonDisabled = false;
            });
          }
        },
        autocorrect: false,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: Theme
            .of(context)
            .textTheme
            .body1,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
                borderSide:
                BorderSide(color: Theme
                    .of(context)
                    .primaryColorLight)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme
                    .of(context)
                    .accentColor)),
            hintStyle: Theme
                .of(context)
                .textTheme
                .body2,
            labelStyle: Theme
                .of(context)
                .textTheme
                .body1,
            hintText: AppLocalizations
                .of(context)
                .exampleHintSeed,
            labelText: null),
      ),
    );
  }

  _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: double.infinity,
        height: 50,
        child: RaisedButton(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
          color: Theme
              .of(context)
              .buttonColor,
          disabledColor: Theme
              .of(context)
              .disabledColor,
          child: Text(
            AppLocalizations
                .of(context)
                .confirm
                .toUpperCase(),
            style: Theme
                .of(context)
                .textTheme
                .button,
          ),
          onPressed: _isButtonDisabled ? null : _onLoginPressed,
        ),
      ),
    );
  }

  _onLoginPressed() {
    authBloc.login(controllerSeed.text.toString());
    Navigator.pop(context);
  }
}
