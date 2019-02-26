import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';

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
                  Icons.exit_to_app,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  'Logout',
                  style: Theme.of(context).textTheme.body1,
                ),
                onTap: () {
                  authBloc.logout();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
