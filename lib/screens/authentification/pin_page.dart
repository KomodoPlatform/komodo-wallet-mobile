import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:komodo_dex/login/bloc/login_bloc.dart';
import 'package:komodo_dex/widgets/pin/pin_input.dart';
import 'package:provider/provider.dart';

import '../../generic_blocs/authenticate_bloc.dart';
import '../../generic_blocs/dialog_bloc.dart';
import '../../localizations.dart';
import '../authentification/app_bar_status.dart';

class PinPage extends StatefulWidget {
  const PinPage({
    Key? key,
    this.title,
    this.subTitle,
    this.pinStatus,
    this.isFromChangingPin = false,
    this.password,
    this.onSuccess,
    this.code,
  }) : super(key: key);

  @required
  final String? title;
  @required
  final String? subTitle;
  @required
  final PinStatus? pinStatus;
  final String? code;
  final bool isFromChangingPin;
  final String? password;
  final VoidCallback? onSuccess;

  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  bool _isLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.pinStatus == PinStatus.NORMAL_PIN) {
        dialogBloc.closeDialog(context);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isBlocLoading = context.watch<LoginBloc>().state.status ==
        FormzStatus.submissionInProgress;

    return Scaffold(
      appBar: !_isLoading
          ? AppBarStatus(
              pinStatus: widget.pinStatus,
              title: widget.title,
              context: context,
            )
          : null,
      resizeToAvoidBottomInset: false,
      body: !_isLoading
          ? Center(
              child: PinInput(
                obscureText: true,
                length: 6,
                readOnly: isBlocLoading || _isLoading,
                value: context.watch<LoginBloc>().state.pin!.value,
                onChanged: (String pin) => context.read<LoginBloc>().add(
                      LoginPinInputChanged(pin),
                    ),
                onPinComplete: (String pin) => context.read<LoginBloc>().add(
                      LoginPinSubmitted(
                          widget.password,
                          pin,
                          widget.isFromChangingPin,
                          widget.onSuccess,
                          widget.pinStatus),
                    ),
              ),
            )
          : _buildLoading(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            color: Theme.of(context).errorColor,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(AppLocalizations.of(context)!.configureWallet)
        ],
      ),
    );
  }
}
