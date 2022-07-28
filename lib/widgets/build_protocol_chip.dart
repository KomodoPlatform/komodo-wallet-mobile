import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_type.dart';

class BuildProtocolChip extends StatelessWidget {
  const BuildProtocolChip(this.coin, {Key key}) : super(key: key);

  final Coin coin;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> labels = _getProtocolChipLabels(context);

    final BoxDecoration decoration = BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      color: const Color.fromRGBO(20, 117, 186, 1),
    );
    final TextStyle style =
        Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.white);

    Widget chip;

    switch (coin.type) {
      case CoinType.utxo:
        chip = const SizedBox.shrink();
        break;

      case CoinType.erc:
      case CoinType.qrc:
      case CoinType.bep:
      case CoinType.plg:
      case CoinType.ubq:
      case CoinType.hrc:
      case CoinType.ftm:
        chip = Container(
          decoration: decoration,
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Row(
            children: <Widget>[
              Text(
                labels[coin.type.name] ?? coin.type.name.toUpperCase(),
                style: style,
              ),
            ],
          ),
        );
        break;

      case CoinType.smartChain:
        chip = coin.abbr == 'KMD'
            ? const SizedBox.shrink()
            : InkWell(
                onTap: () {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 2),
                        content: Text('Built on Komodo'),
                      ),
                    );
                  } catch (_) {}
                },
                child: Container(
                  decoration: decoration.copyWith(
                      color: Theme.of(context).scaffoldBackgroundColor),
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Image.asset(
                    'assets/coin-icons/kmd.png',
                    width: 18,
                    height: 18,
                  ),
                ),
              );
        break;
    }

    return chip;
  }

  Map<String, String> _getProtocolChipLabels(BuildContext context) {
    final Map<String, String> labels = {};

    for (CoinType type in CoinType.values) {
      String label;

      switch (type) {
        // UTXO's dont have any chip.
        // Smart chains have dedicated chip with icon.
        case CoinType.utxo:
        case CoinType.smartChain:
          break;
        case CoinType.bep:
          label = AppLocalizations.of(context).tagBEP20;
          break;
        case CoinType.erc:
          label = AppLocalizations.of(context).tagERC20;
          break;
        case CoinType.hrc:
          label = AppLocalizations.of(context).tagHRC20;
          break;
        case CoinType.ubq:
          label = AppLocalizations.of(context).tagUBQ;
          break;
        case CoinType.qrc:
          label = AppLocalizations.of(context).tagQRC20;
          break;
        case CoinType.ftm:
          label = AppLocalizations.of(context).tagFTM20;
          break;
        case CoinType.plg:
          label = AppLocalizations.of(context).tagPLG20;
          break;
      }

      if (label != null) labels[type.name] = label;
    }

    return labels;
  }
}
