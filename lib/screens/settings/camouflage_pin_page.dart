import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';

class CamouflagePinPage extends StatefulWidget {
  @override
  _CamouflagePinPageState createState() => _CamouflagePinPageState();
}

class _CamouflagePinPageState extends State<CamouflagePinPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
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
                      onTap: isEnabled ? () {} : null,
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
                settingsBloc.setCamoEnabled(!isEnabled);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 12,
                  bottom: 12,
                  right: 12,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        isEnabled ? 'On' : 'Off',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Switch(
                      value: isEnabled,
                      onChanged: (bool value) {
                        settingsBloc.setCamoEnabled(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
