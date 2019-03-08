import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/pin_page.dart';
import 'package:komodo_dex/widgets/shared_preferences_builder.dart';
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
        title: Text(AppLocalizations
            .of(context)
            .settings),
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
                  AppLocalizations
                      .of(context)
                      .security,
                  style: Theme
                      .of(context)
                      .textTheme
                      .body2,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.dialpad,
                  color: Theme
                      .of(context)
                      .hintColor,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      AppLocalizations
                          .of(context)
                          .activateAccessPin,
                      style: Theme
                          .of(context)
                          .textTheme
                          .body1,
                    ),
                    SharedPreferencesBuilder(
                      pref: 'switch_pin',
                      builder: (context, snapshot) {
                        return snapshot.hasData ? Switch(
                            value: snapshot.data,
                            onChanged: (dataSwitch) {
                              setState(() {
                                if (snapshot.data) {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) =>
                                          PinPage(
                                            title: AppLocalizations
                                                .of(context)
                                                .lockScreen,
                                            subTitle: AppLocalizations
                                                .of(context)
                                                .enterPinCode,
                                            isConfirmPin: PinStatus
                                                .DISABLED_PIN,)));
                                } else {
                                  SharedPreferences.getInstance().then((data) {
                                    data.setBool("switch_pin", dataSwitch);
                                  });
                                }
                              });
                            }) : Container();
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
                  AppLocalizations
                      .of(context)
                      .changePin,
                  style: Theme.of(context).textTheme.body1,
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>
                          PinPage(
                            title: AppLocalizations
                                .of(context)
                                .lockScreen,
                            subTitle: AppLocalizations
                                .of(context)
                                .enterPinCode,
                            isConfirmPin: PinStatus.CHANGE_PIN,)));
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
                    AppLocalizations
                        .of(context)
                        .logout,
                    style: Theme
                        .of(context)
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
}
