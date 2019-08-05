import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/dislaimer_page.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({@required this.seed});

  final String seed;

  @override
  _CreatePasswordPageState createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
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
    final String text = controller1.text;
    final String text2 = controller2.text;
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
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const SizedBox(
              height: 16,
            ),
            Text(
              AppLocalizations.of(context).titleCreatePassword,
              style: Theme.of(context).textTheme.title,
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                      key: const Key('create-password-field'),
                      maxLength: 40,
                      focusNode: _focus1,
                      controller: controller1,
                      onFieldSubmitted: (String term) {
                        _fieldFocusChange(context, _focus1, _focus2);
                        _validateInputs();
                      },
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableInteractiveSelection: true,
                      obscureText: isObscured,
                      validator: (String arg) {
                        final RegExp exp = RegExp(
                            r'^(?:(?=.*[a-z])(?:(?=.*[A-Z])(?=.*[\W])|(?=.*\W))|(?=.*\W)(?=.*[A-Z])).{12,}$');
                        return !arg.contains(exp)
                            ? 'Password must contain at least 12 characters, with one lower-case, one upper-case and one special symbol.'
                            : null;
                      },
                      style: Theme.of(context).textTheme.body1,
                      decoration: InputDecoration(
                          errorMaxLines: 6,
                          errorStyle: Theme.of(context)
                              .textTheme
                              .body1
                              .copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context).errorColor),
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
                const SizedBox(
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
                      padding: const EdgeInsets.only(right: 16, left: 16),
                      child: isObscured
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off)),
                )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Builder(builder: (BuildContext context) {
              return Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                        key: const Key('create-password-field-confirm'),
                        maxLength: 40,
                        controller: controller2,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        focusNode: _focus2,
                        obscureText: isObscured,
                        enableInteractiveSelection: true,
                        onFieldSubmitted: (String data) {
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
                  const SizedBox(
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
                Text(
                  'Fast encryption',
                  style: Theme.of(context).textTheme.body2,
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Builder(builder: (BuildContext context) {
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
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _checkValidation(BuildContext context) {
    if (_validateInputs()) {
      if (controller1.text == controller2.text) {
        _nextPage();
      } else {
        _showError(context, AppLocalizations.of(context).wrongPassword);
      }
    }
  }

  Future<void> _nextPage() async {
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => DislaimerPage(
                isFastEncrypted: isFastEncrypted,
                password: controller1.text,
                seed: widget.seed,
                onSuccess: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false,
                      arguments: ScreenArguments(controller1.text));
                },
              )),
    );
  }

  void _showError(BuildContext context, String data) {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).errorColor,
      content: Text(data),
    ));
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}

class ScreenArguments {
  ScreenArguments(
    this.password,
  );
  final String password;
}
