import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/screens/authentification/logout_confirmation.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:pin_code_view/pin_code_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinPage extends StatefulWidget {
  const PinPage(
      {this.firstCreationPin,
      this.title,
      this.subTitle,
      this.pinStatus,
      this.isFromChangingPin,
      this.password,
      this.onSuccess,
      this.code});

  final bool firstCreationPin;
  @required
  final String title;
  @required
  final String subTitle;
  @required
  final PinStatus pinStatus;
  final String code;
  final bool isFromChangingPin;
  final String password;
  final VoidCallback onSuccess;

  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  String _error = '';
  bool isLoading = false;
  String _correctPin;

  @override
  void initState() {
    _initCorrectPin(widget.pinStatus);
    super.initState();
  }

  Future<void> setNormalPin() async {
    final String normalPin = await EncryptionTool().read('pin');
    setState(() {
      _correctPin = normalPin;
    });
  }

  Future<void> _initCorrectPin(PinStatus pinStatus) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (pinStatus == PinStatus.CREATE_PIN) {
      setState(() {
        _correctPin = null;
      });
    } else if (pinStatus == PinStatus.CONFIRM_PIN) {
      authBloc.showLock = false;
      setState(() {
        _correctPin = prefs.getString('pin_create');
      });
    } else {
      await setNormalPin();
    }
  }

  Future<void> _onCodeSuccess(PinStatus pinStatus, String code) async {
    switch (pinStatus) {
      case PinStatus.CREATE_PIN:
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isPinIsCreated', true);
        break;
      case PinStatus.CONFIRM_PIN:
        final Wallet wallet = await Db.getCurrentWallet();
        setState(() {
          isLoading = true;
        });
        if (wallet != null) {
          await EncryptionTool()
              .writeData(
                  KeyEncryption.PIN, wallet, widget.password, code.toString())
              .catchError((dynamic e) => Log.println('pin_page:90', e));
        }

        await EncryptionTool().write('pin', code.toString());
        authBloc.showLock = false;
        authBloc.updateStatusPin(PinStatus.NORMAL_PIN);
        if (!widget.isFromChangingPin) {
          if (!mmSe.running) {
            await authBloc.login(
                await EncryptionTool().read('passphrase'), widget.password);
          }
        } else {
          Navigator.pop(context);
        }
        Navigator.pop(context);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isPinIsCreated', false);

        setState(() {
          isLoading = false;
        });

        break;
      case PinStatus.NORMAL_PIN:
        authBloc.showLock = false;
        if (!mmSe.running) {
          await authBloc.login(await EncryptionTool().read('passphrase'), null);
        }
        if (widget.onSuccess != null) {
          widget.onSuccess();
        }

        break;
      case PinStatus.DISABLED_PIN:
        SharedPreferences.getInstance().then((SharedPreferences data) {
          data.setBool('switch_pin', false);
        });
        Navigator.pop(context);
        break;
      case PinStatus.DISABLED_PIN_BIOMETRIC:
        SharedPreferences.getInstance().then((SharedPreferences data) {
          data.setBool('switch_pin_biometric', false);
        });
        Navigator.pop(context);
        break;
      case PinStatus.CHANGE_PIN:
        Navigator.pushReplacement<dynamic, dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => PinPage(
                      title: AppLocalizations.of(context).createPin,
                      subTitle: AppLocalizations.of(context).enterNewPinCode,
                      pinStatus: PinStatus.CREATE_PIN,
                      password: widget.password,
                      isFromChangingPin: true,
                    )));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !isLoading
          ? AppBarStatus(
              pinStatus: widget.pinStatus,
              title: widget.title,
              context: context,
            )
          : null,
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomPadding: false,
      body: !isLoading
          ? PinCode(
              title: Text(
                widget.subTitle,
                style: Theme.of(context).textTheme.subtitle,
              ),
              subTitle: const Text(
                '',
              ),
              obscurePin: true,
              error: _error,
              errorDelaySeconds:
                  widget.pinStatus == PinStatus.NORMAL_PIN ? 5 : null,
              codeLength: 6,
              correctPin: _correctPin,
              onCodeFail: (dynamic code) async {
                if (widget.pinStatus == PinStatus.CREATE_PIN) {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('isPinIsCreated', true);
                  await prefs.setString('pin_create', code);
                  final MaterialPageRoute<dynamic> materialPage =
                      MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => PinPage(
                                title: AppLocalizations.of(context).confirmPin,
                                subTitle:
                                    AppLocalizations.of(context).confirmPin,
                                code: code,
                                pinStatus: PinStatus.CONFIRM_PIN,
                                password: widget.password,
                                isFromChangingPin: widget.isFromChangingPin,
                              ));

                  if (widget.firstCreationPin != null &&
                      widget.firstCreationPin) {
                    Navigator.push<dynamic>(context, materialPage);
                  } else {
                    Navigator.pushReplacement<dynamic, dynamic>(
                        context, materialPage);
                  }
                } else {
                  _errorPin();
                }
              },
              onCodeSuccess: (dynamic code) {
                _onCodeSuccess(widget.pinStatus, code);
              },
            )
          : _buildLoading(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(
            height: 8,
          ),
          Text(AppLocalizations.of(context).configureWallet)
        ],
      ),
    );
  }

  void _errorPin() {
    setState(() {
      _error = AppLocalizations.of(context).errorTryAgain;
    });
  }
}

class AppBarStatus extends StatelessWidget with PreferredSizeWidget {
  AppBarStatus(
      {Key key,
      @required this.pinStatus,
      @required this.context,
      @required this.title})
      : super(key: key);

  final PinStatus pinStatus;
  final BuildContext context;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (!(pinStatus == PinStatus.CONFIRM_PIN)) {
      return AppBar(
        centerTitle: true,
        leading: InkWell(
            onTap: () async {
              await showLogoutConfirmation(context);
            },
            child: Icon(
              Icons.exit_to_app,
              color: Colors.red,
            )),
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(title),
        elevation: 0,
      );
    } else {
      return AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(title),
      );
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
