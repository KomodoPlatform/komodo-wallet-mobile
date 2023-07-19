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
import '../../widgets/primary_button.dart';

class AddCoinButton extends StatelessWidget {
  const AddCoinButton(
      {Key key,
      this.isCollapsed = false,
      this.hideAddCoinLoading = false,
      this.onShowAddCoinLoading})
      : super(key: key);

  final bool isCollapsed;
  final bool hideAddCoinLoading;
  final VoidCallback onShowAddCoinLoading;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CoinToActivate>(
        initialData: coinsBloc.currentActiveCoin,
        stream: coinsBloc.outcurrentActiveCoin,
        builder:
            (BuildContext context, AsyncSnapshot<CoinToActivate> snapshot) {
          if (snapshot.data != null && !hideAddCoinLoading) {
            return isCollapsed
                ? Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 8,
                      ),
                      const CircularProgressIndicator(),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(snapshot.data.currentStatus ??
                          AppLocalizations.of(context).connecting),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  );
          } else {
            return FutureBuilder<bool>(
              future: _buildAddCoinButton(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                final hasCoinsToAdd = snapshot.data;

                if (hasCoinsToAdd ?? false) {
                  if (isCollapsed)
                    return Center(
                      child: OutlinedButton(
                        style: Theme.of(context)
                            .outlinedButtonTheme
                            .style
                            .copyWith(
                              shape: MaterialStateProperty.all(
                                const CircleBorder(),
                              ),
                            ),
                        key: const Key('add-coins-button-collapse'),
                        onPressed: () => _showAddCoinPage(context),
                        child: Icon(Icons.add),
                      ),
                    );

                  return PrimaryButton(
                    key: const Key('add-coins-button'),
                    icon: Icon(Icons.add),
                    text: AppLocalizations.of(context).addCoin,
                    onPressed: () => _showAddCoinPage(context),
                  );
                } else {
                  return SizedBox();
                }
              },
            );
          }
        });
  }

  void _showAddCoinPage(BuildContext context) {
    if (hideAddCoinLoading && onShowAddCoinLoading != null) {
      onShowAddCoinLoading();
      return;
    }

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
