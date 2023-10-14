import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:komodo_dex/widgets/eager_floating_action_button.dart';

import '../../../../app_config/app_config.dart';
import '../../../../blocs/coins_bloc.dart';
import '../../../../blocs/dialog_bloc.dart';
import '../../../../blocs/main_bloc.dart';
import '../../../../localizations.dart';
import '../../../../model/coin.dart';
import '../../../../services/db/database.dart';
import '../../../../widgets/custom_simple_dialog.dart';
import '../portfolio/activate/select_coins_page.dart';

class AddCoinFab extends StatefulWidget {
  const AddCoinFab({Key key}) : super(key: key);

  @override
  _AddCoinFabState createState() => _AddCoinFabState();
}

class _AddCoinFabState extends State<AddCoinFab> {
  bool _areCoinsLoading = true;
  StreamSubscription<CoinToActivate> _coinSubscription;

  @override
  void initState() {
    super.initState();

    if (coinsBloc.currentActiveCoin == null) {
      setState(() => _areCoinsLoading = false);
    } else {
      _coinSubscription = coinsBloc.outcurrentActiveCoin.listen(
        (coinData) {
          setState(() {
            _areCoinsLoading = coinData != null;
          });
          _showAddCoinPageIfNeeded();
        },
        cancelOnError: false,
      );
    }
  }

  void _showAddCoinPageIfNeeded() async {
    if (!mounted) return;

    bool hasCoinsToAdd = await _userHasInactiveCoins();

    if (_areCoinsLoading && hasCoinsToAdd) {
      _showAddCoinPage(context, _areCoinsLoading);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _userHasInactiveCoins(),
      builder: (context, snapshot) {
        bool hasCoinsToAdd = snapshot.data ?? true;

        return EagerFloatingActionButton(
          onTap: () => _onPressed(context),
          isReady: !_areCoinsLoading,
          child:
              Icon(hasCoinsToAdd == false ? Icons.do_not_disturb : Icons.add),
        );
      },
    );
  }

  void _onPressed(BuildContext context) {
    _showAddCoinPage(context, _areCoinsLoading);
  }

  void _showAddCoinPage(BuildContext context, bool isLoading) {
    if (mainBloc.networkStatus != NetworkStatus.Online) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).errorColor,
          content: Text(AppLocalizations.of(context).noInternet),
        ),
      );
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
                Text(
                  AppLocalizations.of(context).tooManyAssetsEnabledSpan1 +
                      numCoinsEnabled.toString() +
                      AppLocalizations.of(context).tooManyAssetsEnabledSpan2 +
                      maxCoinPerPlatform.toString() +
                      AppLocalizations.of(context).tooManyAssetsEnabledSpan3,
                ),
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          dialogBloc.closeDialog(context);
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => const SelectCoinsPage(),
            ),
          );
        });
      }
    }
  }

  Future<bool> _userHasInactiveCoins() async {
    final active = await Db.activeCoins;
    final known = await coins;
    return active.length < known.length;
  }

  @override
  void dispose() {
    _coinSubscription?.cancel();
    super.dispose();
  }
}
