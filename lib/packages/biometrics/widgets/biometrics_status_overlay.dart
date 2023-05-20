import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/packages/biometrics/bloc/biometrics_status_bloc.dart';
import 'package:komodo_dex/packages/biometrics/event/biometrics_status_event.dart';
import 'package:komodo_dex/packages/biometrics/repository/biometrics_status_repository.dart';
import 'package:komodo_dex/packages/biometrics/state/biometrics_status_state.dart';

class BiometricsStatusOverlay extends StatefulWidget {
  final Widget child;

  const BiometricsStatusOverlay({Key? key, required this.child})
      : super(key: key);

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
          return Stack(
            children: <Widget>[
              widget.child,
              if (true ||
                  state is BiometricsStatusNotSupported ||
                  state is BiometricsNotEnrolled ||
                  state is BiometricsStatusNotAuthenticated)
                Container(
                  color:
                      Theme.of(context).colorScheme.background.withOpacity(0.5),
                  child: Center(
                    child: AlertDialog(
                      title: Text('Biometrics issue'),
                      content: Text(
                        _getMessageForState(state),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // TODO: Localize messages.
  String _getMessageForState(BiometricsStatusState state) {
    // return ;
    // final localizations = MaterialLocalizations.of(context);

    // return localizations.bottomSheetLabel;
    if (state is BiometricsStatusNotSupported) {
      return state.message;
    } else if (state is BiometricsNotEnrolled) {
      return state.message;
    } else if (state is BiometricsStatusNotAuthenticated) {
      return state.message;
    } else {
      return '';
    }
  }
}
