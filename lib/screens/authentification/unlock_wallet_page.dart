import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/screens/authentification/welcome_page.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/widgets/password_visibility_control.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class UnlockWalletPage extends StatefulWidget {
  const UnlockWalletPage(
      {@required this.wallet,
      this.onSuccess,
      this.isSignWithSeedIsEnabled = true,
      @required this.textButton,
      this.isCreatedPin = false});

  final Wallet wallet;
  final Function(String seed, String password) onSuccess;
  final bool isSignWithSeedIsEnabled;
  final String textButton;
  final bool isCreatedPin;

  @override
  _UnlockWalletPageState createState() => _UnlockWalletPageState();
}

class _UnlockWalletPageState extends State<UnlockWalletPage> {
  TextEditingController controller = TextEditingController();
  bool isLoading = false;
  bool isButtonLoginEnabled = false;
  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !widget.isCreatedPin,
      child: Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: widget.isCreatedPin
            ? AppBar(
                leading: InkWell(
                    onTap: () async {
                      await Db.deleteWallet(widget.wallet);
                      await authBloc.logout();
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.exit_to_app,
                      key: const Key('settings-pin-logout'),
                      color: Colors.red,
                    )),
                backgroundColor: Theme.of(context).backgroundColor,
                elevation: 0,
              )
            : AppBar(
                backgroundColor: Theme.of(context).backgroundColor,
                elevation: 0,
              ),
        body: ListView(
          key: const Key('unlock-wallet-scrollable'),
          children: <Widget>[
            Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(150)),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SvgPicture.asset(
                        settingsBloc.getValueIfSwitch(
                            'assets/svg_light/lock.svg', 'assets/svg/lock.svg'),
                        semanticsLabel: 'Lock'),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Center(
              child: Text(
                'UNLOCK',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontSize: 48),
              ),
            ),
            Center(
              child: Text(
                'your wallet',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontWeight: FontWeight.w100, fontSize: 24),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Builder(builder: (BuildContext context) {
                  return TextField(
                    key: const Key('enter-password-field'),
                    maxLength: 40,
                    controller: controller,
                    onChanged: (String str) {
                      if (str.isEmpty || str.length > 40) {
                        setState(() {
                          isButtonLoginEnabled = false;
                        });
                      } else {
                        setState(() {
                          isButtonLoginEnabled = true;
                        });
                      }
                    },
                    onSubmitted: (String data) {
                      _login(context);
                    },
                    autocorrect: false,
                    obscureText: isObscured,
                    enableInteractiveSelection: true,
                    toolbarOptions: ToolbarOptions(
                      paste: controller.text.isEmpty,
                      copy: false,
                      cut: false,
                      selectAll: false,
                    ),
                    style: Theme.of(context).textTheme.bodyText2,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColorLight)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).accentColor)),
                      hintStyle: Theme.of(context).textTheme.bodyText1,
                      labelStyle: Theme.of(context).textTheme.bodyText2,
                      hintText: AppLocalizations.of(context).hintEnterPassword,
                      labelText: null,
                      suffixIcon: PasswordVisibilityControl(
                        isFocused: false,
                        onVisibilityChange: (bool isPasswordObscured) {
                          setState(() {
                            isObscured = isPasswordObscured;
                          });
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),
            Builder(
              builder: (BuildContext context) {
                return isLoading
                    ? Column(
                        children: <Widget>[
                          Container(
                              height: 52,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              )),
                          isLoading
                              ? const SizedBox(
                                  height: 8,
                                )
                              : Container(),
                          isLoading
                              ? Text(
                                  AppLocalizations.of(context).decryptingWallet,
                                  style: Theme.of(context).textTheme.bodyText2,
                                )
                              : Container()
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 100),
                        child: PrimaryButton(
                          key: const Key('unlock-wallet'),
                          onPressed: isButtonLoginEnabled
                              ? () => _login(context)
                              : null,
                          text: widget.textButton,
                        ));
              },
            ),
            widget.isSignWithSeedIsEnabled
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        onTap: () {
                          Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                                builder: (BuildContext context) =>
                                    const WelcomePage(
                                      isFromRestore: true,
                                    )),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(context).signInWithSeedPhrase,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            const SizedBox(
              height: 16,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _login(BuildContext mContext) async {
    setState(() {
      isLoading = true;
    });

    walletBloc
        .loginWithPassword(context, controller.text, widget.wallet)
        .then((String data) async {
      await widget.onSuccess(data, controller.text);
      setState(() {
        isLoading = false;
      });
    }).catchError((dynamic onError) {
      Scaffold.of(mContext).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(mContext).errorColor,
        content: Text(AppLocalizations.of(context).wrongPassword),
      ));
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }
}
