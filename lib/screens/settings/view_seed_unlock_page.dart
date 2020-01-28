import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/password_visibility_toggler.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';

class ViewSeedUnlockPage extends StatefulWidget {
  @override
  _ViewSeedUnlockPageState createState() => _ViewSeedUnlockPageState();
}

class _ViewSeedUnlockPageState extends State<ViewSeedUnlockPage> {
  bool passwordSuccess = false;
  String seed;

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0,
          title: Text(AppLocalizations.of(context).viewSeed.toUpperCase()),
          centerTitle: true,
          actions: <Widget>[
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text(AppLocalizations.of(context).done)),
              ),
            )
          ],
        ),
        body: Builder(builder: (BuildContext context) {
          return passwordSuccess
              ? ViewSeed(
                  seed: seed,
                  context: context,
                )
              : UnlockPassword(
                  currentWallet: walletBloc.currentWallet,
                  icon: SvgPicture.asset('assets/seed_logo.svg'),
                  onSuccess: (String data) {
                    setState(() {
                      seed = data;
                      passwordSuccess = true;
                    });
                  },
                  onError: (String data) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 2),
                      backgroundColor: Theme.of(context).errorColor,
                      content: Text(data),
                    ));
                  },
                );
        }),
      ),
    );
  }
}

class ViewSeed extends StatefulWidget {
  const ViewSeed({this.seed, this.context});

  final String seed;
  final BuildContext context;

  @override
  _ViewSeedState createState() => _ViewSeedState();
}

class _ViewSeedState extends State<ViewSeed> {
  List<Widget> seedWord = <Widget>[];

  @override
  void initState() {
    int i = 1;
    for (String word in widget.seed.split(' ')) {
      seedWord.add(RichText(
        text: TextSpan(
            style:
                Theme.of(widget.context).textTheme.body1.copyWith(fontSize: 22),
            children: <InlineSpan>[
              TextSpan(
                  text: i.toString().padLeft(2, '0'),
                  style: Theme.of(widget.context)
                      .textTheme
                      .body1
                      .copyWith(color: Theme.of(widget.context).accentColor)),
              TextSpan(
                  text: '. $word',
                  style: Theme.of(widget.context).textTheme.body1)
            ]),
      ));
      i++;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: false,
      padding: const EdgeInsets.only(top: 50, bottom: 32, right: 16, left: 16),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 50),
          child: GridView.count(
            shrinkWrap: true,
            primary: false,
            crossAxisCount: 2,
            mainAxisSpacing: 4.0,
            children: seedWord,
            childAspectRatio: 4.0,
            crossAxisSpacing: 4.0,
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SecondaryButton(
              text: AppLocalizations.of(context).clipboardCopy,
              onPressed: () {
                copyToClipBoard(context, widget.seed);
              },
            ),
          ),
        )
      ],
    );
  }
}

class UnlockPassword extends StatefulWidget {
  const UnlockPassword(
      {this.onSuccess, this.onError, this.icon, this.currentWallet});

  final Function(String) onSuccess;
  final Function(String) onError;
  final SvgPicture icon;
  final Wallet currentWallet;

  @override
  _UnlockPasswordState createState() => _UnlockPasswordState();
}

class _UnlockPasswordState extends State<UnlockPassword> {
  TextEditingController controller = TextEditingController();
  bool isContinueEnabled = false;
  bool isObscured = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const SizedBox(height: 32),
        widget.icon,
        const SizedBox(height: 100),
        Text(
          AppLocalizations.of(context).enterpassword,
          style: Theme.of(context).textTheme.body1,
        ),
        const SizedBox(height: 8),
        TextField(
          maxLength: 40,
          controller: controller,
          textInputAction: TextInputAction.done,
          onSubmitted: (String data) {
            _checkPassword(data);
          },
          onChanged: (String data) {
            setState(() {
              data.isNotEmpty
                  ? isContinueEnabled = true
                  : isContinueEnabled = false;
            });
          },
          autocorrect: false,
          obscureText: isObscured,
          enableInteractiveSelection: true,
          style: Theme.of(context).textTheme.body1,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorLight)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
            hintStyle: Theme.of(context).textTheme.body2,
            labelStyle: Theme.of(context).textTheme.body1,
            hintText: AppLocalizations.of(context).hintCurrentPassword,
            labelText: null,
            suffixIcon: PasswordVisibilityToggler(
              onVisibilityChange: (bool isPasswordObscured) {
                setState(() {
                  isObscured = isPasswordObscured;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : PrimaryButton(
                  text: AppLocalizations.of(context).checkSeedPhraseButton1,
                  onPressed: isContinueEnabled
                      ? () => _checkPassword(controller.text)
                      : null,
                ),
        )
      ],
    );
  }

  Future<void> _checkPassword(String data) async {
    final EncryptionTool entryptionTool = EncryptionTool();

    setState(() {
      isLoading = true;
    });
    final String seed = await entryptionTool.readData(
        KeyEncryption.SEED, widget.currentWallet, data);
    setState(() {
      isLoading = false;
    });
    if (seed != null) {
      widget.onSuccess(seed);
    } else {
      widget.onError(AppLocalizations.of(context).wrongPassword);
    }
  }
}
