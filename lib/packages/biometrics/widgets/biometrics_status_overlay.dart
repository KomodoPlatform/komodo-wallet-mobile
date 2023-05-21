import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/packages/biometrics/bloc/biometrics_status_bloc.dart';
import 'package:komodo_dex/packages/biometrics/event/biometrics_status_event.dart';
import 'package:komodo_dex/packages/biometrics/repository/biometrics_status_repository.dart';
import 'package:komodo_dex/packages/biometrics/state/biometrics_status_state.dart';

class BiometricsStatusOverlay extends StatefulWidget {
  const BiometricsStatusOverlay({Key? key}) : super(key: key);

  @override
  State<BiometricsStatusOverlay> createState() =>
      _BiometricsStatusOverlayState();
}

class _BiometricsStatusOverlayState extends State<BiometricsStatusOverlay> {
  final BiometricsStatusBloc _biometricsStatusBloc = BiometricsStatusBloc(
    BiometricsStatusRepository(),
  );

  @override
  void initState() {
    super.initState();
    _biometricsStatusBloc.add(BiometricsStatusSubscriptionRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _biometricsStatusBloc,
      child: BlocBuilder<BiometricsStatusBloc, BiometricsStatusState>(
        builder: (context, state) {
          final shouldShowOverlay = state is BiometricsStatusNotSupported ||
              state is BiometricsNotEnrolled ||
              state is BiometricsStatusNotAuthenticated;
          return !shouldShowOverlay
              ? SizedBox()
              : Container(
                  height: double.infinity,
                  width: double.infinity,
                  color:
                      Theme.of(context).colorScheme.background.withOpacity(0.5),
                  child: Center(
                    child: AlertDialog(
                      title: Text(_titleForState(state)),
                      content: Text(_getMessageForState(state)),
                    ),
                  ),
                );
        },
      ),
    );
  }

  String _titleForState(BiometricsStatusState state) {
    if (state is BiometricsStatusNotSupported) {
      return 'Biometrics not supported';
    } else if (state is BiometricsNotEnrolled) {
      return 'Biometrics not set up';
    } else if (state is BiometricsStatusNotAuthenticated) {
      return 'Biometrics not authenticated';
    } else {
      return '';
    }
  }

  // TODO: Localize messages.
  String _getMessageForState(BiometricsStatusState state) {
    if (state is BiometricsStatusNotSupported) {
      return "Your device doesn't support biometrics.\n\nAtomicDEX Mobile"
          " requires biometrics to securely store your data in your device's"
          ' credential storage.\n\nPlease use a device that supports biometrics.';
    } else if (state is BiometricsNotEnrolled) {
      return "You haven't set up biometrics on your device.\n\nAtomicDEX Mobile"
          " requires biometrics to securely store your data in your device's"
          ' credential storage.\n\nPlease set up biometrics on your device.';
    } else if (state is BiometricsStatusNotAuthenticated) {
      return "You are not authenticated with your device's biometrics.\n"
          ' AtomicDEX Mobile requires biometrics to securely access your data'
          " in your device's credential storage.\n\nPlease lock and unlock your"
          ' device';
    } else {
      return '';
    }
  }
}
