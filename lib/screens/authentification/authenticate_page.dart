import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/repeated_tap_detector.dart';
import '../../blocs/authenticate_bloc.dart';
import '../../blocs/wallet_bloc.dart';
import '../../localizations.dart';
import '../../model/wallet.dart';
import '../authentification/show_delete_wallet_confirmation.dart';
import '../authentification/unlock_wallet_page.dart';
import '../authentification/welcome_page.dart';
import '../../services/mm_service.dart';
import '../../widgets/select_language_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticatePage extends StatefulWidget {
  const AuthenticatePage({Key key}) : super(key: key);

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
    await prefs.remove('is_pin_creation_in_progress');
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
              : const BuildScreenAuth();
        });
  }
}

class BoxButton extends StatelessWidget {
  const BoxButton({
    Key key,
    this.text,
    this.assetPath,
    @required this.onPressed,
  }) : super(key: key);

  final String text;
  final String assetPath;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(8));

    return InkWell(
      borderRadius: borderRadius,
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            borderRadius: borderRadius,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(assetPath, height: 40),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  text.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BuildScreenAuthMultiWallets extends StatelessWidget {
  const BuildScreenAuthMultiWallets({Key key, this.wallets}) : super(key: key);

  final List<Wallet> wallets;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        children: <Widget>[
          Center(
            child: Image.asset(
              Theme.of(context).brightness == Brightness.light
                  ? 'assets/branding/mark_and_text_vertical_dark.png'
                  : 'assets/branding/mark_and_text_vertical_light.png',
              height: 200,
              width: 200,
              alignment: Alignment.center,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: const SelectLanguageButton(),
          ),
          SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: const <Widget>[
                Expanded(child: CreateWalletButton()),
                SizedBox(width: 16),
                Expanded(child: RestoreButton())
              ],
            ),
          ),
          SizedBox(height: 16),
          ...wallets.map<Widget>((element) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildItemWallet(element, context),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildItemWallet(Wallet wallet, BuildContext context) {
    return ListTile(
      key: Key('logged-out-wallet-' + wallet.name),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      tileColor: Colors.transparent,
      onTap: () => Navigator.push<dynamic>(
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
          ),
        ),
      ),
      leading: CircleAvatar(
        radius: 30,
        child: Center(
          child: Text(
            wallet.name.substring(0, 1),
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Theme.of(context).scaffoldBackgroundColor),
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.6),
      ),
      title: Text(
        wallet.name,
        style: Theme.of(context).textTheme.bodyText2,
      ),
      trailing: _buildDeleteButton(wallet, context),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black.withOpacity(0.3)
              : Colors.white.withOpacity(0.6),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
    );
  }

  Widget _buildDeleteButton(Wallet wallet, BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete_outline,
          size: 24,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black.withOpacity(0.3)
              : Colors.white.withOpacity(0.6)),
      onPressed: () async {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => UnlockWalletPage(
              textButton: AppLocalizations.of(context).unlock,
              wallet: wallet,
              isSignWithSeedIsEnabled: false,
              onSuccess: (_, String password) async {
                Navigator.of(context).pop();
                await showDeleteWalletConfirmation(
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
  const BuildScreenAuth({Key key}) : super(key: key);

  @override
  _BuildScreenAuthState createState() => _BuildScreenAuthState();
}

class _BuildScreenAuthState extends State<BuildScreenAuth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _FullAppLogo(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
                    child: Container(
                        alignment: const Alignment(1, 0),
                        child: const SelectLanguageButton()),
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
                        children: const <Widget>[
                          CreateWalletButton(),
                          SizedBox(
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
        ],
      ),
    );
  }
}

class _FullAppLogo extends StatelessWidget {
  const _FullAppLogo({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepeatedTapDetector(
      onRepeatedTap: () => _downloadLogs(context),
      tapTriggerCount: 7,
      child: SizedBox(
          height: 240,
          width: 240,
          child: Image.asset(Theme.of(context).brightness == Brightness.light
              ? 'assets/branding/mark_and_text_vertical_dark.png'
              : 'assets/branding/mark_and_text_vertical_light.png')),
    );
  }

  /// If the user taps the branding logo 7 times in a row, the app will
  /// download the logs and share them via the system share sheet. This is so
  /// that users can download logs even if they can't access the settings page.
  /// E.g. if the app crashes on login.
  void _downloadLogs(BuildContext context) {
    Log.downloadLogs().catchError((e) {
      _showSnackbar(context, e.toString());
    });
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class CreateWalletButton extends StatelessWidget {
  const CreateWalletButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BoxButton(
      key: const Key('createWalletButton'),
      text: AppLocalizations.of(context).createAWallet,
      assetPath: Theme.of(context).brightness == Brightness.light
          ? 'assets/svg_light/create_wallet.svg'
          : 'assets/svg/create_wallet.svg',
      onPressed: () => Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => const WelcomePage()),
      ),
    );
  }
}

class RestoreButton extends StatelessWidget {
  const RestoreButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BoxButton(
      key: const Key('restoreWallet'),
      text: AppLocalizations.of(context).restoreWallet,
      assetPath: Theme.of(context).brightness == Brightness.light
          ? 'assets/svg_light/lock_off.svg'
          : 'assets/svg/lock_off.svg',
      onPressed: () {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => const WelcomePage(
              isFromRestore: true,
            ),
          ),
        );
      },
    );
  }
}
