import 'dart:io';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/updates_provider.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({this.refresh = false, this.onSkip});

  final bool refresh;
  final Function onSkip;

  @override
  _UpdatesPageState createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  UpdatesProvider updatesProvider;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.refresh) updatesProvider.check();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    updatesProvider = Provider.of<UpdatesProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Text('AtomicDeFi update'), // TODO(yurii): localization
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          updatesProvider.check();
        },
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 3,
              child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('assets/logo_kmd.png'),
                      const SizedBox(height: 12),
                      Text(
                          'You are using version ${updatesProvider.currentVersion}'), // TODO(yurii): localization
                      const SizedBox(height: 4),
                      updatesProvider.isFetching
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                                SizedBox(width: 6),
                                Text(
                                    'Checking for updates...') // TODO(yurii): localization
                              ],
                            )
                          : updatesProvider.status == UpdateStatus.upToDate
                              ? const Text(
                                  'Already up to date') // TODO(yurii): localization
                              : Text(
                                  'New version available${updatesProvider.newVersion == null ? '' : ': ${updatesProvider.newVersion}'}', // TODO(yurii): localization
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                    ],
                  )),
            ),
            if (updatesProvider.message != null)
              Container(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Divider(
                      color: Theme.of(context).hintColor,
                      height: 60,
                    ),
                    Text(updatesProvider.message),
                  ],
                ),
              ),
            if (updatesProvider.status != UpdateStatus.upToDate &&
                !updatesProvider.isFetching)
              Container(
                height: MediaQuery.of(context).size.height / 5,
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
                                'https://play.google.com/store/apps/details?id=com.komodoplatform.atomicdex');
                      },
                      child: const Text('Update'), // TODO(yurii): localization
                    ),
                    if (updatesProvider.status == UpdateStatus.available ||
                        updatesProvider.status == UpdateStatus.recommended) ...[
                      const SizedBox(width: 12),
                      RaisedButton(
                        color: Theme.of(context).dialogBackgroundColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: Theme.of(context).textTheme.caption.color),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        onPressed: () {
                          if (widget.onSkip != null) widget.onSkip();
                        },
                        child: const Text(
                            'Skip for now'), // TODO(yurii): localization
                      )
                    ]
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
