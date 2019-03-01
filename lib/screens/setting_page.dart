import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
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
        title: Text("Settings"),
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
                  'Security',
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
                      'Activate PIN access',
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
                                  authBloc.showPin(true);
                                }
                                SharedPreferences.getInstance().then((data) {
                                  data.setBool("switch_pin", dataSwitch);
                                });
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
                  'Change PIN',
                  style: Theme.of(context).textTheme.body1,
                ),
                onTap: () {
//                  Navigator.push(
//                    context,
//                    MaterialPageRoute(
//                        builder: (context) => PinPage()),
//                  );
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
                    'Logout',
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
