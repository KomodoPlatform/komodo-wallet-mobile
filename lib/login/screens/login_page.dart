import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komodo_dex/login/bloc/login_bloc.dart';
import 'package:komodo_dex/widgets/background_gradient.dart';
import 'package:komodo_dex/widgets/pin/pin_input.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../generic_blocs/dialog_bloc.dart';
import '../../localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  static const String routeName = '/login';

  static MaterialPageRoute<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const LoginPage(),
    );
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();

    _loginBloc = BlocProvider.of<LoginBloc>(context);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // if (_loginBloc.pinStatus == PinStatus.NORMAL_PIN) {
      dialogBloc.closeDialog(context);
      // }
    });
  }

  // Clear bloc persistence when navigating away from this page.
  @override
  void dispose() {
    _loginBloc.add(LoginClear());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loginBloc = BlocProvider.of<LoginBloc>(context, listen: true);

    final isBlocLoading = _loginBloc.state.isLoading;

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersive,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        child: SafeArea(
          child: BlocListener<LoginBloc, LoginStateAbstract>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus,
            listener: (context, state) {
              if (state is LoginStatePinSubmittedFailure) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text(AppLocalizations.of(context)!.errorTryAgain),
                //   ),
                // );
              }

              if (state is LoginStatePinSubmittedSuccess) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text(AppLocalizations.of(context)!.success),
                //   ),
                // );
                // Navigator.of(context)
                //     .pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Text(
                  (isBlocLoading
                          ? AppLocalizations.of(context)!.loading
                          : AppLocalizations.of(context)!.enterPinCode)
                      .toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w400,
                    fontSize: 32,
                    height: 1.5,
                    letterSpacing: 2,
                    wordSpacing: 6,
                  ),
                ),
                Spacer(),
                PinInput(
                  errorState: _loginBloc.state.isError,
                  errorMessage: _loginBloc.state.error,
                  obscureText: true,
                  length: 6,
                  readOnly: isBlocLoading,
                  value: context.watch<LoginBloc>().state.pin.value,
                  onChanged: (String pin) => _loginBloc.add(
                    LoginPinInputChanged(pin),
                  ),
                  onPinComplete: (String pin) => _loginBloc.add(
                    LoginPinSubmitted(pin),
                  ),
                ),
                Spacer(),
              ],
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
            color: Theme.of(context).colorScheme.error,
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
