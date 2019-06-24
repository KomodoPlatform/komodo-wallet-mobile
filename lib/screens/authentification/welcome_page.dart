import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/new_account_page.dart';
import 'package:komodo_dex/screens/settings/restore_seed_page.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class WelcomePage extends StatefulWidget {
  final bool isFromRestore;

  WelcomePage({this.isFromRestore = false});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  TextEditingController controller = new TextEditingController();
  bool isButtonLoginEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 16,
          ),
          SvgPicture.asset("assets/welcome_wallet.svg"),
          Center(
            child: Text(
              AppLocalizations.of(context).welcomeTitle,
              key: Key('titleCreateWallet'),
              style: Theme.of(context).textTheme.title.copyWith(fontSize: 32),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).to + " ",
                style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
              ),
              Text(
                AppLocalizations.of(context).welcomeName + " ",
                style: Theme.of(context).textTheme.body1.copyWith(
                    fontSize: 18, color: Theme.of(context).accentColor),
              ),
              Text(
                AppLocalizations.of(context).welcomeWallet,
                style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              AppLocalizations.of(context).welcomeInfo,
              style: Theme.of(context).textTheme.body2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
                maxLength: 40,
                controller: controller,
                onChanged: (str) {
                  if (str.length == 0 || str.length > 40) {
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
                  _newPage();
                },
                autocorrect: false,
                enableInteractiveSelection: true,
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
                    hintText: AppLocalizations.of(context).hintNameYourWallet,
                    labelText: null)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: PrimaryButton(
              onPressed: isButtonLoginEnabled ? () => _newPage() : null,
              text: AppLocalizations.of(context).welcomeLetSetUp,
            ),
          ),
          SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }

  _newPage() {
    if (isButtonLoginEnabled) {
      walletBloc.initCurrentWallet(controller.text);
      if (widget.isFromRestore) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RestoreSeedPage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewAccountPage()),
        );
      }
    }
  }
}
