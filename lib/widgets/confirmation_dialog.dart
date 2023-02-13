import 'package:flutter/material.dart';
import '../generic_blocs/dialog_bloc.dart';
import '../localizations.dart';
import '../utils/utils.dart';
import '../widgets/custom_simple_dialog.dart';

void showConfirmationDialog({
  required BuildContext context,
  String? title,
  IconData icon = Icons.warning,
  Color? iconColor,
  String? message,
  Function? onConfirm,
  String? confirmButtonText,
  Key? key,
}) {
  title ??= AppLocalizations.of(context)!.confirm;
  confirmButtonText ??= AppLocalizations.of(context)!.confirm;
  message ??=
      toInitialUpper(AppLocalizations.of(context)!.areYouSure.toLowerCase());
  dialogBloc.dialog = showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CustomSimpleDialog(
          title: Row(
            children: <Widget>[
              Icon(
                icon,
                color: iconColor ?? Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Text(title!),
            ],
          ),
          children: <Widget>[
            Text(message!),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => dialogBloc.closeDialog(context),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  key: key ?? const Key('confirm-button-key'),
                  onPressed: () {
                    dialogBloc.closeDialog(context);
                    if (onConfirm != null) onConfirm();
                  },
                  child: Text(
                    confirmButtonText!,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        );
      }).then((dynamic _) => dialogBloc.dialog = null);
}
