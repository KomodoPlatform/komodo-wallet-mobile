import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/camo_bloc.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet_security_settings_provider.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/authentification/pin_page.dart';
import 'package:komodo_dex/screens/authentification/unlock_wallet_page.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class CamoPinSetupPage extends StatefulWidget {
  @override
  _CamoPinSetupPageState createState() => _CamoPinSetupPageState();
}

class _CamoPinSetupPageState extends State<CamoPinSetupPage> {
  String _matchingPinErrorMessage;
  WalletSecuritySettingsProvider walletSecuritySettingsProvider;

  @override
  Widget build(BuildContext context) {
    walletSecuritySettingsProvider =
        context.read<WalletSecuritySettingsProvider>();

    _matchingPinErrorMessage =
        AppLocalizations.of(context).matchingCamoPinError;
    _showMatchingPinPopupIfNeeded();

    return StreamBuilder<bool>(
        initialData: camoBloc.isCamoActive,
        stream: camoBloc.outIsCamoActive,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) return SizedBox();
          if (snapshot.data) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            });
            return SizedBox();
          }

          return LockScreen(
            context: context,
            child: Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context).camoPinTitle),
              ),
              body: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildSwitcher(),
                      _buildDescription(),
                      _buildPinSetup(),
                      _buildPercentSetup(),
                      _buildWarnings(),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildPercentSetup() {
    return StreamBuilder<int>(
      initialData: camoBloc.camoFraction,
      stream: camoBloc.outCamoFraction,
      builder: (context, AsyncSnapshot<int> camoFraction) {
        if (!camoFraction.hasData) return SizedBox();

        return StreamBuilder<bool>(
            initialData: camoBloc.isCamoEnabled,
            stream: camoBloc.outCamoEnabled,
            builder: (context, AsyncSnapshot<bool> camoEnabled) {
              if (!camoEnabled.hasData) return SizedBox();

              return Opacity(
                opacity: camoEnabled.data ? 1 : 0.5,
                child: Card(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Text(
                              AppLocalizations.of(context).fakeBalanceAmt,
                              style: const TextStyle(fontSize: 18),
                            )),
                            Text(
                              '${camoFraction.data}%',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                      Slider(
                          activeColor: Theme.of(context).colorScheme.secondary,
                          divisions: 50,
                          label: camoFraction.data.toString(),
                          min: 1,
                          max: 50,
                          value: camoFraction.data.toDouble(),
                          onChanged: camoEnabled.data
                              ? (double value) {
                                  camoBloc.camoFraction = value.round();
                                }
                              : null),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  Widget _buildWarnings() {
    return StreamBuilder<bool>(
        initialData: camoBloc.isCamoEnabled,
        stream: camoBloc.outCamoEnabled,
        builder: (context, camoEnabled) {
          if (camoEnabled.data != true) return SizedBox();

          return FutureBuilder<String>(
              future: EncryptionTool().read('pin'),
              builder: (context, AsyncSnapshot<String> normalPin) {
                if (!normalPin.hasData) return SizedBox();

                if (walletSecuritySettingsProvider.activatePinProtection) {
                  return FutureBuilder<String>(
                      future: EncryptionTool().read('camoPin'),
                      builder: (context, AsyncSnapshot<String> camoPin) {
                        if (!camoPin.hasData) return SizedBox();
                        if (camoPin.data != normalPin.data) return SizedBox();

                        return Container(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            _matchingPinErrorMessage,
                            style: TextStyle(
                              color: Theme.of(context).errorColor,
                              height: 1.2,
                            ),
                          ),
                        );
                      });
                } else {
                  return Container(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      AppLocalizations.of(context).generalPinNotActive,
                      style: TextStyle(
                        color: Theme.of(context).errorColor,
                        height: 1.2,
                      ),
                    ),
                  );
                }
              });
        });
  }

  Widget _buildPinSetup() {
    return FutureBuilder<String>(
        future: EncryptionTool().read('camoPin'),
        builder: (context, AsyncSnapshot<String> camoPinSnapshot) {
          final String camoPin =
              camoPinSnapshot.hasData ? camoPinSnapshot.data : null;

          return StreamBuilder<bool>(
              initialData: camoBloc.isCamoEnabled,
              stream: camoBloc.outCamoEnabled,
              builder: (context, AsyncSnapshot<bool> camoEnabledSnapshot) {
                if (!camoEnabledSnapshot.hasData) return SizedBox();

                final bool isEnabled = camoEnabledSnapshot.data;
                return Opacity(
                  opacity: isEnabled ? 1 : 0.5,
                  child: Card(
                    child: InkWell(
                      onTap: isEnabled ? () => _startPinSetup() : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: camoPin == null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          AppLocalizations.of(context)
                                              .camoPinNotFound,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: isEnabled
                                                ? Theme.of(context).errorColor
                                                : null,
                                          ),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)
                                              .camoPinCreate,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .color
                                                .withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        FutureBuilder<String>(
                                            future:
                                                EncryptionTool().read('pin'),
                                            builder: (context,
                                                AsyncSnapshot<String>
                                                    normalPin) {
                                              if (!normalPin.hasData)
                                                return SizedBox();

                                              if (normalPin.data !=
                                                  camoPinSnapshot.data)
                                                return Text(
                                                  AppLocalizations.of(context)
                                                      .camoPinSaved,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                );

                                              return Text(
                                                AppLocalizations.of(context)
                                                    .camoPinInvalid,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Theme.of(context)
                                                      .errorColor,
                                                ),
                                              );
                                            }),
                                        Text(
                                          AppLocalizations.of(context)
                                              .camoPinChange,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .color
                                                .withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            Icon(Icons.dialpad),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }

  void _startPinSetup() {
    Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => UnlockWalletPage(
                  textButton: AppLocalizations.of(context).unlock,
                  wallet: walletBloc.currentWallet,
                  isSignWithSeedIsEnabled: false,
                  onSuccess: (_, String password) {
                    Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => PinPage(
                                title:
                                    AppLocalizations.of(context).camoSetupTitle,
                                subTitle: AppLocalizations.of(context)
                                    .camoSetupSubtitle,
                                pinStatus: PinStatus.CREATE_CAMO_PIN,
                                password: password)));
                  },
                )));
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 24,
      ),
      child: Text(AppLocalizations.of(context).camoPinDesc,
          style: TextStyle(
            height: 1.3,
            color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.6),
          )),
    );
  }

  Widget _buildSwitcher() {
    return StreamBuilder<bool>(
        initialData: camoBloc.isCamoEnabled,
        stream: camoBloc.outCamoEnabled,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) return SizedBox();

          final bool isEnabled = snapshot.data;
          return Card(
            child: SwitchListTile(
              title: Text(isEnabled
                  ? AppLocalizations.of(context).camoPinOn
                  : AppLocalizations.of(context).camoPinOff),
              value: isEnabled,
              onChanged: (bool value) => _switchEnabled(value),
            ),
          );
        });
  }

  Future<void> _switchEnabled(bool val) async {
    camoBloc.isCamoEnabled = val;

    final String savedPin = await EncryptionTool().read('camoPin');
    if (val && savedPin == null) _startPinSetup();
  }

  Future<void> _showMatchingPinPopupIfNeeded() async {
    if (!camoBloc.shouldWarnBadCamoPin) return;

    final String normalPin = await EncryptionTool().read('pin');
    final String camoPin = await EncryptionTool().read('camoPin');

    if (normalPin == null || camoPin == null) return;
    if (normalPin.isEmpty || camoPin.isEmpty) return;
    if (normalPin != camoPin) return;

    showConfirmationDialog(
        context: context,
        title: AppLocalizations.of(context).matchingCamoTitle,
        message: _matchingPinErrorMessage,
        iconColor: Theme.of(context).errorColor,
        confirmButtonText: AppLocalizations.of(context).matchingCamoChange,
        onConfirm: () {
          _startPinSetup();
        });

    setState(() {
      camoBloc.shouldWarnBadCamoPin = false;
    });
  }
}
