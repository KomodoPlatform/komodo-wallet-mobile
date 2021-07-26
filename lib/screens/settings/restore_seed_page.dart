import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/create_password_page.dart';
import 'package:komodo_dex/widgets/password_visibility_control.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:bip39/bip39.dart' as bip39;

class RestoreSeedPage extends StatefulWidget {
  @override
  _RestoreSeedPageState createState() => _RestoreSeedPageState();
}

class _RestoreSeedPageState extends State<RestoreSeedPage> {
  TextEditingController controllerSeed = TextEditingController();
  bool _isButtonDisabled = false;
  bool _isLogin;
  bool _isSeedHidden = true;
  bool _checkBox = false;

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

  Widget _buildTitle() {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 56,
        ),
        Center(
          child: Text(
            AppLocalizations.of(context).enterSeedPhrase,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(
          height: 56,
        ),
      ],
    );
  }

  Widget _buildInputSeed() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: TextField(
        key: const Key('restore-seed-field'),
        controller: controllerSeed,
        onChanged: (String str) {
          _checkSeed(str);
        },
        autocorrect: false,
        keyboardType: TextInputType.multiline,
        obscureText: _isSeedHidden,
        enableInteractiveSelection: true,
        toolbarOptions: ToolbarOptions(
          paste: controllerSeed.text.isEmpty,
          copy: false,
          cut: false,
          selectAll: false,
        ),
        maxLines: _isSeedHidden ? 1 : null,
        style: Theme.of(context).textTheme.bodyText2,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColorLight)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).accentColor)),
          hintStyle: Theme.of(context).textTheme.bodyText1,
          labelStyle: Theme.of(context).textTheme.bodyText2,
          hintText: AppLocalizations.of(context).exampleHintSeed,
          labelText: null,
          suffixIcon: PasswordVisibilityControl(
            onVisibilityChange: (bool isObscured) {
              setState(() {
                _isSeedHidden = isObscured;
              });
            },
          ),
        ),
      ),
    );
  }

  void _checkSeed(String str) {
    if (_checkBox) {
      if (str.isNotEmpty) {
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

  Widget _buildCheckBoxCustomSeed() {
    return Row(
      children: <Widget>[
        Checkbox(
          key: const Key('checkbox-custom-seed'),
          value: _checkBox,
          onChanged: (bool data) async {
            final bool confirmed = await _showCustomSeedWarning(data);
            if (!confirmed) return;
            setState(() {
              _checkBox = !_checkBox;
              _checkSeed(controllerSeed.text);
            });
          },
        ),
        Text(
          AppLocalizations.of(context).allowCustomSeed,
          style: Theme.of(context).textTheme.bodyText1,
        )
      ],
    );
  }

  Future<bool> _showCustomSeedWarning(bool value) async {
    if (!value) return true;

    dialogBloc.dialog = Future<void>(() {});
    final bool confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          bool enabled = false;
          return StatefulBuilder(builder: (context, setState) {
            return SimpleDialog(
              contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              title: Text(AppLocalizations.of(context).warning),
              children: [
                Text(AppLocalizations.of(context).customSeedWarning),
                TextField(
                  autofocus: true,
                  style: TextStyle(color: Theme.of(context).accentColor),
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).accentColor)),
                  ),
                  onChanged: (String text) {
                    setState(() {
                      enabled = text.trim().toLowerCase() ==
                          AppLocalizations.of(context)
                              .iUnderstand
                              .toLowerCase();
                    });
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlatButton(
                        child: Text(AppLocalizations.of(context).cancelButton),
                        onPressed: () {
                          Navigator.pop(context, false);
                        }),
                    SizedBox(width: 12),
                    RaisedButton(
                      child: Text(AppLocalizations.of(context).okButton),
                      onPressed: !enabled
                          ? null
                          : () {
                              Navigator.pop(context, true);
                            },
                    ),
                  ],
                )
              ],
            );
          });
        });
    dialogBloc.dialog = null;

    return confirmed == true;
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Container(
        width: double.infinity,
        height: 50,
        child: _isLogin
            ? const Center(child: CircularProgressIndicator())
            : PrimaryButton(
                key: const Key('confirm-seed-button'),
                text: AppLocalizations.of(context).confirm,
                onPressed: _isButtonDisabled ? null : _onLoginPressed),
      ),
    );
  }

  void _onLoginPressed() {
    setState(() {
      _isButtonDisabled = true;
      _isLogin = true;
    });
    FocusScope.of(context).requestFocus(FocusNode());

    Navigator.pushReplacement<dynamic, dynamic>(
      context,
      MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => CreatePasswordPage(
                seed: controllerSeed.text.toString(),
              )),
    );
  }
}
