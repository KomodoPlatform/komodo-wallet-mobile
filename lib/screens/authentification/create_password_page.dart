import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class CreatePasswordPage extends StatefulWidget {
  final String seed;

  CreatePasswordPage({@required this.seed});

  @override
  _CreatePasswordPageState createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  TextEditingController controller1 = new TextEditingController();
  TextEditingController controller2 = new TextEditingController();
  final FocusNode _focus1 = FocusNode();
  final FocusNode _focus2 = FocusNode();
  bool isLoading = false;
  bool isValidPassword = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool isObscured = true;
  bool isFastEncrypted = false;

  @override
  void initState() {
    controller2.addListener(_onChange);
    controller1.addListener(_onChange);
    super.initState();
  }

  void _onChange() {
    String text = controller1.text;
    String text2 = controller2.text;
    if (text.isEmpty ||
        text2.isEmpty ||
        !_formKey.currentState.validate() ||
        controller1.text != controller2.text) {
      setState(() {
        isValidPassword = false;
      });
    } else {
      setState(() {
        isValidPassword = true;
      });
    }
  }

  bool _validateInputs() {
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      return true;
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Text(
              "CREATE A PASSWORD",
              style: Theme.of(context).textTheme.title,
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              AppLocalizations.of(context).infoWalletPassword,
              style: Theme.of(context).textTheme.body2,
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                      maxLength: 40,
                      focusNode: _focus1,
                      controller: controller1,
                      onFieldSubmitted: (term) {
                        _fieldFocusChange(context, _focus1, _focus2);
                        _validateInputs();
                      },
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableInteractiveSelection: true,
                      obscureText: isObscured,
                      validator: (String arg) {
                        RegExp exp = RegExp(
                            r'^(?:(?=.*[a-z])(?:(?=.*[A-Z])(?=.*[\W])|(?=.*\W))|(?=.*\W)(?=.*[A-Z])).{12,}$');
                        if (!arg.contains(exp))
                          return 'Password must be more than 12 charaters, with one lower-case, one upper-case and one special symbol.';
                        else
                          return null;
                      },
                      style: Theme.of(context).textTheme.body1,
                      decoration: InputDecoration(
                          errorMaxLines: 3,
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorLight)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).accentColor)),
                          hintStyle: Theme.of(context).textTheme.body2,
                          labelStyle: Theme.of(context).textTheme.body1,
                          hintText: AppLocalizations.of(context).hintPassword,
                          labelText: null)),
                ),
                SizedBox(
                  width: 8,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isObscured = !isObscured;
                    });
                  },
                  child: Container(
                      height: 60,
                      padding: EdgeInsets.only(right: 16, left: 16),
                      child: isObscured
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off)),
                )
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Builder(builder: (context) {
              return Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                        maxLength: 40,
                        controller: controller2,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        focusNode: _focus2,
                        obscureText: isObscured,
                        enableInteractiveSelection: true,
                        onFieldSubmitted: (data) {
                          _checkValidation(context);
                        },
                        style: Theme.of(context).textTheme.body1,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).primaryColorLight)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).accentColor)),
                            hintStyle: Theme.of(context).textTheme.body2,
                            labelStyle: Theme.of(context).textTheme.body1,
                            hintText: AppLocalizations.of(context)
                                .hintConfirmPassword,
                            labelText: null)),
                  ),
                  SizedBox(
                    width: 72,
                  ),
                ],
              );
            }),
            Row(
              children: <Widget>[
                Switch(
                  onChanged: (bool value) {
                    setState(() {
                      isFastEncrypted = value;
                    });
                  },
                  value: isFastEncrypted,
                ),
                Text("Fast encryption", style: Theme.of(context).textTheme.body2,)
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Builder(builder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: <Widget>[
                    PrimaryButton(
                      text: AppLocalizations.of(context).confirmPassword,
                      onPressed: isValidPassword
                          ? () => _checkValidation(context)
                          : null,
                      isLoading: isLoading,
                    ),
                    isLoading
                        ? SizedBox(
                            height: 8,
                          )
                        : Container(),
                    isLoading
                        ? Text(
                            AppLocalizations.of(context).encryptingWallet,
                            style: Theme.of(context).textTheme.body1,
                          )
                        : Container()
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  _checkValidation(BuildContext context) {
    if (_validateInputs()) {
      if (controller1.text == controller2.text) {
        _nextPage();
      } else {
        _showError(context, AppLocalizations.of(context).wrongPassword);
      }
    }
  }

  _nextPage() async {
    setState(() {
      isLoading = true;
    });

    var entryptionTool = new EncryptionTool();
    var wallet = walletBloc.currentWallet;
    wallet.isFastEncryption = isFastEncrypted;
    walletBloc.currentWallet = wallet;

    await entryptionTool.writeData(
        KeyEncryption.SEED, wallet, controller1.text, widget.seed);
    await DBProvider.db.saveWallet(wallet);
    await DBProvider.db.saveCurrentWallet(wallet);
    await coinsBloc.resetCoinDefault();

    await authBloc
        .loginUI(false, widget.seed, controller1.text)
        .then((onValue) {
      setState(() {
        isLoading = true;
      });
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false,
          arguments: ScreenArguments(controller1.text));
    });
  }

  _showError(BuildContext context, String data) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      duration: Duration(seconds: 2),
      backgroundColor: Theme.of(context).errorColor,
      content: new Text(data),
    ));
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}

class ScreenArguments {
  final String password;

  ScreenArguments(
    this.password,
  );
}
