import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/screens/restore_seed_page.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';

class UnlockWalletPage extends StatefulWidget {
  final Wallet wallet;
  final Function(String seed, String password) onSuccess;
  final bool isSignWithSeedIsEnabled;
  final String textButton;

  UnlockWalletPage(
      {@required this.wallet,
      this.onSuccess,
      this.isSignWithSeedIsEnabled = true,
      @required this.textButton});

  @override
  _UnlockWalletPageState createState() => _UnlockWalletPageState();
}

class _UnlockWalletPageState extends State<UnlockWalletPage> {
  TextEditingController controller = new TextEditingController();
  bool isLoading = false;
  bool isButtonLoginEnabled = false;

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
              borderRadius: BorderRadius.all(Radius.circular(150)),
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SvgPicture.asset("assets/lock.svg",
                      semanticsLabel: 'Lock'),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Center(
            child: Text(
              "UNLOCK",
              style: Theme.of(context).textTheme.title.copyWith(fontSize: 48),
            ),
          ),
          Center(
            child: Text(
              "your wallet",
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(fontWeight: FontWeight.w100, fontSize: 24),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Builder(builder: (context) {
                return TextField(
                    maxLength: 120,
                    controller: controller,
                    onChanged: (str) {
                      if (str.length == 0 || str.length > 120) {
                        setState(() {
                          isButtonLoginEnabled = false;
                        });
                      } else {
                        setState(() {
                          isButtonLoginEnabled = true;
                        });
                      }
                    },
                    onSubmitted: (data) {
                      _login(context);
                    },
                    autocorrect: false,
                    obscureText: true,
                    enableInteractiveSelection: false,
                    style: Theme.of(context).textTheme.body1,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColorLight)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor)),
                        hintStyle: Theme.of(context).textTheme.body2,
                        labelStyle: Theme.of(context).textTheme.body1,
                        hintText:
                            AppLocalizations.of(context).hintEnterPassword,
                        labelText: null));
              }),
            ),
          ),
          Builder(
            builder: (BuildContext context) {
              return isLoading
                  ? Container(
                      height: 52,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ))
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
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RestoreSeedPage()),
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
          SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }

  _login(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    walletBloc
        .loginWithPassword(context, controller.text, widget.wallet)
        .then((data) async {
      Navigator.of(context).pop();
      widget.onSuccess(data, controller.text);
    }).catchError((onError) {
      print(onError);
      Scaffold.of(context).showSnackBar(new SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).errorColor,
        content: new Text(onError),
      ));
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }
}
