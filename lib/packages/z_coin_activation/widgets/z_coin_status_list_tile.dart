import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_bloc.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_event.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_state.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_notifications.dart';
import 'package:komodo_dex/packages/z_coin_activation/models/z_coin_activation_prefs.dart';
import 'package:komodo_dex/packages/z_coin_activation/widgets/rotating_progress_indicator.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/widgets/animated_linear_progress_indicator.dart';

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

  AppLocalizations get localisations => AppLocalizations.of(context);

  @override
  initState() {
    super.initState();

    if (!apiReady) {
      MM.untilRpcIsUp().then((_) {
        if (mounted) setState(() => apiReady = true);
      });
    }
  }

  bool apiReady = mmSe.running;

  @override
  Widget build(BuildContext context) {
    final protocolTag = localisations.tagZHTLC;

    return BlocBuilder<ZCoinActivationBloc, ZCoinActivationState>(
      builder: (context, state) {
        bool isActivationInProgress = state is ZCoinActivationInProgess;

        if (isActivationInProgress) {
          final progressState = state as ZCoinActivationInProgess;
          return ListTile(
            title: Text(localisations.activating(protocolTag)),
            dense: true,
            onTap: () => _showInProgressDialog(context),
            subtitle: Text(localisations.doNotCloseTheAppTapForMoreInfo),
            leading: Icon(Icons.hourglass_full_rounded),
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

        return ListTile(
          title: Text(localisations.activation('PIRATE ($protocolTag)')),
          tileColor: Theme.of(context).primaryColor,
          leading: isStatusLoading
              ? CircularProgressIndicator()
              : state is ZCoinActivationStatusChecked && state.isActivated
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                  : null,
          subtitle: isStatusLoading
              ? null
              : state is ZCoinActivationStatusChecked
                  ? Text(
                      state.isActivated
                          ? localisations.coinsAreActivated(protocolTag)
                          : localisations.coinsAreNotActivated(protocolTag),
                    )
                  : null,
          selected: false,
        );
      },
    );
  }

  static void listener(BuildContext context, ZCoinActivationState state) {
    ScaffoldMessengerState scaffold;

    try {
      ScaffoldMessenger.maybeOf(context);
    } catch (e) {
      return;
    }

    if (scaffold == null) return;

    final localisations = AppLocalizations.of(context);

    final protocolTag = localisations.tagZHTLC;

    final theme = Theme.of(context);

    ScaffoldFeatureController updateNotice;

    if (state is ZCoinActivationFailure) {
      scaffold.clearMaterialBanners();

      updateNotice = scaffold.showMaterialBanner(
        MaterialBanner(
          elevation: 1,
          content: Text(
            localiseFailedReason(localisations, state.reason),
          ),
          leading: Icon(
            Icons.error,
            color: Colors.red,
          ),
          backgroundColor: theme.colorScheme.error,
          actions: [
            TextButton(
              onPressed: () => scaffold.hideCurrentMaterialBanner(),
              child: Text(
                localisations.okButton,
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
          content:
              Text(localisations.coinsAreActivatedSuccessfully(protocolTag)),
          actions: [
            TextButton(
              onPressed: () => scaffold.hideCurrentMaterialBanner(),
              child: Text(localisations.okButton),
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
                  Text(localisations.activationInProgress(protocolTag)),
                  SizedBox(width: 8),
                  SizedBox.square(
                    dimension: 24,
                    child: RotatingCircularProgressIndicator(
                      value: state.progress,
                    ),
                  ),
                  if (state.progress != null && state.progress > 0) ...[
                    SizedBox(width: 8),
                    Text('${(state.progress * 100).round()}%'),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => scaffold.hideCurrentMaterialBanner(),
                  child: Text(localisations.okButton),
                ),
                TextButton(
                  onPressed: () => _showInProgressDialog(context),
                  child: Text(localisations.moreInfo),
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

  static String localiseFailedReason(
    AppLocalizations localisations,
    ZCoinActivationFailureReason reason,
  ) {
    final tag = localisations.tagZHTLC;
    switch (reason) {
      case ZCoinActivationFailureReason.startFailed:
      case ZCoinActivationFailureReason.failedAfterStart:
      case ZCoinActivationFailureReason.failedOther:
        return localisations.weFailedTo(tag);

      case ZCoinActivationFailureReason.failedToCancel:
        return localisations.failedToCancelActivation(tag);

      case ZCoinActivationFailureReason.cancelled:
        return localisations.coinActivationCancelled(tag);

      default:
        return localisations.weFailedTo(tag);
    }
  }
}

Future<Map<String, dynamic>> _showConfirmationDialog(BuildContext context) {
  SyncType _syncType = SyncType.newTransactions;
  DateTime _lastDate = DateTime.now().subtract(Duration(days: 1));
  DateTime _selectedDate = _lastDate;

  final localisations = AppLocalizations.of(context);

  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(
              localisations.syncTransactionsQuestion(localisations.tagZHTLC),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  RadioListTile<SyncType>(
                    title: Text(localisations.syncNewTransactions),
                    value: SyncType.newTransactions,
                    groupValue: _syncType,
                    onChanged: (SyncType value) {
                      setState(() {
                        _syncType = value;
                      });
                    },
                  ),
                  RadioListTile<SyncType>(
                    title: Text(localisations.syncFromDate),
                    value: SyncType.specifiedDate,
                    groupValue: _syncType,
                    onChanged: (SyncType value) {
                      setState(() {
                        _syncType = value;
                      });
                    },
                  ),

                  // Date Picker shown if sync type is specified date
                  AnimatedContainer(
                    height: _syncType == SyncType.specifiedDate ? 80 : 0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: ClipRRect(
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final DateTime pickedDate = await showDatePicker(
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
                            child: Text(localisations.selectDate),
                          ),
                          // Display the selected date
                          Text(
                            '${localisations.startDate}: '
                            "${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (settingsBloc.enableTestCoins)
                    RadioListTile<SyncType>(
                      title: Text(localisations.syncFromSaplingActivation),
                      value: SyncType.fullSync,
                      groupValue: _syncType,
                      onChanged: (SyncType value) {
                        setState(() {
                          _syncType = value;
                        });
                      },
                    ),

                  SizedBox(height: 16),
                  // Sync Type Description
                  if (_syncType == SyncType.newTransactions)
                    Text(localisations.futureTransactions),

                  if (_syncType == SyncType.fullSync)
                    Text(localisations.allPastTransactions),

                  if (_syncType == SyncType.specifiedDate)
                    Text(localisations.pastTransactionsFromDate),

                  if (Platform.isIOS) ...[
                    SizedBox(height: 16),
                    Text(
                      localisations.minimizingWillTerminate,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: Colors.amber),
                    ),
                  ],
                  if (_syncType == SyncType.fullSync ||
                      _syncType == SyncType.specifiedDate)
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
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Colors.amber,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(localisations.willTakeTime),
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
                child: Text(localisations.cancelButton),
              ),
              TextButton(
                onPressed: () => Navigator.pop<Map<String, dynamic>>(
                  context,
                  {
                    'zhtlcSyncType': _syncType,
                    'zhtlcSyncStartDate': _selectedDate
                  },
                ),
                child: Text(localisations.confirm),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _showInProgressDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return BlocConsumer<ZCoinActivationBloc, ZCoinActivationState>(
        listener: (context, state) {
          final progressState = state.asProgressOrNull();

          if (progressState == null || progressState.progress >= 1) {
            Navigator.of(context, rootNavigator: true).maybePop();
          }
        },
        listenWhen: (previous, current) => previous != current,
        builder: (context, s) {
          final state = s.asProgressOrNull();

          if (state == null || state.progress >= 1) {
            Navigator.of(context, rootNavigator: true).maybePop();
            return Container();
          }

          final localisations = AppLocalizations.of(context);

          final etaString = state?.eta?.inMinutes != null
              ? '${state.eta.inMinutes}${localisations.minutes}'
              : kDebugMode
                  ? '¯\\_(ツ)_/¯'
                  : null;
          return AlertDialog(
            title: Text(
              '${localisations.warning}: '
              '${localisations.activationInProgress(localisations.tagZHTLC)}',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!ZCoinProgressNotifications.canNotify) ...[
                  Text(
                    localisations.enableNotificationsForActivationProgress,
                    style: TextStyle(color: Colors.amber),
                  ),
                  SizedBox(height: 16),
                ],
                Text(localisations.willTakeTime),
                SizedBox(height: 16),
                if (etaString != null) ...[
                  Text('${localisations.rewardsTableTime}: $etaString'),
                  SizedBox(height: 16),
                ],
                Text(
                  '${localisations.swapProgress}: ${(state.progress * 100).round()}%',
                ),
                SizedBox(height: 8),
                AnimatedLinearProgressIndicator(
                  key: Key('z_coin_status_linear_progress_indicator'),
                  value: state.progress,
                ),
              ],
            ),
            actions: [
              if (!state.isResync)
                TextButton(
                  onPressed: () =>
                      _showConfirmCancelActivationDialog(context).ignore(),
                  child: Text(
                    localisations.cancelActivation,
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(color: Theme.of(context).errorColor),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localisations.close),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<bool> _showConfirmCancelActivationDialog(BuildContext context) async {
  final localisations = AppLocalizations.of(context);

  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localisations.cancelActivation),
        content: Text(localisations.cancelActivationQuestion),
        actions: <Widget>[
          TextButton(
            child: Text(localisations.close),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          ElevatedButton(
            child: Text(localisations.confirm),
            onPressed: () {
              context
                  .read<ZCoinActivationBloc>()
                  .add(ZCoinActivationCancelRequested());
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}
