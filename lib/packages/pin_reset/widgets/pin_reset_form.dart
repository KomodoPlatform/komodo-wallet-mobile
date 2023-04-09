import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/packages/pin_reset/bloc/pin_reset_bloc.dart';
import 'package:komodo_dex/packages/pin_reset/events/index.dart';
import 'package:komodo_dex/packages/pin_reset/state/pin_reset_state.dart';
import 'package:komodo_dex/widgets/pin/pin_input.dart';

class PinResetForm extends StatelessWidget {
  const PinResetForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PinResetBloc, PinResetState>(
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PinInput(
              key: Key('pin-reset-form-pinInput-${state.currentStep.index}'),
              value: state.getCurrentStepPin.value,
              length: state.getCurrentStepPin.requiredLength,
              readOnly: state.isLoading,
              obscureText: true,
              onChanged: (value) =>
                  context.read<PinResetBloc>().add(PinResetPinChanged(value)),
              onPinComplete: (value) =>
                  context.read<PinResetBloc>().add(const PinResetSubmitted()),
              errorMessage: state.isError ? state.errorMessage : null,
              errorState: state.isError,
            ),
          ],
        );
      },
    );
  }
}
