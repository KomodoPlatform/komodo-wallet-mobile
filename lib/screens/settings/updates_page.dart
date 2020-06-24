import 'dart:io';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/updates_provider.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class UpdatesPage extends StatefulWidget {
  @override
  _UpdatesPageState createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  UpdatesProvider updatesProvider;

  @override
  Widget build(BuildContext context) {
    updatesProvider = Provider.of<UpdatesProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Center(
            child: Text('atomicDEX update')), // TODO(yurii): localization
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 3,
              child: Center(
                child: updatesProvider.isFetching
                    ? Text('checking...')
                    : updatesProvider.newVersionAvailable
                        ? Text('new version available')
                        : Text('already up to date'),
              ),
            ),
            Divider(
              color: Theme.of(context).disabledColor,
            ),
            Container(
              height: MediaQuery.of(context).size.height / 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    color: Theme.of(context).dialogBackgroundColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Theme.of(context).textTheme.caption.color),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: () {
                      Platform.isIOS
                          ? launchURL(
                              'https://testflight.apple.com/join/c2mOLEoC')
                          : launchURL(
                              'https://play.google.com/apps/testing/com.komodoplatform.atomicdex');
                    },
                    child: Text('Update'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
