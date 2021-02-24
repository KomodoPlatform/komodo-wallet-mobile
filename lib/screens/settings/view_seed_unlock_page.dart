import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/settings/view_private_keys.dart';
import 'package:komodo_dex/screens/settings/view_seed.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/widgets/password_visibility_control.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

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
          title:
              Text(AppLocalizations.of(context).viewSeedAndKeys.toUpperCase()),
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
              ? ListView(
                  children: [
                    ViewSeed(
                      seed: seed,
                      context: context,
                    ),
                    ViewPrivateKeys(),
                  ],
                )
              : UnlockPassword(
                  currentWallet: walletBloc.currentWallet,
                  icon: SvgPicture.asset('assets/svg/seed_logo.svg'),
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
          style: Theme.of(context).textTheme.bodyText2,
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
          toolbarOptions: ToolbarOptions(
            paste: controller.text.isEmpty,
            copy: false,
            cut: false,
            selectAll: false,
          ),
          style: Theme.of(context).textTheme.bodyText2,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorLight)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
            hintStyle: Theme.of(context).textTheme.bodyText1,
            labelStyle: Theme.of(context).textTheme.bodyText2,
            hintText: AppLocalizations.of(context).hintCurrentPassword,
            labelText: null,
            suffixIcon: PasswordVisibilityControl(
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
