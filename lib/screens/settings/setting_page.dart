import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/authentification/pin_page.dart';
import 'package:komodo_dex/screens/authentification/unlock_wallet_page.dart';
import 'package:komodo_dex/screens/settings/view_seed_unlock_page.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';
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
        title: Text(
          AppLocalizations.of(context).settings.toUpperCase(),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
            canvasColor: Theme.of(context).primaryColor,
            textTheme: Theme.of(context).textTheme),
        child: Container(
          child: ListView(
            children: <Widget>[
              _buildTitle(AppLocalizations.of(context).logoutsettings),
              _buildLogout(),
              SizedBox(
                height: 1,
              ),
              _buildLogOutOnExit(),
              _buildTitle(AppLocalizations.of(context).security),
              _buildActivatePIN(),
              SizedBox(
                height: 1,
              ),
              _buildActivateBiometric(),
              SizedBox(
                height: 1,
              ),
              _buildChangePIN(),
              SizedBox(
                height: 1,
              ),
              _buildSendFeedback(),
              walletBloc.currentWallet != null
                  ? _buildTitle(AppLocalizations.of(context).backupTitle)
                  : Container(),
              walletBloc.currentWallet != null ? _buildViewSeed() : Container(),
                            SizedBox(
                height: 1,
              ),
              _buildSendFeedback(),
              walletBloc.currentWallet != null
                  ? _buildTitle(AppLocalizations.of(context).version + "-0.1.1")
                  : Container(),
              SizedBox(
                height: 48,
              ),
              walletBloc.currentWallet != null
                  ? _buildDeleteWallet()
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.body2,
      ),
    );
  }

  _buildActivatePIN() {
    return CustomTile(
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                AppLocalizations.of(context).activateAccessPin,
                style: Theme.of(context).textTheme.body1.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.7)),
              ),
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
                                            pinStatus: PinStatus.DISABLED_PIN,
                                          )));
                            } else {
                              SharedPreferences.getInstance().then((data) {
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
    );
  }

  _buildActivateBiometric() {
    return CustomTile(
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                AppLocalizations.of(context).activateAccessBiometric,
                style: Theme.of(context).textTheme.body1.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.7)),
              ),
            ),
            SharedPreferencesBuilder(
              pref: 'switch_pin_biometric',
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Switch(
                        value: snapshot.data,
                        onChanged: (dataSwitch) {
                          setState(() {
                            if (snapshot.data) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LockScreen(
                                            pinStatus: PinStatus
                                                .DISABLED_PIN_BIOMETRIC,
                                          )));
                            } else {
                              SharedPreferences.getInstance().then((data) {
                                data.setBool(
                                    "switch_pin_biometric", dataSwitch);
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
    );
  }

  _buildChangePIN() {
    return CustomTile(
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UnlockWalletPage(
                    textButton: AppLocalizations.of(context).unlock,
                    wallet: walletBloc.currentWallet,
                    isSignWithSeedIsEnabled: false,
                    onSuccess: (_, password) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PinPage(
                                  title:
                                      AppLocalizations.of(context).lockScreen,
                                  subTitle:
                                      AppLocalizations.of(context).enterPinCode,
                                  isConfirmPin: PinStatus.CHANGE_PIN,
                                  password: password)));
                    },
                  ))),
      child: ListTile(
        trailing:
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.7)),
        title: Text(
          AppLocalizations.of(context).changePin,
          style: Theme.of(context).textTheme.body1.copyWith(
              fontWeight: FontWeight.w300,
              color: Colors.white.withOpacity(0.7)),
        ),
      ),
    );
  }

  _buildSendFeedback() {
    return CustomTile(
      onPressed: () => _shareFile(),
      child: ListTile(
        trailing:
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.7)),
        title: Text(
          AppLocalizations.of(context).feedback,
          style: Theme.of(context).textTheme.body1.copyWith(
              fontWeight: FontWeight.w300,
              color: Colors.white.withOpacity(0.7)),
        ),
      ),
    );
  }

  _buildViewSeed() {
    return CustomTile(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ViewSeedUnlockPage()));
      },
      child: ListTile(
        trailing:
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.7)),
        title: Text(
          AppLocalizations.of(context).viewSeed,
          style: Theme.of(context).textTheme.body1.copyWith(
              fontWeight: FontWeight.w300,
              color: Colors.white.withOpacity(0.7)),
        ),
      ),
    );
  }

  _buildLogout() {
    return CustomTile(
      onPressed: () {
        print("PRESSED");
        authBloc.logout().then((onValue) {
          print("PRESSED");
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });
      },
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: SvgPicture.asset("assets/logout_setting.svg"),
        ),
        title: Text(AppLocalizations.of(context).logout,
            style: Theme.of(context).textTheme.body1.copyWith(
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.7))),
      ),
    );
  }

  _buildLogOutOnExit() {
    return CustomTile(
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                AppLocalizations.of(context).logoutOnExit,
                style: Theme.of(context).textTheme.body1.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.7)),
              ),
            ),
            SharedPreferencesBuilder(
              pref: 'switch_pin_log_out_on_exit',
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Switch(
                        value: snapshot.data,
                        onChanged: (dataSwitch) {
                          setState(() {
                            SharedPreferences.getInstance().then((data) {
                              data.setBool(
                                  "switch_pin_log_out_on_exit", dataSwitch);
                            });
                          });
                        })
                    : Container();
              },
            )
          ],
        ),
      ),
    );
  }

  _buildDeleteWallet() {
    return CustomTile(
      onPressed: () => _showDialogDeleteWallet(),
      backgroundColor: Theme.of(context).errorColor.withOpacity(0.8),
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: SvgPicture.asset("assets/delete_setting.svg"),
        ),
        title: Text(AppLocalizations.of(context).deleteWallet,
            style: Theme.of(context).textTheme.body1.copyWith(
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.7))),
      ),
    );
  }

  _showDialogDeleteWallet() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UnlockWalletPage(
                textButton: AppLocalizations.of(context).unlock,
                wallet: walletBloc.currentWallet,
                isSignWithSeedIsEnabled: false,
                onSuccess: (_, password) {
                  Navigator.of(context).pop();
                  dialogBloc.dialog = showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(8.0)),
                          backgroundColor: Colors.white,
                          title: Column(
                            children: <Widget>[
                              SvgPicture.asset("assets/delete_wallet.svg"),
                              SizedBox(
                                height: 16,
                              ),
                              Text(
                                AppLocalizations.of(context)
                                    .deleteWallet
                                    .toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .title
                                    .copyWith(
                                        color: Theme.of(context).errorColor),
                              ),
                              SizedBox(
                                height: 24,
                              ),
                            ],
                          ),
                          children: <Widget>[
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                TextSpan(
                                    text: AppLocalizations.of(context)
                                        .settingDialogSpan1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                TextSpan(
                                    text: walletBloc.currentWallet.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: AppLocalizations.of(context)
                                        .settingDialogSpan2,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColor)),
                              ]),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: AppLocalizations.of(context)
                                          .settingDialogSpan3,
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                  TextSpan(
                                      text: AppLocalizations.of(context)
                                          .settingDialogSpan4,
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text: AppLocalizations.of(context)
                                          .settingDialogSpan5,
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                ]),
                              ),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: SecondaryButton(
                                    text: AppLocalizations.of(context).cancel,
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    isDarkMode: false,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: PrimaryButton(
                                    text: AppLocalizations.of(context).delete,
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      settingsBloc.setDeleteLoading(true);
                                      _showLoadingDelete();
                                      await walletBloc.deleteSeedPhrase(
                                          password, walletBloc.currentWallet);
                                      settingsBloc.setDeleteLoading(false);

                                      walletBloc.deleteCurrentWallet();
                                    },
                                    backgroundColor:
                                        Theme.of(context).errorColor,
                                    isDarkMode: false,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 24,
                            ),
                          ],
                        );
                      }).then((_) {
                    dialogBloc.dialog = null;
                  });
                },
              )),
    );
  }

  _showLoadingDelete() {
    dialogBloc.dialog = showDialog(
        context: context,
        builder: (context) {
          return StreamBuilder<Object>(
            initialData: settingsBloc.isDeleteLoading,
            stream: settingsBloc.outIsDeleteLoading,
            builder: (context, snapshot) {
              if (snapshot.hasData && !snapshot.data) {
                Navigator.of(context).pop();
              }
              return SimpleDialog(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: <Widget>[
                  Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(
                        width: 16,
                      ),
                      Text("Deleting wallet...")
                    ],
                  ))
                ],
              );
            }
          );
        }).then((_) {
      dialogBloc.dialog = null;
    });
  }

  void _shareFile() {
    File file = new File('${mm2.filesPath}log.txt');
    Share.shareFile(file,
        subject: "My logs for the ${DateTime.now().toIso8601String()}");
  }
}

class CustomTile extends StatefulWidget {
  final Widget child;
  final Function onPressed;
  final Color backgroundColor;

  CustomTile({this.child, this.onPressed, this.backgroundColor});

  @override
  _CustomTileState createState() => _CustomTileState();
}

class _CustomTileState extends State<CustomTile> {
  Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (widget.backgroundColor == null) {
      backgroundColor = Theme.of(context).primaryColor;
    } else {
      backgroundColor = widget.backgroundColor;
    }
    return Container(
      color: backgroundColor,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          child: widget.child,
        ),
      ),
    );
  }
}
