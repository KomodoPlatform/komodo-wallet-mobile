import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/packages/z_coin_activation/widgets/z_coin_status_list_tile.dart';
import 'package:komodo_dex/utils/log_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_config/app_config.dart';
import '../../blocs/authenticate_bloc.dart';
import '../../blocs/camo_bloc.dart';
import '../../blocs/dialog_bloc.dart';
import '../../blocs/main_bloc.dart';
import '../../blocs/settings_bloc.dart';
import '../../blocs/wallet_bloc.dart';
import '../../localizations.dart';
import '../../model/cex_provider.dart';
import '../../model/swap.dart';
import '../../model/swap_provider.dart';
import '../../model/updates_provider.dart';
import '../../model/wallet_security_settings_provider.dart';
import '../../services/mm_service.dart';
import '../../utils/log.dart';
import '../../utils/utils.dart';
import '../../widgets/build_red_dot.dart';
import '../../widgets/custom_simple_dialog.dart';
import '../../widgets/eula_contents.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/scrollable_dialog.dart';
import '../../widgets/tac_contents.dart';
import '../authentification/lock_screen.dart';
import '../authentification/pin_page.dart';
import '../authentification/show_delete_wallet_confirmation.dart';
import '../authentification/unlock_wallet_page.dart';
import '../import-export/export_page.dart';
import '../import-export/import_page.dart';
import '../import-export/import_swap_page.dart';
import '../settings/camo_pin_setup_page.dart';
import '../settings/updates_page.dart';
import '../settings/view_seed_unlock_page.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String version = '';
  CexProvider cexProvider;
  WalletSecuritySettingsProvider walletSecuritySettingsProvider;

  @override
  void initState() {
    _getVersionApplication().then((String onValue) {
      setState(() {
        version = onValue;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    mainBloc.isUrlLaucherIsOpen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cexProvider = Provider.of<CexProvider>(context);
    walletSecuritySettingsProvider =
        context.watch<WalletSecuritySettingsProvider>();
    return LockScreen(
      context: context,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).settings.toUpperCase(),
            key: const Key('settings-title'),
          ),
          elevation: Theme.of(context).brightness == Brightness.light ? 3 : 0,
        ),
        body: ListView(
          key: const Key('settings-scrollable'),
          children: <Widget>[
            _buildTitle(AppLocalizations.of(context).logoutsettings),
            _buildLogOutOnExit(),
            _buildTitle(AppLocalizations.of(context).security),
            _buildActivatePIN(),
            const SizedBox(height: 1),
            _buildActivateBiometric(),
            const SizedBox(height: 1),
            _buildActivateScreenshot(),
            const SizedBox(height: 1),
            _buildCamouflagePin(),
            const SizedBox(height: 1),
            _buildChangePIN(),
            const SizedBox(height: 1),
            _buildSendFeedback(),
            if (walletBloc.currentWallet != null) ...[
              _buildTitle(AppLocalizations.of(context).backupTitle),
              _buildViewSeed(),
              const SizedBox(height: 1),
            ],
            _buildExport(),
            const SizedBox(height: 1),
            _buildImport(),
            const SizedBox(height: 1),
            _buildImportSwap(),
            const SizedBox(
              height: 1,
            ),
            _buildTitle(AppLocalizations.of(context).oldLogsTitle),
            BuildOldLogs(),
            _buildTitle(AppLocalizations.of(context).legalTitle),
            _buildDisclaimerToS(),
            _buildTitle(AppLocalizations.of(context).developerTitle),
            _buildEnableTestCoins(),
            SizedBox(height: 2),
            _buildTitle(version),
            if (appConfig.isUpdateCheckerEnabled) _buildUpdate(),
            const SizedBox(
              height: 48,
            ),
            if (walletBloc.currentWallet != null) _buildDeleteWallet(),
          ],
        ),
      ),
    );
  }

  Future<String> _getVersionApplication() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final versionString = '${AppLocalizations.of(context).version}'
        ' : ${packageInfo.version ?? 'Undefined package version'}'
        ' (${packageInfo.buildNumber ?? 'Undefined build number'})'
        ' - ${mmSe.mmVersion ?? 'Undefined API version'}';

    return versionString;
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  Widget _buildActivatePIN() {
    return SwitchListTile(
      title: Text(AppLocalizations.of(
        context,
      ).activateAccessPin),
      tileColor: Theme.of(context).primaryColor,
      value: walletSecuritySettingsProvider.activatePinProtection ?? false,
      onChanged: (
        bool switchValue,
      ) {
        Log(
          'setting_page:262',
          'switchValue $switchValue',
        );
        if (walletSecuritySettingsProvider.activatePinProtection) {
          // We want to deactivate biometrics here
          // together with a regular pin protection,
          // so that user would not leave himself
          // only with biometrics one - thinking that
          // he is "protected", truth be told
          // without any fallback to regular pin
          // protection, this biometrics widget is
          // not very reliable (read very not)
          // and it does not take too much time to
          // break it, and get access to users funds.
          walletSecuritySettingsProvider.activateBioProtection = false;
          walletSecuritySettingsProvider.activatePinProtection = false;
        } else {
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (
                BuildContext context,
              ) =>
                  LockScreen(
                context: context,
                pinStatus: PinStatus.DISABLED_PIN,
              ),
            ),
          ).then((dynamic _) => setState(() {}));
        }
      },
    );
  }

  Widget _buildActivateBiometric() {
    return FutureBuilder<bool>(
      initialData: false,
      future: canCheckBiometrics,
      builder: (
        BuildContext context,
        AsyncSnapshot<bool> snapshot,
      ) {
        if (snapshot.hasData && snapshot.data) {
          return SwitchListTile(
            title: Text(AppLocalizations.of(
              context,
            ).activateAccessBiometric),
            tileColor: Theme.of(context).primaryColor,
            value:
                walletSecuritySettingsProvider.activateBioProtection ?? false,
            onChanged: camoBloc.isCamoActive
                ? null
                : (
                    bool switchValue,
                  ) {
                    if (camoBloc.isCamoEnabled) {
                      _showCamoPinBioProtectionConflictDialog();
                      return;
                    }
                    if (walletSecuritySettingsProvider.activateBioProtection) {
                      walletSecuritySettingsProvider.activateBioProtection =
                          false;
                    } else {
                      authenticateBiometrics(
                        context,
                        PinStatus.DISABLED_PIN_BIOMETRIC,
                        authorize: true,
                      ).then((
                        bool passedBioCheck,
                      ) {
                        if (passedBioCheck) {
                          walletSecuritySettingsProvider.activateBioProtection =
                              true;
                          walletSecuritySettingsProvider.activatePinProtection =
                              true;
                          //
                        }
                      });
                    }
                  },
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildActivateScreenshot() {
    return SwitchListTile(
      title: Text(AppLocalizations.of(
        context,
      ).disableScreenshots),
      tileColor: Theme.of(context).primaryColor,
      value: walletSecuritySettingsProvider.disallowScreenshot,
      onChanged: (bool switchValue) async {
        if (!switchValue) {
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => UnlockWalletPage(
                  textButton: AppLocalizations.of(context).unlock,
                  wallet: walletBloc.currentWallet,
                  isSignWithSeedIsEnabled: false,
                  onSuccess: (_, __) {
                    Navigator.pop(context);
                    switchScreenshot(switchValue);
                  }),
            ),
          );
          return;
        }
        switchScreenshot(switchValue);
      },
    );
  }

  Future<void> switchScreenshot(bool switchValue) async {
    Log('setting_page:269', 'disallowScreenshot $switchValue');
    walletSecuritySettingsProvider.disallowScreenshot = switchValue;
    // delay for a while for data to properly sync before trying to
    // call it on the native side (affects majorly android)
    await Future.delayed(Duration(microseconds: 500));
    MMService.nativeC.invokeMethod('is_screenshot');
  }

  void _showCamoPinBioProtectionConflictDialog() {
    dialogBloc.dialog = showDialog<dynamic>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomSimpleDialog(
            title: Text(
                AppLocalizations.of(context).camoPinBioProtectionConflictTitle),
            children: <Widget>[
              Text(AppLocalizations.of(context).camoPinBioProtectionConflict),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context).warningOkBtn),
                  ),
                ],
              ),
            ],
          );
        }).then((dynamic _) {
      dialogBloc.dialog = null;
    });
  }

  Widget _buildCamouflagePin() {
    return StreamBuilder<bool>(
        initialData: camoBloc.isCamoActive,
        stream: camoBloc.outIsCamoActive,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == true) return SizedBox();

          return _chevronListTileHelper(
            title: Text(AppLocalizations.of(context).camoPinLink),
            onTap: () {
              Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                      settings: const RouteSettings(name: '/camoSetup'),
                      builder: (BuildContext context) => CamoPinSetupPage()));
            },
          );
        });
  }

  Widget _buildChangePIN() {
    return _chevronListTileHelper(
      title: Text(AppLocalizations.of(context).changePin),
      onTap: () => Navigator.push<dynamic>(
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
                                  title: AppLocalizations.of(context).createPin,
                                  subTitle: AppLocalizations.of(context)
                                      .enterNewPinCode,
                                  pinStatus: PinStatus.CHANGE_PIN,
                                  password: password)));
                    },
                  ))),
    );
  }

  Widget _buildSendFeedback() {
    return _chevronListTileHelper(
      title: Text(AppLocalizations.of(context).feedback),
      onTap: () => _shareFileDialog(),
    );
  }

  Widget _buildViewSeed() {
    return _chevronListTileHelper(
      title: Text(AppLocalizations.of(context).viewSeedAndKeys),
      onTap: () {
        Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => ViewSeedUnlockPage()));
      },
    );
  }

  Widget _buildExport() {
    return _chevronListTileHelper(
      title: Text(AppLocalizations.of(context).exportLink),
      onTap: () {
        Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => ExportPage()));
      },
    );
  }

  Widget _buildImport() {
    return _chevronListTileHelper(
      title: Text(AppLocalizations.of(context).importLink),
      onTap: () {
        Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => ImportPage()));
      },
    );
  }

  Widget _buildImportSwap() {
    return _chevronListTileHelper(
      title: Text(AppLocalizations.of(context).importSingleSwapLink),
      onTap: () {
        Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => ImportSwapPage()));
      },
    );
  }

  Widget _buildDisclaimerToS() {
    return _chevronListTileHelper(
        title: Text(AppLocalizations.of(context).disclaimerAndTos),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ScrollableDialog(
                mustScrollToBottom: false,
                verticalButtons: PrimaryButton(
                  key: const Key('settings-tos-close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  text: AppLocalizations.of(context).close,
                ),
                children: [
                  Text(
                      AppLocalizations.of(context)
                          .eulaTitle1(appConfig.appName),
                      style: Theme.of(context).textTheme.headline6),
                  EULAContents(),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context).eulaTitle2,
                      style: Theme.of(context).textTheme.headline6),
                  TACContents(),
                ]),
          );
        });
  }

  Widget _buildUpdate() {
    final UpdatesProvider updatesProvider =
        Provider.of<UpdatesProvider>(context);

    return _chevronListTileHelper(
      title: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Text(AppLocalizations.of(context).checkForUpdates),
          if (updatesProvider.status != UpdateStatus.upToDate)
            buildRedDot(context, right: -12),
        ],
      ),
      onTap: () {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => UpdatesPage(
                    refresh: true,
                    onSkip: () => Navigator.pop(context),
                  )),
        );
      },
    );
  }

  Widget _buildLogOutOnExit() {
    return SwitchListTile(
      value: walletSecuritySettingsProvider.logOutOnExit ?? false,
      onChanged: (bool dataSwitch) {
        setState(() {
          walletSecuritySettingsProvider.logOutOnExit =
              !walletSecuritySettingsProvider.logOutOnExit;
        });
      },
      title: Text(AppLocalizations.of(context).logoutOnExit),
      tileColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildDeleteWallet() {
    return ListTile(
      tileColor: Theme.of(context).errorColor,
      leading: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SvgPicture.asset(
          'assets/svg/delete_setting.svg',
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      title: Text(
        AppLocalizations.of(context).deleteWallet,
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(color: Theme.of(context).colorScheme.onError),
      ),
      onTap: () => _showDialogDeleteWallet(),
    );
  }

  ListTile _chevronListTileHelper({
    @required Widget title,
    GestureTapCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      trailing: Icon(Icons.chevron_right),
      title: title,
      tileColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildEnableTestCoins() {
    return StreamBuilder(
      key: const Key('show-test-coins'),
      initialData: settingsBloc.enableTestCoins,
      stream: settingsBloc.outEnableTestCoins,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return SwitchListTile(
          title: Text(AppLocalizations.of(context).enableTestCoins),
          value: snapshot.data ?? false,
          onChanged: (bool dataSwitch) {
            settingsBloc.setEnableTestCoins(dataSwitch);
          },
          tileColor: Theme.of(context).primaryColor,
        );
      },
    );
  }

  void _showDialogDeleteWallet() {
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => UnlockWalletPage(
                textButton: AppLocalizations.of(context).unlock,
                wallet: walletBloc.currentWallet,
                isSignWithSeedIsEnabled: false,
                onSuccess: (_, String password) {
                  Navigator.of(context).pop();
                  showDeleteWalletConfirmation(
                    context,
                    password: password,
                  );
                },
              )),
    );
  }

  Future<void> _shareLogs() async {
    Navigator.of(context).pop();

    Log.downloadLogs().catchError((dynamic e) {
      _showSnackbar(e.toString());
    });
  }

  void _showSnackbar(String message) {
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _shareFileDialog() async {
    dialogBloc.dialog = showDialog<dynamic>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomSimpleDialog(
            title: Text(AppLocalizations.of(context).feedback),
            children: <Widget>[
              Text(AppLocalizations.of(context).warningShareLogs),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context).cancel),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    key: const Key('setting-share-button'),
                    onPressed: _shareLogs,
                    child: Text(
                      AppLocalizations.of(context).share,
                      style: Theme.of(context)
                          .textTheme
                          .button
                          .copyWith(color: Colors.white),
                    ),
                  )
                ],
              ),
            ],
          );
        }).then((dynamic _) {
      dialogBloc.dialog = null;
    });
  }
}

class ShowLoadingDelete extends StatefulWidget {
  @override
  _ShowLoadingDeleteState createState() => _ShowLoadingDeleteState();
}

class _ShowLoadingDeleteState extends State<ShowLoadingDelete> {
  @override
  Widget build(BuildContext context) {
    return CustomSimpleDialog(
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
            Text(AppLocalizations.of(context).deletingWallet)
          ],
        ))
      ],
    );
  }
}

class BuildOldLogs extends StatefulWidget {
  @override
  _BuildOldLogsState createState() => _BuildOldLogsState();
}

class _BuildOldLogsState extends State<BuildOldLogs> {
  List<dynamic> _listLogs = <dynamic>[];
  double _sizeMb = 0;

  @override
  void initState() {
    _update();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: ElevatedButton(
        onPressed: () {
          for (File f in _listLogs) {
            f.deleteSync();
          }
          _update();
        },
        child: Text(AppLocalizations.of(context).oldLogsDelete),
      ),
      title: Text(AppLocalizations.of(context).oldLogsUsed +
          ': ' +
          (_sizeMb >= 1000
              ? '${(_sizeMb / 1000).toStringAsFixed(2)} GB'
              : ' ${_sizeMb.toStringAsFixed(2)} MB')),
      tileColor: Theme.of(context).primaryColor,
    );
  }

  void _update() {
    _updateOldLogsList();
    _updateLogsSize();
  }

  void _updateOldLogsList() {
    final dirList = applicationDocumentsDirectorySync.listSync();
    setState(() {
      _listLogs = dirList
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList();
    });
  }

  Future<void> _updateLogsSize() async {
    final dirPath = applicationDocumentsDirectorySync.path;
    setState(() {
      _sizeMb = MMService.dirStatSync(dirPath);
    });
  }
}
