import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/screens/pin_page.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
              ListTile(
                leading: Icon(
                  Icons.security,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  'Change PIN',
                  style: Theme.of(context).textTheme.body1,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PinPage()),
                  );
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
                    style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.red.withOpacity(0.7)
                    ),
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
