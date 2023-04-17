import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/login/models/pin_type.dart';
import 'package:komodo_dex/packages/pin_reset/bloc/pin_reset_bloc.dart';
import 'package:komodo_dex/packages/pin_reset/state/pin_reset_state.dart';
import 'package:komodo_dex/packages/pin_reset/widgets/pin_reset_form.dart';

class PinResetPage extends StatefulWidget {
  const PinResetPage({Key? key}) : super(key: key);

  @override
  _PinResetPageState createState() => _PinResetPageState();
}

class _PinResetPageState extends State<PinResetPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PinResetBloc, PinResetState>(
      builder: (context, state) {
        final appBarTitleText =
            _getPinResetAppBarTitle(state.currentStep, state.pinType);

        return Scaffold(
          appBar: AppBar(title: Text(appBarTitleText)),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: PinResetForm(),
          ),
        );
      },
    );
  }

  String _getPinResetAppBarTitle(
      PinResetStep currentStep, PinTypeName pinType) {
    final localizations = AppLocalizations.of(context)!;

    // TODO(@ologunB): Please implement this method to determine the appropriate
    // AppBar title based on the current step and pin type name

    return 'PLACEHOLDER!';
  }
}
