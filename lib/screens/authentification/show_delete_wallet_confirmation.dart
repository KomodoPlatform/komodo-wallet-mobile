import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';

Future<void> showDeleteWalletConfirmation(BuildContext context,
    {Wallet wallet, String password}) async {
  wallet ??= walletBloc.currentWallet;

  dialogBloc.dialog = showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        bool loading = false;

        return CustomSimpleDialog(
          title: Column(
            children: <Widget>[
              SvgPicture.asset('assets/svg/delete_wallet.svg'),
              const SizedBox(
                height: 16,
              ),
              Text(
                AppLocalizations.of(context).deleteWallet.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Theme.of(context).errorColor),
              ),
              const SizedBox(
                height: 24,
              ),
            ],
          ),
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: <InlineSpan>[
                TextSpan(
                    text: AppLocalizations.of(context).settingDialogSpan1,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withOpacity(0.8))),
                TextSpan(
                    text: walletBloc.currentWallet.name,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withOpacity(0.8),
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: AppLocalizations.of(context).settingDialogSpan2,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withOpacity(0.8))),
              ]),
            ),
            const SizedBox(
              height: 16,
            ),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: <InlineSpan>[
                  TextSpan(
                      text: AppLocalizations.of(context).settingDialogSpan3,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .color
                              .withOpacity(0.8))),
                  TextSpan(
                      text: AppLocalizations.of(context).settingDialogSpan4,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .color
                              .withOpacity(0.8),
                          fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: AppLocalizations.of(context).settingDialogSpan5,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .color
                              .withOpacity(0.8))),
                ]),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            StatefulBuilder(builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text(AppLocalizations.of(context).cancel),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (loading) ...{
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                        },
                        Text(AppLocalizations.of(context).delete),
                      ],
                    ),
                    key: const Key('delete-wallet'),
                    onPressed: loading
                        ? null
                        : () async {
                            setState(() => loading = true);
                            await walletBloc.deleteSeedPhrase(password, wallet);
                            await walletBloc.deleteWallet(wallet);
                            await walletBloc.getWalletsSaved();

                            Navigator.of(context).pop();
                          },
                  )
                ],
              );
            }),
          ],
        );
      }).then((dynamic _) {
    dialogBloc.dialog = null;
  });
}
