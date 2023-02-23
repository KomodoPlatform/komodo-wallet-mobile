import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_config/app_config.dart';
import '../../generic_blocs/authenticate_bloc.dart';
import '../../generic_blocs/wallet_bloc.dart';
import '../../localizations.dart';
import '../../model/wallet.dart';
import '../../services/db/database.dart';
import '../../utils/encryption_tool.dart';
import '../../utils/log.dart';
import '../../widgets/eula_contents.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/scrollable_dialog.dart';
import '../../widgets/tac_contents.dart';

class DisclaimerPage extends StatefulWidget {
  const DisclaimerPage({
    Key? key,
    this.password,
    this.seed,
    this.onSuccess,
    this.readOnly = false,
  }) : super(key: key);

  final String? password;
  final String? seed;
  final Function? onSuccess;
  final bool readOnly;

  @override
  _DisclaimerPageState createState() => _DisclaimerPageState();
}

class _DisclaimerPageState extends State<DisclaimerPage>
    with TickerProviderStateMixin {
  bool isLoading = false;
  bool _checkBoxEULA = false;
  bool _checkBoxTOC = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget _tosControls = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          if (!widget.readOnly)
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Checkbox(
                      key: const Key('checkbox-eula'),
                      value: _checkBoxEULA,
                      onChanged: (bool? value) {
                        setState(() {
                          _checkBoxEULA = !_checkBoxEULA;
                        });
                      },
                    ),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          text: AppLocalizations.of(context)!.accepteula,
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ScrollableDialog(
                                      title: Text(
                                        AppLocalizations.of(context)!
                                            .eulaTitle1(appConfig.appName),
                                      ),
                                      children: [EULAContents()],
                                      verticalButtons: PrimaryButton(
                                        key: const Key('eula-close'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        text:
                                            AppLocalizations.of(context)!.close,
                                      ),
                                      mustScrollToBottom: false,
                                    );
                                  });
                            },
                          mouseCursor: SystemMouseCursors.click,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      key: const Key('checkbox-toc'),
                      value: _checkBoxTOC,
                      onChanged: (bool? value) {
                        setState(() {
                          _checkBoxTOC = !_checkBoxTOC;
                        });
                      },
                    ),
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          text: AppLocalizations.of(context)!.accepttac,
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ScrollableDialog(
                                      title: Text(
                                        AppLocalizations.of(context)!
                                            .eulaTitle2,
                                      ),
                                      children: [TACContents()],
                                      verticalButtons: PrimaryButton(
                                        key: const Key('tac-close'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        text:
                                            AppLocalizations.of(context)!.close,
                                      ),
                                      mustScrollToBottom: false,
                                    );
                                  });
                            },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    AppLocalizations.of(context)!.confirmeula,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ],
            ),
          SizedBox(height: 16),
          PrimaryButton(
            key: const Key('next-disclaimer'),
            onPressed: (!widget.readOnly && (_checkBoxEULA && _checkBoxTOC))
                ? _nextPage
                : null,
            text: widget.readOnly
                ? AppLocalizations.of(context)!.close
                : AppLocalizations.of(context)!.next,
            isLoading: isLoading,
          ),
          if (isLoading) ...[
            const SizedBox(
              height: 8,
            ),
            Text(
              AppLocalizations.of(context)!.encryptingWallet,
              style: Theme.of(context).textTheme.bodyText2,
            )
          ]
        ],
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.disclaimerAndTos),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onBackground,
        ),
        body: SafeArea(
          // On small screens and in split-screen mode
          // page controls (checkboxes, button) should not be docked
          // to the bottom of the screen
          child: Column(
            children: <Widget>[
              //
              _tosControls,
            ],
          ),
        ));
  }

  Future<void> _nextPage() async {
    if (widget.readOnly) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        isLoading = true;
      });

      final EncryptionTool encryptionTool = EncryptionTool();
      final Wallet wallet = walletBloc.currentWallet!;
      walletBloc.currentWallet = wallet;

      await encryptionTool
          .writeData(KeyEncryption.SEED, wallet, widget.password, widget.seed)
          .catchError((dynamic e) => Log.println('disclaimer_page:409', e));

      await Db.saveWallet(wallet);
      await Db.saveCurrentWallet(wallet);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('is_pin_creation_in_progress', true);

      await authBloc.loginUI(true, widget.seed, widget.password).then((_) {
        setState(() {
          isLoading = false;
        });
        widget.onSuccess!();
      });
    }
  }
}
