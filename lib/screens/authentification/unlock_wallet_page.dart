import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/screens/settings/restore_seed_page.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class UnlockWalletPage extends StatefulWidget {
  const UnlockWalletPage(
      {@required this.wallet,
      this.onSuccess,
      this.isSignWithSeedIsEnabled = true,
      @required this.textButton});

  final Wallet wallet;
  final Function(String seed, String password) onSuccess;
  final bool isSignWithSeedIsEnabled;
  final String textButton;

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
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(150)),
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SvgPicture.asset('assets/lock.svg',
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
              style: Theme.of(context).textTheme.title.copyWith(fontSize: 48),
            ),
          ),
          Center(
            child: Text(
              'your wallet',
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(fontWeight: FontWeight.w100, fontSize: 24),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Builder(builder: (BuildContext context) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
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
                          enableInteractiveSelection: false,
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
                                  .hintEnterPassword,
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
                            child: Center(
                              child: const CircularProgressIndicator(),
                            )),
                        isLoading
                            ? const SizedBox(
                                height: 8,
                              )
                            : Container(),
                        isLoading
                            ? Text(
                                AppLocalizations.of(context).decryptingWallet,
                                style: Theme.of(context).textTheme.body1,
                              )
                            : Container()
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: PrimaryButton(
                        onPressed:
                            isButtonLoginEnabled ? () => _login(context) : null,
                        text: widget.textButton,
                      ));
            },
          ),
          widget.isSignWithSeedIsEnabled
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      onTap: () {
                        Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) => RestoreSeedPage()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          AppLocalizations.of(context).signInWithSeedPhrase,
                          style: Theme.of(context).textTheme.body2.copyWith(
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
    );
  }

  Future<void>_login(BuildContext context) async {
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
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).errorColor,
        content: Text(onError),
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
