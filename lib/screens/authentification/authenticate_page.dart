import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/screens/authentification/showDeleteWalletConfirmation.dart';
import 'package:komodo_dex/screens/authentification/unlock_wallet_page.dart';
import 'package:komodo_dex/screens/authentification/welcome_page.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticatePage extends StatefulWidget {
  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  @override
  void initState() {
    walletBloc.getWalletsSaved();
    initPinCreated();
    super.initState();
  }

  Future<void> initPinCreated() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isPinIsCreated', false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Wallet>>(
        initialData: walletBloc.wallets,
        stream: walletBloc.outWallets,
        builder: (BuildContext context, AsyncSnapshot<List<Wallet>> snapshot) {
          return snapshot.data.isNotEmpty
              ? BuildScreenAuthMultiWallets(
                  wallets: snapshot.data,
                )
              : BuildScreenAuth();
        });
  }
}

class BoxButton extends StatelessWidget {
  const BoxButton(
      {Key key, this.text, this.assetPath, @required this.onPressed})
      : super(key: key);

  final String text;
  final String assetPath;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(8));

    return InkWell(
      borderRadius: borderRadius,
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .color
                      .withOpacity(0.3)),
              borderRadius: borderRadius,
              color:
                  Theme.of(context).textTheme.bodyText2.color.withOpacity(0.1)),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: Center(
                child: Column(
              children: <Widget>[
                Container(height: 40, child: SvgPicture.asset(assetPath)),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  text.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText2,
                )
              ],
            )),
          ),
        ),
      ),
    );
  }
}

class BuildScreenAuthMultiWallets extends StatefulWidget {
  const BuildScreenAuthMultiWallets({this.wallets});

  final List<Wallet> wallets;

  @override
  _BuildScreenAuthMultiWalletsState createState() =>
      _BuildScreenAuthMultiWalletsState();
}

class _BuildScreenAuthMultiWalletsState
    extends State<BuildScreenAuthMultiWallets> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const SizedBox(
                height: 16,
              ),
              Center(
                child: Container(
                    height: 200,
                    width: 200,
                    child: Image.asset(settingsBloc.isLightTheme
                        ? 'assets/mark_and_text_vertical_dark.png'
                        : 'assets/mark_and_text_vertical_light.png')),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(child: CreateWalletButton()),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(child: RestoreButton())
                  ],
                ),
              ),
              Column(
                children: widget.wallets.map<Widget>((wallet) {
                  return _buildItemWallet(wallet);
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemWallet(Wallet wallet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: () {
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => UnlockWalletPage(
                      textButton: AppLocalizations.of(context).login,
                      wallet: wallet,
                      onSuccess: (String seed, String password) async {
                        authBloc.showLock = false;
                        if (!mmSe.running) {
                          await authBloc.login(seed, password);
                        }
                        Navigator.of(context).pop();
                      },
                    )),
          );
        },
        child: Container(
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CircleAvatar(
                    radius: 30,
                    child: Center(
                      child: Text(
                        wallet.name.substring(0, 1),
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: Theme.of(context).backgroundColor),
                      ),
                    ),
                    backgroundColor: settingsBloc.isLightTheme
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Text(
                    wallet.name,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                _buildDeleteButton(wallet),
              ],
            ),
            decoration: BoxDecoration(
                border: Border.all(
                    color: settingsBloc.isLightTheme
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white.withOpacity(0.6)),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                color: Colors.transparent)),
      ),
    );
  }

  Widget _buildDeleteButton(Wallet wallet) {
    return IconButton(
      padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
      icon: Icon(
        Icons.delete_outline,
        size: 24,
        color: settingsBloc.isLightTheme
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.6),
      ),
      // TODO(MateusRodCosta): Unify this and _showDialogDeleteWallet from settings_page
      // into a single method with different callbacks for when the user accepts deleting
      // the wallet.
      onPressed: () async {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => UnlockWalletPage(
              textButton: AppLocalizations.of(context).unlock,
              wallet: wallet,
              isSignWithSeedIsEnabled: false,
              onSuccess: (_, String password) {
                Navigator.of(context).pop();
                showDeleteWalletConfirmation(
                  context,
                  wallet: wallet,
                  password: password,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class BuildScreenAuth extends StatefulWidget {
  @override
  _BuildScreenAuthState createState() => _BuildScreenAuthState();
}

class _BuildScreenAuthState extends State<BuildScreenAuth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      height: 240,
                      width: 240,
                      child: Image.asset(settingsBloc.isLightTheme
                          ? 'assets/mark_and_text_vertical_dark.png'
                          : 'assets/mark_and_text_vertical_light.png')),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      CreateWalletButton(),
                      const SizedBox(
                        height: 16,
                      ),
                      RestoreButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateWalletButton extends StatefulWidget {
  @override
  _CreateWalletButtonState createState() => _CreateWalletButtonState();
}

class _CreateWalletButtonState extends State<CreateWalletButton> {
  @override
  Widget build(BuildContext context) {
    return BoxButton(
      key: const Key('createWalletButton'),
      text: AppLocalizations.of(context).createAWallet,
      assetPath: settingsBloc.isLightTheme
          ? 'assets/svg_light/create_wallet.svg'
          : 'assets/svg/create_wallet.svg',
      onPressed: () {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => const WelcomePage()),
        );
      },
    );
  }
}

class RestoreButton extends StatefulWidget {
  @override
  _RestoreButtonState createState() => _RestoreButtonState();
}

class _RestoreButtonState extends State<RestoreButton> {
  @override
  Widget build(BuildContext context) {
    return BoxButton(
      key: const Key('restoreWallet'),
      text: AppLocalizations.of(context).restoreWallet,
      assetPath: settingsBloc.isLightTheme
          ? 'assets/svg_light/lock_off.svg'
          : 'assets/svg/lock_off.svg',
      onPressed: () {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => const WelcomePage(
                    isFromRestore: true,
                  )),
        );
      },
    );
  }
}
