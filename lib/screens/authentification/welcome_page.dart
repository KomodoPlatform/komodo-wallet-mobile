import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/new_account_page.dart';
import 'package:komodo_dex/screens/settings/restore_seed_page.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({this.isFromRestore = false});

  final bool isFromRestore;

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  TextEditingController controller = TextEditingController();
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
        key: const Key('welcome-scrollable'),
        children: <Widget>[
          const SizedBox(
            height: 16,
          ),
          SvgPicture.asset('assets/svg/welcome_wallet.svg'),
          Center(
            child: Text(
              AppLocalizations.of(context).welcomeTitle,
              key: const Key('titleCreateWallet'),
              style:
                  Theme.of(context).textTheme.headline6.copyWith(fontSize: 32),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).to + ' ',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 18),
              ),
              Text(
                AppLocalizations.of(context).welcomeName + ' ',
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontSize: 18, color: Theme.of(context).accentColor),
              ),
              Text(
                AppLocalizations.of(context).welcomeWallet,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 18),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              AppLocalizations.of(context).welcomeInfo,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
                key: const Key('name-wallet-field'),
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
                  _newPage();
                },
                autocorrect: false,
                enableInteractiveSelection: true,
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
                    hintText: AppLocalizations.of(context).hintNameYourWallet,
                    labelText: null)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PrimaryButton(
              onPressed: isButtonLoginEnabled ? () => _newPage() : null,
              text: AppLocalizations.of(context).welcomeLetSetUp,
              key: const Key('welcome-setup'),
            ),
          ),
          const SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }

  void _newPage() {
    if (isButtonLoginEnabled) {
      walletBloc.initCurrentWallet(controller.text);
      if (widget.isFromRestore) {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => RestoreSeedPage()),
        );
      } else {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => NewAccountPage()),
        );
      }
    }
  }
}
