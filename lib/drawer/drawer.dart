import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/screens/addressbook/addressbook_page.dart';
import 'package:komodo_dex/screens/authentification/logout_confirmation.dart';
import 'package:komodo_dex/screens/help-feedback/help_page.dart';
import 'package:komodo_dex/screens/settings/currencies_dialog.dart';
import 'package:komodo_dex/screens/settings/select_language_page.dart';
import 'package:komodo_dex/screens/settings/setting_page.dart';
import 'package:komodo_dex/screens/settings/sound_settings_page.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/music_service.dart';
import 'package:komodo_dex/widgets/shared_preferences_builder.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer(this.mContext, {Key key}) : super(key: key);

  final BuildContext mContext;

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  CexProvider cexProvider;

  @override
  Widget build(BuildContext context) {
    cexProvider = Provider.of<CexProvider>(context);
    double drawerWidth = MediaQuery.of(context).size.width * 0.7;
    if (drawerWidth < 200) drawerWidth = 200;
    final double headerHeight = MediaQuery.of(context).size.height * 0.25;

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: headerHeight,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  end: Alignment.centerLeft,
                  begin: Alignment.centerRight,
                  stops: <double>[0.01, 1],
                  colors: <Color>[
                    Color.fromRGBO(98, 90, 229, 1),
                    Color.fromRGBO(45, 184, 240, 1),
                  ],
                )),
                child: SafeArea(
                  bottom: false,
                  child: Flex(
                    direction: Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SvgPicture.asset(
                            'assets/branding/svg/mark_and_text_vertical_white.svg',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Divider(
                          color: Colors.white,
                          indent: drawerWidth * 0.1,
                          endIndent: drawerWidth * 0.1,
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SvgPicture.asset(
                                'assets/svg/wallet.svg',
                                height: 18,
                              ),
                              const SizedBox(width: 4),
                              FutureBuilder<Wallet>(
                                  future: Db.getCurrentWallet(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<Wallet> snapshot) {
                                    if (!snapshot.hasData) return Container();
                                    return Text(
                                      snapshot.data.name,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  })
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildDrawerItem(
                            title: Row(
                              children: <Widget>[
                                Text(AppLocalizations.of(context)
                                    .soundSettingsLink),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.push<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          SoundSettingsPage()));
                            },
                            leading: const Icon(Icons.audiotrack, size: 16),
                            trailing: InkWell(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  musicService.on()
                                      ? Icons.volume_up
                                      : Icons.volume_down,
                                  size: 22,
                                  color: musicService.on()
                                      ? Theme.of(context)
                                          .toggleButtonsTheme
                                          .color
                                      : Theme.of(context)
                                          .toggleButtonsTheme
                                          .disabledColor,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  musicService.flip();
                                });
                              },
                            )),
                        _buildDrawerItem(
                            title: SharedPreferencesBuilder<dynamic>(
                                pref: 'current_languages',
                                builder: (BuildContext context,
                                    AsyncSnapshot<dynamic> snapshot) {
                                  return Row(
                                    children: <Widget>[
                                      Text(AppLocalizations.of(context)
                                          .language),
                                      Text(
                                        snapshot.hasData
                                            ? ' (${snapshot.data})'
                                                .toUpperCase()
                                            : '',
                                      ),
                                    ],
                                  );
                                }),
                            onTap: () {
                              Navigator.push<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          SelectLanguagePage(
                                            currentLoc:
                                                Localizations.localeOf(context),
                                          )));
                            },
                            leading: const Icon(Icons.language,
                                key: Key('side-nav-language'), size: 16)),
                        _buildDrawerItem(
                            title: Row(
                              children: <Widget>[
                                Text(AppLocalizations.of(context).currency),
                                if (cexProvider.selectedFiat != null)
                                  Text(' (${cexProvider.selectedFiat})'),
                              ],
                            ),
                            onTap: () {
                              showCurrenciesDialog(context);
                            },
                            leading: cexProvider.selectedFiatSymbol.length > 1
                                ? const Icon(Icons.account_balance_wallet,
                                    key: Key('side-nav-currency'), size: 16)
                                : Text(' ${cexProvider.selectedFiatSymbol}')),
                        _buildDrawerItem(
                          title: Text(AppLocalizations.of(context).hideBalance),
                          leading: const Icon(Icons.money_off, size: 16),
                          trailing: StreamBuilder<bool>(
                            initialData: settingsBloc.showBalance,
                            stream: settingsBloc.outShowBalance,
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              return snapshot.hasData
                                  ? Switch(
                                      value: !snapshot.data,
                                      key: const Key('settings-hide-balance'),
                                      onChanged: (bool dataSwitch) {
                                        settingsBloc
                                            .setShowBalance(!dataSwitch);
                                      })
                                  : Container();
                            },
                          ),
                        ),
                        Divider(
                          indent: 20,
                          endIndent: 20,
                        ),
                        _buildDrawerItem(
                            title:
                                Text(AppLocalizations.of(context).addressBook),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          const AddressBookPage()));
                            },
                            leading: const Icon(Icons.import_contacts,
                                key: Key('side-nav-addressbook'), size: 16)),
                        Divider(
                          indent: 20,
                          endIndent: 20,
                        ),
                        _buildDrawerItem(
                            title: Text(AppLocalizations.of(context).settings),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          SettingPage()));
                            },
                            leading: const Icon(Icons.settings,
                                key: Key('side-nav-settings'), size: 16)),
                        _buildDrawerItem(
                            title: Text(AppLocalizations.of(context).helpLink),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          HelpPage()));
                            },
                            leading: const Icon(Icons.help,
                                key: Key('side-nav-help-feedback'), size: 16)),
                        _buildDrawerItem(
                          title: Text(AppLocalizations.of(context).switchTheme),
                          leading: const Icon(Icons.brush, size: 16),
                          trailing: StreamBuilder<bool>(
                            initialData: settingsBloc.isLightTheme,
                            stream: settingsBloc.outLightTheme,
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              return snapshot.hasData
                                  ? Switch(
                                      value: snapshot.data,
                                      key: const Key('settings-switch-theme'),
                                      onChanged: (bool dataSwitch) {
                                        settingsBloc.setLightTheme(dataSwitch);
                                      })
                                  : Container();
                            },
                          ),
                        ),
                        Divider(
                          indent: 20,
                          endIndent: 20,
                        ),
                        _buildDrawerItem(
                          leading: const Icon(Icons.exit_to_app,
                              key: Key('side-nav-logout'), size: 16),
                          onTap: () {
                            Navigator.pop(context);
                            showLogoutConfirmation(widget.mContext);
                          },
                          title: Text(AppLocalizations.of(context).logout),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    Function onTap,
    Widget title,
    Widget leading,
    Widget trailing,
  }) {
    trailing ??= const Icon(Icons.chevron_right);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          children: <Widget>[
            if (leading != null)
              Row(
                children: <Widget>[leading, const SizedBox(width: 4)],
              ),
            Expanded(
              child: title,
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
