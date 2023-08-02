import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_bloc.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_event.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_state.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_notifications.dart';
import 'package:komodo_dex/packages/z_coin_activation/widgets/rotating_progress_indicator.dart';
import 'package:komodo_dex/services/mm_service.dart';

enum SyncType { newTransactions, fullSync, specifiedDate }

class ZCoinStatusWidget extends StatefulWidget {
  const ZCoinStatusWidget({Key key}) : super(key: key);

  static BlocListenerCondition<ZCoinActivationState> get listenWhen =>
      (previous, current) =>
          previous.runtimeType != current.runtimeType &&
          current is! ZCoinActivationInitial;

  static BlocWidgetListener get listener =>
      (context, state) => _ZCoinStatusWidgetState.listener(context, state);

  static Future<Map<String, dynamic>> Function(BuildContext)
      get showConfirmationDialog => _showConfirmationDialog;

  @override
  State<ZCoinStatusWidget> createState() => _ZCoinStatusWidgetState();
}

class _ZCoinStatusWidgetState extends State<ZCoinStatusWidget> {
  static bool get canNotify => ZCoinProgressNotifications.canNotify;

  @override
  initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (apiReady != mmSe.running) {
        setState(() => apiReady = mmSe.running);
      }

      if (apiReady) {
        return timer.cancel();
      }
    });
  }

  bool apiReady = mmSe.running;
// class _SetupZcoinButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZCoinActivationBloc, ZCoinActivationState>(
      // listenWhen: (previous, current) =>
      //     previous.runtimeType != current.runtimeType,
      // listener: listener,
      builder: (context, state) {
        // bool coinActivated = state is ZCoinActivationSuccess;
        bool isActivationInProgress = state is ZCoinActivationInProgess;

        if (isActivationInProgress) {
          final progressState = state as ZCoinActivationInProgess;
          return ListTile(
            onTap: () => _showInProgressDialog(context),
            title: Text('ZHTLC Activating'),
            subtitle: Text(
              'Do not close the app. Tap for more info...',
            ),
            leading: Icon(
              Icons.warning,
              color: Colors.red,
            ),
            tileColor: Theme.of(context).primaryColor,
            trailing: SizedBox(
              child: RotatingCircularProgressIndicator(
                key: ValueKey('z_coin_status_rotating_progress_indicator'),
                value: progressState.progress,
              ),
            ),
          );
        }

        final bool isStatusLoading = state is ZCoinActivationStatusLoading;

        final bool knownActivationStatus =
            (state is ZCoinActivationStatusChecked ? state.isActivated : false);

        return ListTile(
          title: Text('ZCoin (ZHTLC) Activation'),
          tileColor: Theme.of(context).primaryColor,
          leading: isStatusLoading
              ? CircularProgressIndicator()
              : knownActivationStatus
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                  : null,
          subtitle: isStatusLoading
              ? null
              : Text(
                  knownActivationStatus
                      ? 'ZHTLC coins are activated'
                      : 'ZHTLC coins are not activated',
                ),
          selected: false,
          trailing: IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () => context
                .read<ZCoinActivationBloc>()
                .add(ZCoinActivationStatusRequested()),
          ),
        );
      },
    );
  }

  static void listener(BuildContext context, ZCoinActivationState state) {
    final scaffold = ScaffoldMessenger.maybeOf(context);
    if (scaffold == null) return;

    final l10n = AppLocalizations.of(context);

    final theme = Theme.of(context);

    ScaffoldFeatureController updateNotice;

    if (state is ZCoinActivationFailure) {
      scaffold.clearMaterialBanners();

      updateNotice = scaffold.showMaterialBanner(
        MaterialBanner(
          elevation: 1,
          content: Text(state.message),
          leading: Icon(
            Icons.error,
            color: Colors.red,
          ),
          backgroundColor: theme.colorScheme.error,
          actions: [
            TextButton(
              onPressed: () => scaffold.hideCurrentMaterialBanner(),
              child: Text(
                l10n.okButton,
                style: TextStyle().copyWith(color: theme.colorScheme.onError),
              ),
            ),
          ],
        ),
      );
    } else if (state is ZCoinActivationSuccess) {
      scaffold.clearMaterialBanners();

      updateNotice = scaffold.showMaterialBanner(
        MaterialBanner(
          elevation: 1,

          leading: Icon(
            Icons.check_circle,
            color: theme.colorScheme.secondary,
          ),
          content: Text('ZHTLC coins activated successfully'),
          // backgroundColor: Colors.green,
          actions: [
            TextButton(
              onPressed: () => scaffold.hideCurrentMaterialBanner(),
              child: Text(l10n.okButton),
            ),
          ],
        ),
      );
    } else if (state is ZCoinActivationInProgess) {
      // Prefer showing the notification if possible
      if (!canNotify) {
        scaffold
          ..removeCurrentMaterialBanner()
          ..showMaterialBanner(
            MaterialBanner(
              elevation: 1,
              content: Row(
                children: [
                  Text('ZHTLC Activation in Progress'),
                  SizedBox(width: 8),
                  SizedBox.square(
                    dimension: 24,
                    child: RotatingCircularProgressIndicator(
                      value: state.progress,
                    ),
                  ),
                  if (state.progress != null && state.progress > 0) ...[
                    SizedBox(width: 8),
                    Text(
                      '${(state.progress * 100).round()}%',
                    ),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => scaffold.hideCurrentMaterialBanner(),
                  child: Text(l10n.okButton),
                ),
                TextButton(
                  onPressed: () => _showInProgressDialog(context),
                  child: Text('More Info'),
                ),
              ],
            ),
          );
      }
    }

    Timer(
      const Duration(seconds: 5),
      () {
        if (updateNotice != null) {
          updateNotice.close();
        }
      },
    );
  }
}

Future<Map<String, dynamic>> _showConfirmationDialog(BuildContext context) {
  final appL10n = AppLocalizations.of(context);

  SyncType _syncType = SyncType.newTransactions;
  DateTime _lastDate = DateTime.now().subtract(Duration(days: 1));
  DateTime _selectedDate = _lastDate;

  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Scan for past Z-Coin (ZHTLC) transactions?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(
                    'You have selected to activate a ZHTLC asset. Which transactions would you like to sync?',
                  ),
                  // Radio list tiles
                  RadioListTile<SyncType>(
                    title: const Text('Sync new transactions'),
                    value: SyncType.newTransactions,
                    groupValue: _syncType,
                    onChanged: (SyncType value) {
                      setState(() {
                        _syncType = value;
                      });
                    },
                  ),
                  RadioListTile<SyncType>(
                    title: const Text('Full sync'),
                    value: SyncType.fullSync,
                    groupValue: _syncType,
                    onChanged: (SyncType value) {
                      setState(() {
                        _syncType = value;
                      });
                    },
                  ),
                  RadioListTile<SyncType>(
                    title: const Text('Sync from specified date'),
                    value: SyncType.specifiedDate,
                    groupValue: _syncType,
                    onChanged: (SyncType value) {
                      setState(() {
                        _syncType = value;
                      });
                    },
                  ),
                  // Date Picker
                  _syncType == SyncType.specifiedDate
                      ? Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final DateTime pickedDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null &&
                                    pickedDate != _selectedDate)
                                  setState(() {
                                    _selectedDate = pickedDate;
                                  });
                              },
                              child: Text('Select Date'),
                            ),
                            // Display the selected date
                            Text(
                              "Start Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
                            ),
                          ],
                        )
                      : SizedBox.shrink(),

                  SizedBox(height: 16),
                  // Sync Type Description
                  if (_syncType == SyncType.newTransactions)
                    Text(
                      'Your wallet will show future transactions made after activation associated with your public key.',
                    ),
                  if (_syncType == SyncType.fullSync)
                    Text(
                      'Your wallet will show all past transactions associated with your public key. This will take significant storage and time as all blocks will be downloaded and scanned.',
                    ),
                  if (_syncType == SyncType.specifiedDate)
                    Text(
                      'Your wallet will show all past transactions associated with your public key made after the specified date.',
                    ),

                  if (Platform.isIOS) ...[
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(
                        Icons.warning,
                        color: Colors.amber,
                      ),
                      dense: true,
                      title: Text(
                        'Warning: Minimizing the app on iOS will terminate the activation process.',
                        style: TextStyle(color: Colors.amber),
                      ),
                    )
                  ],
                  Column(
                    children: [
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.amber,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: const <Widget>[
                              Icon(
                                Icons.warning,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This will take a while and the app must be kept in the foreground. Terminating the app while activation is in progress could lead to issues.',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop<Map<String, dynamic>>(context, null),
                child: Text(appL10n.cancelButton),
              ),
              TextButton(
                onPressed: () => Navigator.pop<Map<String, dynamic>>(
                  context,
                  {'syncType': _syncType, 'selectedDate': _selectedDate},
                ),
                child: Text(appL10n.confirm),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showInProgressDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) {
      final state =
          context.watch<ZCoinActivationBloc>().state.asProgressOrNull();

      if (state == null) return Container();

      final appL10n = AppLocalizations.of(context);

      final etaString = state?.eta?.inMinutes == null
          ? appL10n.loading
          : '${state.eta.inMinutes}${appL10n.minutes}';
      return AlertDialog(
        title: Text('${appL10n.warning}: ZHLTC Activation in Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!ZCoinProgressNotifications.canNotify) ...[
              Text(
                'Please enable notifications to get updates on the activation progress.',
                style: TextStyle(color: Colors.amber),
              ),
              SizedBox(height: 16),
            ],
            Text(
              'This will take a while and the app must be kept in the foreground.'
              'Closing the app while activation is in progress could lead to issues.',
            ),
            SizedBox(height: 16),
            Text(
              '${appL10n.rewardsTableTime}: $etaString',
            ),
            SizedBox(height: 16),
            Text(
              '${appL10n.swapProgress}: ${(state.progress * 100).round()}%',
            ),
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: state.progress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appL10n.close),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    },
  );
}
