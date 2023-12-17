import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin_type.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_bloc.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_event.dart';
import 'package:komodo_dex/packages/z_coin_activation/models/z_coin_activation_prefs.dart';
import 'package:komodo_dex/packages/z_coin_activation/widgets/z_coin_status_list_tile.dart';
import '../../../blocs/coins_bloc.dart';
import '../../../blocs/dialog_bloc.dart';
import '../../../blocs/settings_bloc.dart';
import '../../../localizations.dart';
import '../../../app_config/app_config.dart';
import '../../../model/coin.dart';
import '../../authentification/lock_screen.dart';
import '../../portfolio/activate/build_item_coin.dart';
import '../../portfolio/activate/build_type_header.dart';
import '../../portfolio/activate/search_filter.dart';
import '../../portfolio/loading_coin.dart';
import '../../../widgets/custom_simple_dialog.dart';
import '../../../widgets/primary_button.dart';
import 'build_selected_coins.dart';

import 'build_filter_coin.dart';

class SelectCoinsPage extends StatefulWidget {
  const SelectCoinsPage({this.coinsToActivate});

  final Function(List<Coin>) coinsToActivate;

  @override
  _SelectCoinsPageState createState() => _SelectCoinsPageState();
}

class _SelectCoinsPageState extends State<SelectCoinsPage> {
  bool _isDone = false;
  StreamSubscription<bool> _listenerClosePage;
  StreamSubscription<List<CoinToActivate>> _listenerCoinsActivated;
  List<Coin> _currentCoins = <Coin>[];
  List<Widget> _listViewItems = <Widget>[];
  List<CoinToActivate> _coinsToActivate = [];

  @override
  void initState() {
    coinsBloc.setCloseViewSelectCoin(false);
    _listenerClosePage =
        coinsBloc.outCloseViewSelectCoin.listen((dynamic onData) {
      if (onData != null && onData == true && mounted) {
        Navigator.of(context).pop();
      }
    });
    coinsBloc.initCoinBeforeActivation().then((_) {
      _initCoinList();
    });

    _listenerCoinsActivated = coinsBloc.outCoinBeforeActivation.listen((data) {
      setState(() {
        _coinsToActivate = data.where((element) => element.isActive).toList();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _listenerClosePage.cancel();
    _listenerCoinsActivated.cancel();
    super.dispose();
  }

  String typeFilter = '';
  final TextEditingController controller = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isDone,
      child: LockScreen(
        context: context,
        child: Scaffold(
            appBar: AppBar(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              flexibleSpace: SizedBox(),
              titleSpacing: 0,
              title: SearchFieldFilterCoin(
                clear: () => _initCoinList(),
                type: typeFilter,
                focusNode: myFocusNode,
                controller: controller,
                onFilterCoins: (List<Coin> coinsFiltered) {
                  setState(() {
                    _currentCoins = coinsFiltered;
                    _listViewItems = _buildListView();
                  });
                },
              ),
              actions: [
                BuildFilterCoin(
                  typeFilter: typeFilter,
                  allCoinsTypes: allCoinsTypes,
                  focusNode: myFocusNode,
                  onSelected: (String aType) async {
                    typeFilter = aType;
                    List<Coin> coinsFiltered = await coinsBloc
                        .getAllNotActiveCoinsWithFilter(controller.text, aType);
                    setState(() {
                      _currentCoins = coinsFiltered;
                      _listViewItems = _buildListView();
                    });
                  },
                )
              ],
            ),
            body: StreamBuilder<CoinToActivate>(
                initialData: coinsBloc.currentActiveCoin,
                stream: coinsBloc.outcurrentActiveCoin,
                builder: (BuildContext context,
                    AsyncSnapshot<CoinToActivate> snapshot) {
                  if (snapshot.data != null) {
                    return LoadingCoin();
                  } else {
                    return _isDone
                        ? LoadingCoin()
                        : Column(
                            children: [
                              if (_coinsToActivate.isNotEmpty)
                                BuildSelectedCoins(_coinsToActivate),
                              Expanded(
                                child: Scrollbar(
                                  child: ListView.builder(
                                    itemCount: _listViewItems.length,
                                    itemBuilder:
                                        (BuildContext context, int i) =>
                                            _listViewItems[i],
                                  ),
                                ),
                              ),
                              _buildDoneButton(),
                            ],
                          );
                  }
                })),
      ),
    );
  }

  void _initCoinList() async {
    for (CoinToActivate coinToActivate in coinsBloc.coinBeforeActivation) {
      _currentCoins
          .removeWhere((Coin coin) => coin.abbr == coinToActivate.coin.abbr);
      _currentCoins.add(coinToActivate.coin);
    }

    final Map<String, List<Coin>> coinsMap = getCoinsMap();
    allCoinsTypes = coinsMap.keys.toList()
      ..sort((String a, String b) => b.compareTo(a));

    _currentCoins =
        await coinsBloc.getAllNotActiveCoinsWithFilter('', typeFilter);
    setState(() {
      _listViewItems = _buildListView();
    });
  }

  List<Widget> _buildListView() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          AppLocalizations.of(context).selectCoinInfo,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Theme.of(context).colorScheme.onBackground),
        ),
      ),
      const SizedBox(
        height: 8,
      ),
      ..._buildCoinListItems(),
    ];
  }

  List<String> allCoinsTypes = [];

  Map<String, List<Coin>> getCoinsMap() {
    final Map<String, List<Coin>> coinsMap = <String, List<Coin>>{};

    for (Coin c in _currentCoins) {
      if (c.testCoin) continue;
      if (!coinsMap.containsKey(c.type.name)) {
        coinsMap.putIfAbsent(c.type.name, () => [c]);
      } else {
        coinsMap[c.type.name].add(c);
      }
    }

    return coinsMap;
  }

  List<Widget> _buildCoinListItems() {
    if (_currentCoins.isEmpty) {
      return [
        Center(
          child: Text(
            AppLocalizations.of(context).noCoinFound,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        )
      ];
    }

    final List<Widget> list = <Widget>[];

    final Map<String, List<Coin>> coinsMap = <String, List<Coin>>{};

    for (Coin c in _currentCoins) {
      if (c.testCoin) continue;
      if (!coinsMap.containsKey(c.type.name)) {
        coinsMap.putIfAbsent(c.type.name, () => [c]);
      } else {
        coinsMap[c.type.name].add(c);
      }
    }

    final List<String> sortedTypes = coinsMap.keys.toList()
      ..sort((String a, String b) => a.compareTo(b));

    for (String type in sortedTypes) {
      list.add(BuildTypeHeader(
        type: type,
        query: controller.text,
        filterType: typeFilter,
      ));

      List<Coin> _tCoins = coinsMap[type];
      _tCoins.sort((Coin a, Coin b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      for (Coin coin in _tCoins) {
        list.add(BuildItemCoin(
          key: Key('coin-activate-${coin.abbr}'),
          coin: coin,
        ));
      }
    }

    final List<Coin> testCoins = _currentCoins
        .where((Coin c) =>
            (c.testCoin && settingsBloc.enableTestCoins) ||
            appConfig.defaultTestCoins.contains(c.abbr))
        .toList();
    if (testCoins.isNotEmpty) {
      list.add(BuildTypeHeader(
        type: null,
        filterType: typeFilter,
        query: controller.text,
      ));

      testCoins.sort((Coin a, Coin b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      for (Coin testCoin in testCoins) {
        list.add(BuildItemCoin(
          key: Key('coin-activate-${testCoin.abbr}'),
          coin: testCoin,
        ));
      }
    }

    return list;
  }

  Widget _buildDoneButton() {
    int selected = coinsBloc.coinBeforeActivation
        .where((element) => element.isActive)
        .length;
    int activated = coinsBloc.coinBalance.length;

    int maxCoinLength = Platform.isIOS
        ? appConfig.maxCoinEnabledIOS
        : appConfig.maxCoinsEnabledAndroid;

    int remainingSpace = maxCoinLength - activated;
    return SizedBox(
      height: 80,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilder<List<CoinToActivate>>(
              initialData: coinsBloc.coinBeforeActivation,
              stream: coinsBloc.outCoinBeforeActivation,
              builder: (BuildContext context,
                  AsyncSnapshot<List<CoinToActivate>> snapshot) {
                bool isButtonActive = false;
                if (snapshot.hasData) {
                  for (CoinToActivate coinToActivate in snapshot.data) {
                    if (coinToActivate.isActive) {
                      isButtonActive = true;
                    }
                  }
                }
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  if (remainingSpace - selected == 0)
                    Text(
                      AppLocalizations.of(context).coinsActivatedLimitReached,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          .apply(color: Theme.of(context).colorScheme.error),
                    ),
                  Text(
                    AppLocalizations.of(context)
                        .enable(selected, remainingSpace - selected),
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  PrimaryButton(
                    key: const Key('done-activate-coins'),
                    text: AppLocalizations.of(context).done,
                    isLoading: _isDone,
                    onPressed: isButtonActive ? _pressDoneButton : null,
                  )
                ]);
              }),
        ),
      ),
    );
  }

  void _pressDoneButton() async {
    final localisations = AppLocalizations.of(context);

    final numCoinsEnabled = coinsBloc.coinBalance.length;
    final numCoinsTryingEnable =
        coinsBloc.coinBeforeActivation.where((c) => c.isActive).toList().length;
    final maxCoinPerPlatform = Platform.isAndroid
        ? appConfig.maxCoinsEnabledAndroid
        : appConfig.maxCoinEnabledIOS;
    if (numCoinsEnabled + numCoinsTryingEnable > maxCoinPerPlatform) {
      dialogBloc.closeDialog(context);
      dialogBloc.dialog = showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CustomSimpleDialog(
            title: Text(localisations.enablingTooManyAssetsTitle),
            children: [
              Text(localisations.enablingTooManyAssetsSpan1 +
                  numCoinsEnabled.toString() +
                  localisations.enablingTooManyAssetsSpan2 +
                  numCoinsTryingEnable.toString() +
                  localisations.enablingTooManyAssetsSpan3 +
                  maxCoinPerPlatform.toString() +
                  localisations.enablingTooManyAssetsSpan4),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => dialogBloc.closeDialog(context),
                    child: Text(localisations.warningOkBtn),
                  ),
                ],
              ),
            ],
          );
        },
      ).then((dynamic _) => dialogBloc.dialog = null);
      return;
    } else {
      final allAccepted = await _confirmSpecialActivations();

      if (!allAccepted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(
              '${localisations.activationCancelled}\n'
              '${localisations.pleaseAcceptAllCoinActivationRequests}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        return;
      }
      final hasZCoins = coinsBloc.coinBeforeActivation
          .any((c) => c.coin.type == CoinType.zhtlc);

      setState(() => _isDone = true);
      await coinsBloc.activateCoinsSelected();
      if (hasZCoins) {
        context.read<ZCoinActivationBloc>().add(ZCoinActivationRequested());
      }
    }
  }

  /// Shows a confirmation dialog for each coin which requires special
  /// activation.
  ///
  /// Currently this is only for ZHTLC coins because their activation can take
  /// a long time and the user must keep the app open.
  Future<bool> _confirmSpecialActivations() async {
    final newCoins = coinsBloc.coinBeforeActivation
        .where((c) => c.isActive && !c.coin.isActive)
        .toList();

    final hasAnyZCoinActivations =
        newCoins.any((c) => c.coin.type == CoinType.zhtlc);

    if (hasAnyZCoinActivations) {
      final isDeviceSupported = await _devicePermitsIntensiveWork(context);
      if (!isDeviceSupported) return false;

      final zhtlcActivationPrefs =
          await ZCoinStatusWidget.showConfirmationDialog(context);
      if (zhtlcActivationPrefs == null) return false;

      // enum SyncType { newTransactions, fullSync, specifiedDate } is in z_coin_status_list_tile.dart
      // Use zhtlcActivationPrefs as { 'zhtlcSyncType': SyncType, 'zhtlcSyncStartDate': DateTime }
      await saveZhtlcActivationPrefs(zhtlcActivationPrefs);
    }

    return true;
  }

  /// *NOT IMPLEMENTED*
  ///
  /// Checks if the device is capable of performing intensive work required
  /// for certain coin activations. Shows a dialog if the device is not
  /// capable.
  ///
  /// Returns true if the device is capable of performing intensive work.
  /// Returns false after showing a dialog if the device is not capable.
  Future<bool> _devicePermitsIntensiveWork(BuildContext context) async {
    // TODO: Ensure user has sufficient battery life, storage space, and
    // has battery saver disabled.

    return true;
  }
}
