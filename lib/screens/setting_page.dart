import 'dart:io';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/lock_screen.dart';
import 'package:komodo_dex/screens/pin_page.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/shared_preferences_builder.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
            canvasColor: Theme.of(context).primaryColor,
            primaryColor: Theme.of(context).accentColor,
            textTheme: Theme.of(context).textTheme),
        child: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context).security,
                  style: Theme.of(context).textTheme.body2,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.dialpad,
                  color: Theme.of(context).hintColor,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).activateAccessPin,
                      style: Theme.of(context).textTheme.body1,
                    ),
                    SharedPreferencesBuilder(
                      pref: 'switch_pin',
                      builder: (context, snapshot) {
                        print("switch_pin pref " + snapshot.data.toString());
                        return snapshot.hasData
                            ? Switch(
                                value: snapshot.data,
                                onChanged: (dataSwitch) {
                                  print("dataSwitch" + dataSwitch.toString());
                                  setState(() {
                                    if (snapshot.data) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => LockScreen(
                                                    pinStatus:
                                                        PinStatus.DISABLED_PIN,
                                                  )));
                                    } else {
                                      SharedPreferences.getInstance()
                                          .then((data) {
                                        data.setBool("switch_pin", dataSwitch);
                                      });
                                    }
                                  });
                                })
                            : Container();
                      },
                    )
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.refresh,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  AppLocalizations.of(context).changePin,
                  style: Theme.of(context).textTheme.body1,
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PinPage(
                                title: AppLocalizations.of(context).lockScreen,
                                subTitle:
                                    AppLocalizations.of(context).enterPinCode,
                                isConfirmPin: PinStatus.CHANGE_PIN,
                              )));
                },
              ),
              ListTile(
                leading: Icon(Icons.feedback, color: Colors.white),
                title: Text(
                  AppLocalizations.of(context).feedback,
                  style: Theme.of(context).textTheme.body1,
                ),
                onTap: () {
                  _shareFile();
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  title: Text(
                    AppLocalizations.of(context).logout,
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(color: Colors.red.withOpacity(0.7)),
                  ),
                  onTap: () {
                    authBloc.logout();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _shareFile() {
    File file = new File('${mm2.filesPath}log.txt');
    Share.shareFile(file,
        subject: "My logs for the ${DateTime.now().toIso8601String()}");
  }
}
