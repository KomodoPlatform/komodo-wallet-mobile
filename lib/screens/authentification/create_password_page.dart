import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/main.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';

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
  String _password;

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
            TextFormField(
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
                obscureText: true,
                validator: (String arg) {
                  RegExp exp = RegExp(
                      r'^(?:(?=.*[a-z])(?:(?=.*[A-Z])(?=.*[\W])|(?=.*\W))|(?=.*\W)(?=.*[A-Z])).{12,}$');
                  if (!arg.contains(exp))
                    return 'Password must be more than 12 charaters, with one lower-case, one upper-case and one special symbol.';
                  else
                    return null;
                },
                onSaved: (String val) {
                  _password = val;
                },
                style: Theme.of(context).textTheme.body1,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    errorMaxLines: 3,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColorLight)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).accentColor)),
                    hintStyle: Theme.of(context).textTheme.body2,
                    labelStyle: Theme.of(context).textTheme.body1,
                    hintText: AppLocalizations.of(context).hintPassword,
                    labelText: null)),
            SizedBox(
              height: 8,
            ),
            Builder(builder: (context) {
              return TextFormField(
                  maxLength: 40,
                  controller: controller2,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  focusNode: _focus2,
                  obscureText: true,
                  enableInteractiveSelection: true,
                  onFieldSubmitted: (data) {
                    _checkValidation(context);
                  },
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
                      hintText:
                          AppLocalizations.of(context).hintConfirmPassword,
                      labelText: null));
            }),
            SizedBox(
              height: 16,
            ),
            Builder(builder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: PrimaryButton(
                  text: AppLocalizations.of(context).confirmPassword,
                  onPressed:
                      isValidPassword ? () => _checkValidation(context) : null,
                  isLoading: isLoading,
                ),
              );
            }),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SecondaryButton(
                text: AppLocalizations.of(context).dontWantPassword,
                onPressed: () => _showDialogConfirm(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  _showDialogConfirm(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(16),
            backgroundColor: Colors.white,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(8.0)),
            title: Column(
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  size: 40,
                  color: Theme.of(context).accentColor,
                ),
                Text(AppLocalizations.of(context).areYouSure,
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .copyWith(color: Theme.of(context).accentColor))
              ],
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Center(
                    child: Text(
                  AppLocalizations.of(context).infoPasswordDialog,
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                )),
              ),
              SizedBox(
                height: 24,
              ),
              PrimaryButton(
                text: AppLocalizations.of(context).setUpPassword,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(
                height: 16,
              ),
              SecondaryButton(
                  text: AppLocalizations.of(context).dontWantPassword,
                  onPressed: () => _nextPage(false),
                  isDarkMode: false)
            ],
          );
        });
  }

  _checkValidation(BuildContext context) {
    if (_validateInputs()) {
      if (controller1.text == controller2.text) {
        _nextPage(true);
      } else {
        _showError(context, AppLocalizations.of(context).wrongPassword);
      }
    }
  }

  _nextPage(bool isPasswordSaved) async {
    setState(() {
      isLoading = true;
    });
    if (isPasswordSaved) {
      var entryptionTool = new EncryptionTool();
      var wallet = walletBloc.currentWallet;

      await entryptionTool.writeData(
          KeyEncryption.SEED, wallet, controller1.text, widget.seed);
      await DBProvider.db.saveWallet(wallet);
      await DBProvider.db.saveCurrentWallet(wallet);
    }

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
    print("SNACKBAR");
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
