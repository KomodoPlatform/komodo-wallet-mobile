import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_bloc.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_event.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_state.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_notifications.dart';
import 'package:komodo_dex/packages/z_coin_activation/widgets/rotating_progress_indicator.dart';
import 'package:komodo_dex/services/mm_service.dart';

class ZCoinStatusWidget extends StatefulWidget {
  const ZCoinStatusWidget({Key key}) : super(key: key);

  static BlocListenerCondition<ZCoinActivationState> get listenWhen =>
      (previous, current) =>
          previous.runtimeType != current.runtimeType &&
          current is! ZCoinActivationInitial;

  static BlocWidgetListener get listener =>
      (context, state) => _ZCoinStatusWidgetState.listener(context, state);

  static Future<bool> Function(BuildContext) get showConfirmationDialog =>
      _showConfirmationDialog;

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
            title: Text(AppLocalizations.of(context).activating('ZHTLC')),
            subtitle: Text(
                AppLocalizations.of(context).doNotCloseTheAppTapForMoreInfo),
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
          title: Text(AppLocalizations.of(context).activation('ZCoin (ZHTLC)')),
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
                      ? AppLocalizations.of(context).coinsAreActivated('ZHTLC')
                      : AppLocalizations.of(context)
                          .coinsAreNotActivated('ZHTLC'),
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

      String message;
      switch (state.reason) {
        case ZCoinActivationFailureReason.FailedToActivateCoins:
          message = AppLocalizations.of(context).failedToActivateCoins;
          break;
        case ZCoinActivationFailureReason.FailedToStartActivation:
          message = AppLocalizations.of(context).failedToStartActivation;
          break;
        case ZCoinActivationFailureReason.FailedToSetRequestedCoins:
          message = AppLocalizations.of(context).failedToSetRequestedCoins;
          break;
        case ZCoinActivationFailureReason.FailedToGetActivationStatus:
          message = AppLocalizations.of(context).failedToGetActivationStatus;
          break;
      }

      updateNotice = scaffold.showMaterialBanner(
        MaterialBanner(
          elevation: 1,
          content: Text(message),
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
          content: Text(AppLocalizations.of(context)
              .coinsAreActivatedSuccessfully('ZHTLC')),
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
                  Text(AppLocalizations.of(context)
                      .activationInProgress('ZHTLC')),
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
                  child: Text(AppLocalizations.of(context).moreInfo),
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

Future<bool> _showConfirmationDialog(BuildContext context) {
  final appL10n = AppLocalizations.of(context);

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context).activateCoins('ZHTLC')),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        content: Column(
          children: [
            Text(AppLocalizations.of(context).willTakeTime),
            if (Platform.isIOS) ...[
              SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  Icons.warning,
                  color: Colors.amber,
                ),
                dense: true,
                title: Text(
                  AppLocalizations.of(context).minimizingWillTerminate,
                  style: TextStyle(color: Colors.amber),
                ),
              )
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop<bool>(context, false),
            child: Text(appL10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop<bool>(context, true),
            child: Text(appL10n.confirm),
          ),
        ],
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
        title: Text(
            '${appL10n.warning}: ${AppLocalizations.of(context).activationInProgress('ZHTLC')}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!ZCoinProgressNotifications.canNotify) ...[
              Text(
                AppLocalizations.of(context)
                    .enableNotificationsForActivationProgress,
                style: TextStyle(color: Colors.amber),
              ),
              SizedBox(height: 16),
            ],
            Text(AppLocalizations.of(context).willTakeTime),
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
