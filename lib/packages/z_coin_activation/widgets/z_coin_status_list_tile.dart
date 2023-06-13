import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_bloc.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_event.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_state.dart';

class ZCoinStatusListTile extends StatelessWidget {
  const ZCoinStatusListTile({Key key}) : super(key: key);

// class _SetupZcoinButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ZCoinActivationBloc, ZCoinActivationState>(
      listener: (context, state) {
        if (state is ZCoinActivationFailure) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(content: Text('Activation Failed: ${state.message}')),
            );
        }
      },
      builder: (context, state) {
        bool coinActivated = state is ZCoinActivationSuccess;
        bool isActivationInProgress = state is ZCoinActivationInProgess;

        if (isActivationInProgress) {
          final progressState = state as ZCoinActivationInProgess;
          return ListTile(
            onTap: () => _showInProgressDialog(context),
            title: Text('ZHTLC Activating'),
            subtitle: Text(
              progressState.message != null && progressState.message.isNotEmpty
                  ? '${progressState.message}. Do not close the app.'
                  : 'This will take a while and the app must be kept in the '
                      'foreground. Terminating the app while activation is in '
                      'progress could lead to issues.',
            ),
            leading: Icon(
              Icons.warning,
              color: Colors.red,
            ),
            tileColor: Theme.of(context).primaryColor,
            trailing: SizedBox(
                child: CircularProgressIndicator(
              value:
                  progressState.progress < 0.1 ? null : progressState.progress,
            )),
          );
        }

        final bool isStatusLoading = state is ZCoinActivationStatusLoading;

        return SwitchListTile(
          title: Text('Enable ZCoin (ZHTLC)'),
          tileColor: Theme.of(context).primaryColor,
          value: coinActivated,
          selected: false,
          onChanged: isStatusLoading || coinActivated
              ? null
              : (bool switchValue) async {
                  if (switchValue) {
                    showDialog<void>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Activate ZHTLC coins?'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          content: Text(
                              'This will take a while and the app must be kept in the foreground. '
                              'Terminating the app while activation is in progress could lead to issues.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context
                                    .read<ZCoinActivationBloc>()
                                    .add(ZCoinActivationRequested());
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    //TODO: Handle case where user wants to deactivate ZCoin
                  }
                },
        );
      },
    );
  }

  void _showInProgressDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Warning: ZHLTC Activation in Progress'),
          content: Text(
            'This will take a while and the app must be kept in the foreground.'
            'Closing the app while activation is in progress could lead to issues.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).close),
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
}
