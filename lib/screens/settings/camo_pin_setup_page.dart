import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/authentification/pin_page.dart';
import 'package:komodo_dex/screens/authentification/unlock_wallet_page.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';

class CamoPinSetupPage extends StatefulWidget {
  @override
  _CamoPinSetupPageState createState() => _CamoPinSetupPageState();
}

class _CamoPinSetupPageState extends State<CamoPinSetupPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        initialData: authBloc.isCamoActive,
        stream: authBloc.outIsCamoActive,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.data) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            });
            return Container();
          }

          return LockScreen(
            context: context,
            child: Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              appBar: AppBar(
                // TODO(yurii): localization
                title: const Text('Camouflage PIN'),
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
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildPinSetup() {
    return FutureBuilder<String>(
        future: EncryptionTool().read('camoPin'),
        builder: (context, AsyncSnapshot<String> camoPinSnapshot) {
          final String camoPin =
              camoPinSnapshot.hasData ? camoPinSnapshot.data : null;

          return StreamBuilder<bool>(
              initialData: settingsBloc.isCamoEnabled,
              stream: settingsBloc.outCamoEnabled,
              builder: (context, AsyncSnapshot<bool> camoEnabledSnapshot) {
                if (!camoEnabledSnapshot.hasData) return Container();

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
                                        const Text(
                                          'Camouflage PIN not found',
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          'Create Camouflage PIN',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).disabledColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text(
                                          'Camouflage PIN saved',
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          'Change Camouflage PIN',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).disabledColor,
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
                                title: 'Camouflage PIN Setup',
                                subTitle: 'Enter new Camouflage PIN',
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
      child: Text(
          'If You\'ll unlock the app with the Camouflage PIN, a fake'
          ' LOW balance will be shown'
          ' and the Camouflage PIN config option will'
          ' NOT be visible in the settings',
          style: TextStyle(
            height: 1.3,
            color: Theme.of(context).disabledColor,
          )),
    );
  }

  Widget _buildSwitcher() {
    return StreamBuilder<bool>(
        initialData: settingsBloc.isCamoEnabled,
        stream: settingsBloc.outCamoEnabled,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) return Container();

          final bool isEnabled = snapshot.data;
          return Card(
            child: InkWell(
              onTap: () {
                _switchEnabled(!isEnabled);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 8,
                  bottom: 8,
                  right: 8,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        isEnabled ? 'On' : 'Off',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Switch(
                      value: isEnabled,
                      onChanged: (bool value) {
                        _switchEnabled(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _switchEnabled(bool val) async {
    settingsBloc.setCamoEnabled(val);

    final String savedPin = await EncryptionTool().read('camoPin');
    if (val && savedPin == null) _startPinSetup();
  }
}
