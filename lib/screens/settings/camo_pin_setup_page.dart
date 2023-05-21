import 'package:flutter/material.dart';
import 'package:komodo_dex/login/models/pin_type.dart';
import 'package:komodo_dex/packages/pin_reset/bloc/pin_reset_bloc.dart';
import '../../generic_blocs/camo_bloc.dart';
import '../../generic_blocs/wallet_bloc.dart';
import '../../localizations.dart';
import '../../model/wallet_security_settings_provider.dart';
import '../authentification/lock_screen.dart';
import '../../utils/encryption_tool.dart';
import 'package:provider/provider.dart';

class CamoPinSetupPage extends StatefulWidget {
  @override
  _CamoPinSetupPageState createState() => _CamoPinSetupPageState();
}

class _CamoPinSetupPageState extends State<CamoPinSetupPage> {
  String? _matchingPinErrorMessage;
  late WalletSecuritySettingsProvider walletSecuritySettingsProvider;

  @override
  Widget build(BuildContext context) {
    walletSecuritySettingsProvider =
        context.read<WalletSecuritySettingsProvider>();

    _matchingPinErrorMessage =
        AppLocalizations.of(context)!.matchingCamoPinError;

    if (walletSecuritySettingsProvider.activateBioProtection &&
        camoBloc.isCamoEnabled) {
      camoBloc.isCamoEnabled = false;
    }
    return StreamBuilder<bool>(
        initialData: camoBloc.isCamoActive,
        stream: camoBloc.outIsCamoActive,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) return SizedBox();
          if (snapshot.data!) {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            });
            return SizedBox();
          }

          return LockScreen(
            context: context,
            child: Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.camoPinTitle),
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
                opacity: camoEnabled.data! ? 1 : 0.5,
                child: Card(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Text(
                              AppLocalizations.of(context)!.fakeBalanceAmt,
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
                          value: camoFraction.data!.toDouble(),
                          onChanged: camoEnabled.data!
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
    if (walletSecuritySettingsProvider.activateBioProtection) {
      return Container(
        padding: const EdgeInsets.all(18),
        child: Text(
          AppLocalizations.of(context)!.camoPinBioProtectionConflict,
          style: TextStyle(
            color: Theme.of(context).errorColor,
            height: 1.2,
          ),
        ),
      );
    }

    return StreamBuilder<bool>(
        initialData: camoBloc.isCamoEnabled,
        stream: camoBloc.outCamoEnabled,
        builder: (context, camoEnabled) {
          if (camoEnabled.data != true) return SizedBox();

          return FutureBuilder<String?>(
              future: EncryptionTool().read('pin'),
              builder: (context, AsyncSnapshot<String?> normalPin) {
                if (!normalPin.hasData) return SizedBox();

                if (walletSecuritySettingsProvider.activatePinProtection) {
                  return StreamBuilder<String?>(
                      initialData: camoBloc.camoPinValue,
                      stream: camoBloc.outCamoPinValue,
                      builder: (context, AsyncSnapshot<String?> camoPin) {
                        if (!camoPin.hasData) return SizedBox();
                        if (camoPin.data != normalPin.data) return SizedBox();

                        return Container(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            _matchingPinErrorMessage!,
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
                      AppLocalizations.of(context)!.generalPinNotActive,
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
    return FutureBuilder(
        future: camoBloc.getCamoPinValue(),
        builder: (context, snap) {
          return StreamBuilder<String?>(
              initialData: camoBloc.camoPinValue,
              stream: camoBloc.outCamoPinValue,
              builder: (context, AsyncSnapshot<String?> camoPinSnapshot) {
                final String? camoPin =
                    camoPinSnapshot.hasData ? camoPinSnapshot.data : null;

                return StreamBuilder<bool>(
                    initialData: camoBloc.isCamoEnabled,
                    stream: camoBloc.outCamoEnabled,
                    builder:
                        (context, AsyncSnapshot<bool> camoEnabledSnapshot) {
                      if (!camoEnabledSnapshot.hasData) return SizedBox();

                      final bool isEnabled = camoEnabledSnapshot.data!;
                      return Opacity(
                        opacity: isEnabled ? 1 : 0.5,
                        child: Card(
                          child: InkWell(
                            onTap:
                                isEnabled ? () => _startCamoPinSetup() : null,
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
                                                AppLocalizations.of(context)!
                                                    .camoPinNotFound,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: isEnabled
                                                      ? Theme.of(context)
                                                          .errorColor
                                                      : null,
                                                ),
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .camoPinCreate,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2!
                                                      .color!
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
                                              FutureBuilder<String?>(
                                                  future: EncryptionTool()
                                                      .read('pin'),
                                                  builder: (context,
                                                      AsyncSnapshot<String?>
                                                          normalPin) {
                                                    if (!normalPin.hasData)
                                                      return SizedBox();

                                                    if (normalPin.data !=
                                                        camoPinSnapshot.data)
                                                      return Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .camoPinSaved,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      );

                                                    return Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .camoPinInvalid,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: Theme.of(context)
                                                            .errorColor,
                                                      ),
                                                    );
                                                  }),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .camoPinChange,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2!
                                                      .color!
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
        });
  }

  void _startCamoPinSetup() {
    // TODO: Delete file when confirming removal of camo pin feature. If not,
    // implement this feature in bloc.

    // Navigator.push<dynamic>(
    //     context,
    //     MaterialPageRoute<dynamic>(
    //         builder: (BuildContext context) => UnlockWalletPage(
    //               textButton: AppLocalizations.of(context)!.unlock,
    //               wallet: walletBloc.currentWallet!,
    //               isSignWithSeedIsEnabled: false,
    //               onSuccess: (_, String password) {
    //                 // final successMessage = await Navigator.push<String?>(context, PinResetPage.route);
    //               },
    //             ))).then((value) => camoBloc.getCamoPinValue());
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 24,
      ),
      child: Text(AppLocalizations.of(context)!.camoPinDesc,
          style: TextStyle(
            height: 1.3,
            color:
                Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.6),
          )),
    );
  }

  Widget _buildSwitcher() {
    return StreamBuilder<bool>(
        initialData: camoBloc.isCamoEnabled,
        stream: camoBloc.outCamoEnabled,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) return SizedBox();

          final bool isEnabled = camoBloc.isCamoEnabled;
          return Card(
            child: SwitchListTile(
              title: Text(isEnabled
                  ? AppLocalizations.of(context)!.camoPinOn
                  : AppLocalizations.of(context)!.camoPinOff),
              value: isEnabled,
              onChanged: walletSecuritySettingsProvider.activateBioProtection
                  ? null
                  : (bool value) => _switchEnabled(value),
            ),
          );
        });
  }

  Future<void> _switchEnabled(bool shouldEnable) async {
    final bool isCamoPinSet =
        await context.read<PinResetBloc>().checkIfPinTypeSet(PinTypeName.camo);

    if (shouldEnable && !isCamoPinSet) {
      _startCamoPinSetup();
      return;
    }
  }

  // Future<void> _showMatchingPinPopupIfNeeded() async {
  //   if (!camoBloc.shouldWarnBadCamoPin) return;

  //   final String? normalPin = await EncryptionTool().read('pin');
  //   final String? camoPin = await EncryptionTool().read('camoPin');

  //   if (normalPin == null || camoPin == null) return;
  //   if (normalPin.isEmpty || camoPin.isEmpty) return;
  //   if (normalPin != camoPin) return;

  //   showConfirmationDialog(
  //       context: context,
  //       title: AppLocalizations.of(context)!.matchingCamoTitle,
  //       message: _matchingPinErrorMessage,
  //       iconColor: Theme.of(context).errorColor,
  //       confirmButtonText: AppLocalizations.of(context)!.matchingCamoChange,
  //       onConfirm: () {
  //         _startPinSetup();
  //       });

  //   setState(() {
  //     camoBloc.shouldWarnBadCamoPin = false;
  //   });
  // }
}
