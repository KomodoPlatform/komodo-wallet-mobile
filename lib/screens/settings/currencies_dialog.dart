import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:provider/provider.dart';

void showCurrenciesDialog(BuildContext context) {
  final CexProvider cexProvider =
      Provider.of<CexProvider>(context, listen: false);
  final String current = cexProvider.selectedFiat;
  final List<String> available = cexProvider.fiatList;
  if (available == null || available.isEmpty) return;

  const List<String> primary = ['usd', 'eur', 'gbp', 'cny', 'rub', 'try'];

  final List<String> sorted = List.from(available);
  sorted.sort((String a, String b) {
    for (String curr in primary) {
      if (a == curr && b != curr) return -1;
      if (b == curr && a != curr) return 1;
    }

    return a.compareTo(b);
  });

  final List<Widget> options = [];
  for (String currency in sorted) {
    options.add(SimpleDialogOption(
      onPressed: () {
        cexProvider.selectedFiat = currency;
        dialogBloc.closeDialog(context);
      },
      child: Text(
        currency.toUpperCase(),
        style: TextStyle(
          color: currency == current ? Theme.of(context).accentColor : null,
        ),
      ),
    ));
  }

  dialogBloc.dialog = showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Currency'), // TODO(yurii): localization
          contentPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
          ),
          titlePadding: const EdgeInsets.all(20),
          children: <Widget>[
            ...options,
          ],
        );
      });
}
