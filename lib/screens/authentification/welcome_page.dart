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
      ),
      body: ListView(
        key: const Key('welcome-scrollable'),
        children: <Widget>[
          const SizedBox(
            height: 16,
          ),
          SvgPicture.asset(Theme.of(context).brightness == Brightness.light
              ? 'assets/svg_light/welcome_wallet.svg'
              : 'assets/svg/welcome_wallet.svg'),
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
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
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
            child: TextFormField(
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
              onFieldSubmitted: (String data) {
                _newPage();
              },
              autocorrect: false,
              enableInteractiveSelection: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).hintNameYourWallet,
              ),
            ),
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
              builder: (BuildContext context) => const NewAccountPage()),
        );
      }
    }
  }
}
