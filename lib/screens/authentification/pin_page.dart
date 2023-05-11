import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:komodo_dex/login/bloc/login_bloc.dart';
import 'package:komodo_dex/widgets/pin/pin_input.dart';

import '../../generic_blocs/authenticate_bloc.dart';
import '../../generic_blocs/dialog_bloc.dart';
import '../../localizations.dart';
import '../../widgets/page_transition.dart';
import '../authentification/app_bar_status.dart';

@deprecated
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
  // @required
  final PinStatus? pinStatus;
  final String? code;
  final bool isFromChangingPin;
  final String? password;
  final VoidCallback? onSuccess;

  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  late LoginBloc _loginBloc;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.pinStatus == PinStatus.NORMAL_PIN) {
        dialogBloc.closeDialog(context);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _loginBloc = BlocProvider.of<LoginBloc>(context, listen: true);

    final isBlocLoading = _loginBloc.state.isLoading;

    return Scaffold(
      appBar: !isBlocLoading
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: AppBarStatus(
                // pinStatus: widget.pinStatus,
                pinStatus: null,
                title: widget.title,
                context: context,
              ),
            )
          : null,
      resizeToAvoidBottomInset: false,
      body: BlocListener<LoginBloc, LoginState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus,
        listener: (context, state) {
          if (state is LoginStatePinSubmittedFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.errorTryAgain),
              ),
            );
          }
        },
        child: _loginBloc.state.isLoading
            ? _buildLoading()
            : Center(
                child: PinInput(
                  obscureText: true,
                  length: 6,
                  readOnly: isBlocLoading,
                  value: context.watch<LoginBloc>().state.pin!.value,
                  onChanged: (String pin) => context.read<LoginBloc>().add(
                        LoginPinInputChanged(pin),
                      ),
                  onPinComplete: (String pin) => context.read<LoginBloc>().add(
                        LoginPinSubmitted(pin),
                      ),
                ),
              ),
      ),
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

  void uiCodeSuccess() {
    switch (widget.pinStatus) {
      case PinStatus.NORMAL_PIN:
        break;
      case PinStatus.CHANGE_PIN:
        break;
      case PinStatus.CREATE_PIN:
        break;
      case PinStatus.CREATE_CAMO_PIN:
        break;
      case PinStatus.CONFIRM_PIN:
        Navigator.pop(context);
        break;
      case PinStatus.CONFIRM_CAMO_PIN:
        Navigator.popUntil(context, ModalRoute.withName('/camoSetup'));
        break;
      case PinStatus.DISABLED_PIN:
        Navigator.pop(context);
        break;
      case PinStatus.DISABLED_PIN_BIOMETRIC:
        Navigator.pop(context);
        break;
      default:
        break;
    }
  }

  void uiCodeFail() {
    print(300003);
    switch (widget.pinStatus) {
      case PinStatus.CREATE_PIN:
        final materialPage = PageTransition(
          child: PinPage(
            title: AppLocalizations.of(context)!.confirmPin,
            subTitle: AppLocalizations.of(context)!.confirmPin,
            pinStatus: PinStatus.CONFIRM_PIN,
            password: widget.password,
          ),
        );

        Navigator.push<dynamic>(context, materialPage);
        break;

      case PinStatus.CHANGE_PIN:
        final materialPage = PageTransition(
            child: PinPage(
          title: AppLocalizations.of(context)!.confirmPin,
          subTitle: AppLocalizations.of(context)!.confirmPin,
          pinStatus: PinStatus.CONFIRM_PIN,
          password: widget.password,
          isFromChangingPin: true,
        ));

        Navigator.pushReplacement<dynamic, dynamic>(context, materialPage);
        break;

      case PinStatus.CREATE_CAMO_PIN:
        final materialPage = PageTransition(
            child: PinPage(
          title: AppLocalizations.of(context)!.camouflageSetup,
          subTitle: AppLocalizations.of(context)!.confirmCamouflageSetup,
          onSuccess: widget.onSuccess,
          pinStatus: PinStatus.CONFIRM_CAMO_PIN,
          password: widget.password,
        ));

        Navigator.pushReplacement<dynamic, dynamic>(context, materialPage);
        break;

      default:
        Navigator.popUntil(context, ModalRoute.withName('/'));

        break;
    }
  }
}
