import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/widgets/confirmation_dialog.dart';

void showLogoutConfirmation(BuildContext context) {
  showConfirmationDialog(
    context: context,
    title: AppLocalizations.of(context).logout,
    message:
        'Are you sure you want to logout now?', // TODO(yurii): localization
    confirmButtonText: AppLocalizations.of(context).logout,
    icon: Icons.exit_to_app,
    onConfirm: () async {
      await authBloc.logout();
    },
  );
}
