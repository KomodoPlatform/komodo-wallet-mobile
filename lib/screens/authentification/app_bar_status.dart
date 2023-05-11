import 'package:flutter/material.dart';
import '../../generic_blocs/authenticate_bloc.dart';
import '../authentification/logout_confirmation.dart';

class AppBarStatus extends StatelessWidget {
  AppBarStatus({
    Key? key,
    required this.pinStatus,
    required this.context,
    required this.title,
  }) : super(key: key);

  final PinStatus? pinStatus;
  final BuildContext context;
  final String? title;

  @override
  Widget build(BuildContext context) {
    switch (pinStatus) {
      case PinStatus.CREATE_PIN:
      case PinStatus.CHANGE_PIN:
      case PinStatus.CONFIRM_PIN:
      case PinStatus.CREATE_CAMO_PIN:
      case PinStatus.CONFIRM_CAMO_PIN:
        return AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onBackground,
          title: Text(title!),
        );
        break;
      default:
        return AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onBackground,
          automaticallyImplyLeading: pinStatus != PinStatus.NORMAL_PIN,
          actions: <Widget>[
            IconButton(
              key: Key('settings-pin-logout'),
              onPressed: () => showLogoutConfirmation(context),
              color: Theme.of(context).errorColor,
              icon: Icon(Icons.exit_to_app),
              splashRadius: 24,
            ),
          ],
          title: Text(title!),
        );
    }
  }
}
