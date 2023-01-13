import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../blocs/coins_bloc.dart';
import '../../../../blocs/dialog_bloc.dart';
import '../../../../blocs/main_bloc.dart';
import '../../../../localizations.dart';
import '../../../../app_config/app_config.dart';
import '../../../../model/coin.dart';
import '../portfolio/activate/select_coins_page.dart';
import '../../../../services/db/database.dart';
import '../../../../widgets/custom_simple_dialog.dart';

class AddCoinButton extends StatefulWidget {
  const AddCoinButton({Key key}) : super(key: key);

  @override
  _AddCoinButtonState createState() => _AddCoinButtonState();
}

class _AddCoinButtonState extends State<AddCoinButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CoinToActivate>(
        initialData: coinsBloc.currentActiveCoin,
        stream: coinsBloc.outcurrentActiveCoin,
        builder:
            (BuildContext context, AsyncSnapshot<CoinToActivate> snapshot) {
          if (snapshot.data != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 16,
                ),
                const CircularProgressIndicator(),
                const SizedBox(
                  height: 8,
                ),
                Text(snapshot.data.currentStatus ??
                    AppLocalizations.of(context).connecting),
                const SizedBox(
                  height: 16,
                ),
              ],
            );
          } else {
            return FutureBuilder<bool>(
              future: _buildAddCoinButton(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data != null && snapshot.data) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          key: const Key('adding-coins'),
                          child: Icon(Icons.add),
                          mini: true,
                          onPressed: _showAddCoinPage,
                        ),
                        SizedBox(width: 16),
                        Text(
                          AppLocalizations.of(context).addCoin,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            );
          }
        });
  }

  void _showAddCoinPage() {
    if (mainBloc.networkStatus != NetworkStatus.Online) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).errorColor,
        content: Text(AppLocalizations.of(context).noInternet),
      ));
    } else {
      final numCoinsEnabled = coinsBloc.coinBalance.length;
      final maxCoinPerPlatform = Platform.isAndroid
          ? appConfig.maxCoinsEnabledAndroid
          : appConfig.maxCoinEnabledIOS;
      if (numCoinsEnabled >= maxCoinPerPlatform) {
        dialogBloc.closeDialog(context);
        dialogBloc.dialog = showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return CustomSimpleDialog(
              title:
                  Text(AppLocalizations.of(context).tooManyAssetsEnabledTitle),
              children: [
                Text(AppLocalizations.of(context).tooManyAssetsEnabledSpan1 +
                    numCoinsEnabled.toString() +
                    AppLocalizations.of(context).tooManyAssetsEnabledSpan2 +
                    maxCoinPerPlatform.toString() +
                    AppLocalizations.of(context).tooManyAssetsEnabledSpan3),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => dialogBloc.closeDialog(context),
                      child: Text(AppLocalizations.of(context).warningOkBtn),
                    ),
                  ],
                ),
              ],
            );
          },
        ).then((dynamic _) => dialogBloc.dialog = null);
      } else {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => const SelectCoinsPage()),
        );
      }
    }
  }

  /// Returns `true` if there are coins we can still activate, `false` if all of them activated.
  Future<bool> _buildAddCoinButton() async {
    final active = await Db.activeCoins;
    final known = await coins;
    return active.length < known.length;
  }
}
