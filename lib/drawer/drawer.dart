import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/screens/addressbook/addressbook_page.dart';
import 'package:komodo_dex/screens/authentification/logout_confirmation.dart';
import 'package:komodo_dex/screens/settings/currencies_dialog.dart';
import 'package:komodo_dex/screens/settings/select_language_page.dart';
import 'package:komodo_dex/screens/settings/setting_page.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/widgets/shared_preferences_builder.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
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
    final double headerHeight = MediaQuery.of(context).size.height * 0.25 -
        MediaQuery.of(context).padding.top;

    return SizedBox(
      width: drawerWidth,
      child: SafeArea(
        child: Drawer(
          child: Container(
            color: Theme.of(context).primaryColor,
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
                        Color.fromRGBO(39, 71, 110, 0.6),
                        Color.fromRGBO(65, 234, 213, 0.1),
                      ],
                    )),
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 5,
                        bottom: 5,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: headerHeight * 0.4,
                              child: Image.asset(
                                  'assets/mark_and_text_vertical_light.png'),
                            ),
                            Divider(
                              color: Colors.white,
                              height: headerHeight * 0.22,
                              indent: drawerWidth * 0.1,
                              endIndent: drawerWidth * 0.1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset(
                                  'assets/wallet.svg',
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
                                        style: const TextStyle(fontSize: 18),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    })
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ListView(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    shrinkWrap: true,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildDrawerItem(
                              title: SharedPreferencesBuilder<dynamic>(
                                  pref: 'current_languages',
                                  builder: (BuildContext context,
                                      AsyncSnapshot<dynamic> snapshot) {
                                    return Row(
                                      children: <Widget>[
                                        const Text(
                                            'Language'), // TODO(yurii): localization
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
                                                  Localizations.localeOf(
                                                      context),
                                            )));
                              },
                              leading: Icon(
                                Icons.language,
                                size: 16,
                                color: Colors.white.withAlpha(200),
                              )),
                          _buildDrawerItem(
                              title: Row(
                                children: <Widget>[
                                  const Text(
                                      'Currency'), // TODO(yurii): localization
                                  if (cexProvider.selectedFiat != null)
                                    Text(' (${cexProvider.selectedFiat})'),
                                ],
                              ),
                              onTap: () {
                                showCurrenciesDialog(context);
                              },
                              leading: cexProvider.selectedFiatSymbol.length > 1
                                  ? Icon(
                                      Icons.account_balance_wallet,
                                      size: 16,
                                      color: Colors.white.withAlpha(200),
                                    )
                                  : Text(' ${cexProvider.selectedFiatSymbol}')),
                          _buildDrawerItem(
                            title: const Text(
                                'Hide balances'), // TODO(yurii): localization
                            leading: Icon(
                              Icons.money_off,
                              size: 16,
                              color: Colors.white.withAlpha(200),
                            ),
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
                            color: Theme.of(context).hintColor,
                          ),
                          _buildDrawerItem(
                              title: const Text('Address book'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push<dynamic>(
                                    context,
                                    MaterialPageRoute<dynamic>(
                                        builder: (BuildContext context) =>
                                            AddressBookPage()));
                              },
                              leading: Icon(
                                Icons.import_contacts,
                                size: 16,
                                color: Colors.white.withAlpha(200),
                              )),
                          Divider(
                            indent: 20,
                            endIndent: 20,
                            color: Theme.of(context).hintColor,
                          ),
                          _buildDrawerItem(
                              title:
                                  Text(AppLocalizations.of(context).settings),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push<dynamic>(
                                    context,
                                    MaterialPageRoute<dynamic>(
                                        builder: (BuildContext context) =>
                                            SettingPage()));
                              },
                              leading: Icon(
                                Icons.settings,
                                size: 16,
                                color: Colors.white.withAlpha(200),
                              )),
                        ],
                      ),
                    ],
                  ),
                  Expanded(child: Container()),
                  Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          showLogoutConfirmation(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.exit_to_app,
                                size: 16,
                                color: Colors.white.withAlpha(200),
                              ),
                              const SizedBox(width: 4),
                              Text(AppLocalizations.of(context).logout),
                            ],
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                ],
              ),
            ),
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
    trailing ??= Icon(Icons.chevron_right);

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
