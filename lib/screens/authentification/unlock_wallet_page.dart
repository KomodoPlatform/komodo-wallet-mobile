import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/screens/authentification/welcome_page.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/widgets/password_visibility_control.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class UnlockWalletPage extends StatefulWidget {
  const UnlockWalletPage({
    Key key,
    @required this.wallet,
    this.onSuccess,
    this.isSignWithSeedIsEnabled = true,
    @required this.textButton,
    this.isCreatedPin = false,
  }) : super(key: key);

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
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: widget.isCreatedPin
              ? IconButton(
                  key: Key('settings-pin-logout'),
                  onPressed: () async {
                    await Db.deleteWallet(widget.wallet);
                    await authBloc.logout();
                    Navigator.pop(context);
                  },
                  color: Theme.of(context).errorColor,
                  icon: const Icon(Icons.exit_to_app),
                )
              : null,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onBackground,
          elevation: 0,
        ),
        body: ListView(
          key: const Key('unlock-wallet-scrollable'),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          children: <Widget>[
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(150)),
                  color: Theme.of(context).primaryColor,
                ),
                padding: const EdgeInsets.all(24.0),
                child: SvgPicture.asset(
                    Theme.of(context).brightness == Brightness.light
                        ? 'assets/svg_light/lock.svg'
                        : 'assets/svg/lock.svg',
                    semanticsLabel: 'Lock'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'UNLOCK',
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
            Text(
              'your wallet',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Builder(builder: (BuildContext context) {
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
                  hintText: AppLocalizations.of(context).hintEnterPassword,
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
            SizedBox(height: 24),
            Builder(
              builder: (BuildContext context) {
                return isLoading
                    ? Column(
                        children: <Widget>[
                          SizedBox(
                              height: 52,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              )),
                          SizedBox(
                            height: isLoading ? 8 : null,
                          ),
                          isLoading
                              ? Text(
                                  AppLocalizations.of(context).decryptingWallet,
                                  style: Theme.of(context).textTheme.bodyText2,
                                )
                              : SizedBox()
                        ],
                      )
                    : PrimaryButton(
                        key: const Key('unlock-wallet'),
                        onPressed:
                            isButtonLoginEnabled ? () => _login(context) : null,
                        text: widget.textButton,
                      );
              },
            ),
            //TODO(MRC): Convert to a fitting Button widget
            if (widget.isSignWithSeedIsEnabled) ...[
              SizedBox(height: 24),
              Center(
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  onTap: () {
                    Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) =>
                            const WelcomePage(isFromRestore: true),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context).signInWithSeedPhrase,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
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
      ScaffoldMessenger.of(mContext).showSnackBar(SnackBar(
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
