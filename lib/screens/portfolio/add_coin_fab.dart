import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

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
  bool _hasCoinsToAdd;

  /// We show the add button state eagerly while the coins are still loading.
  /// If the user taps the button while the coins are still loading, we need
  /// to show a progress indicator instead of the add button and then call the
  /// "tap" event handler once the coins are loaded.
  bool tappedWhileLoading = false;

  StreamSubscription<CoinToActivate> _coinSubscription;
  final Completer<bool> _shouldShowAddCoinButtonCompleter = Completer<bool>();

  bool get _isShowLoading => _isLoading && tappedWhileLoading;
  bool get _isLoading => _hasCoinsToAdd == null || _areCoinsLoading;

  @override
  void initState() {
    super.initState();

    if (coinsBloc.currentActiveCoin != null) {
      _areCoinsLoading = false;
    }

    _coinSubscription = coinsBloc.outcurrentActiveCoin.listen((coinData) {
      setState(() {
        _areCoinsLoading = coinData != null;
      });

      _showAddCoinPageIfNeeded();
    }, cancelOnError: false);

    _shouldShowAddCoinButton().then((value) {
      if (!_shouldShowAddCoinButtonCompleter.isCompleted) {
        _shouldShowAddCoinButtonCompleter.complete(value);
      }
    });

    _shouldShowAddCoinButtonCompleter.future.then((value) {
      setState(() => _hasCoinsToAdd = value);
    }).whenComplete(() => _showAddCoinPageIfNeeded());
  }

  void _showAddCoinPageIfNeeded() {
    if (!mounted || _isLoading) return;

    if (tappedWhileLoading && _hasCoinsToAdd == true) {
      _showAddCoinPage(context, _areCoinsLoading);
    }

    if (mounted)
      setState(() {
        tappedWhileLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_isShowLoading) {
      return FloatingActionButton(
        key: const Key('add-coins-button'),
        onPressed: null,
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).disabledColor),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: (_hasCoinsToAdd == true) ? () => _onPressed(context) : null,
      child: Icon(_hasCoinsToAdd == false ? Icons.do_not_disturb : Icons.add),
      key: const Key('add-coins-button'),
    );
  }

  void _onPressed(BuildContext context) {
    if (_isLoading) {
      setState(() {
        tappedWhileLoading = true;
      });
    } else {
      _showAddCoinPage(context, _areCoinsLoading);
    }
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
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => const SelectCoinsPage(),
          ),
        );
      }
    }
  }

  Future<bool> _shouldShowAddCoinButton() async {
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
