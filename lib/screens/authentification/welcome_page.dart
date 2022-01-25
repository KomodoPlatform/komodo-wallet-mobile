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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: ListView(
        key: const Key('welcome-scrollable'),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: <Widget>[
          SvgPicture.asset(Theme.of(context).brightness == Brightness.light
              ? 'assets/svg_light/welcome_wallet.svg'
              : 'assets/svg/welcome_wallet.svg'),
          Text(
            AppLocalizations.of(context).welcomeTitle,
            key: const Key('titleCreateWallet'),
            style: Theme.of(context).textTheme.headline5,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(AppLocalizations.of(context).to + ' ',
                  style: Theme.of(context).textTheme.subtitle1),
              Text(
                AppLocalizations.of(context).welcomeName + ' ',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              Text(AppLocalizations.of(context).welcomeWallet,
                  style: Theme.of(context).textTheme.subtitle1),
            ],
          ),
          SizedBox(height: 24),
          Text(
            AppLocalizations.of(context).welcomeInfo,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          SizedBox(height: 24),
          TextFormField(
            key: const Key('name-wallet-field'),
            maxLength: 40,
            controller: controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String str) {
              if (str.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    isButtonLoginEnabled = false;
                  });
                });
                return 'Wallet name must not be empty';
              }
              if (str.length > 40) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    isButtonLoginEnabled = false;
                  });
                });
                return 'Wallet name must have a max of 40 characters';
              }

              final allWallets = walletBloc.wallets;
              if (allWallets != null && allWallets.isNotEmpty) {
                final List<String> walletsNames =
                    allWallets.map((w) => w.name).toList();
                if (walletsNames.contains(str)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      isButtonLoginEnabled = false;
                    });
                  });
                  return 'Wallet name is already in use';
                }
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  isButtonLoginEnabled = true;
                });
              });
              return null;
            },
            onFieldSubmitted: (String data) => _newPage(),
            autocorrect: false,
            enableInteractiveSelection: true,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).hintNameYourWallet,
            ),
          ),
          SizedBox(height: 24),
          PrimaryButton(
            onPressed: isButtonLoginEnabled ? () => _newPage() : null,
            text: AppLocalizations.of(context).welcomeLetSetUp,
            key: const Key('welcome-setup'),
          ),
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
              builder: (BuildContext context) => const NewAccountPage()),
        );
      }
    }
  }
}
