import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/dex/trade/pro/create/trade_form.dart';
import 'package:komodo_dex/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

void showLogoutConfirmation(BuildContext mContext) {
  final context = mContext;

  showConfirmationDialog(
    context: context,
    title: AppLocalizations.of(context).logout,
    message: AppLocalizations.of(context).logoutWarning,
    confirmButtonText: AppLocalizations.of(context).logout,
    icon: Icons.exit_to_app,
    iconColor: Theme.of(context).errorColor,
    key: const Key('settings-logout-yes'),
    onConfirm: () async {
      Provider.of<MultiOrderProvider>(mContext, listen: false).reset();
      Provider.of<ConstructorProvider>(mContext, listen: false).reset();
      tradeForm.reset();

      await authBloc.logout();
    },
  );
}
