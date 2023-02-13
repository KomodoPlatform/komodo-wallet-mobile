import 'package:flutter/material.dart';
import '../../../blocs/coins_bloc.dart';
import '../../../localizations.dart';
import '../../../model/coin_type.dart';
import '../../../utils/utils.dart';

class BuildTypeHeader extends StatefulWidget {
  const BuildTypeHeader({Key key, this.type, this.filterType, this.query})
      : super(key: key);

  // `null` for 'test coins' category
  final String type;
  final String filterType;
  final String query;

  @override
  _BuildTypeHeaderState createState() => _BuildTypeHeaderState();
}

class _BuildTypeHeaderState extends State<BuildTypeHeader> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoinToActivate>>(
        initialData: coinsBloc.coinBeforeActivation,
        stream: coinsBloc.outCoinBeforeActivation,
        builder: (context, snapshot) {
          final bool isActive = _areAllActive(snapshot.data);

          // todo(MRC): Optimize this to use CheckboxListTile in a future point in time
          return InkWell(
            onTap: () => coinsBloc.setCoinsBeforeActivationByType(
              widget.type,
              !isActive,
              filterType: widget.filterType,
              query: widget.query,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              child: Row(
                children: <Widget>[
                  Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: isActive
                              ? Theme.of(context).toggleableActiveColor
                              : Colors.transparent,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                          ))),
                  const SizedBox(width: 24),
                  Flexible(
                    child: Text(
                      _getTitleText(),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  String _getTitleText() {
    final CoinType titleType = coinTypeFromString(widget.type);

    switch (titleType) {
      case CoinType.erc:
        return AppLocalizations.of(context).searchFilterSubtitleERC;
        break;
      case CoinType.hrc:
        return AppLocalizations.of(context).searchFilterSubtitleHRC;
        break;
      case CoinType.zhtlc:
        return AppLocalizations.of(context).searchFilterSubtitleZHTLC;
        break;
      case CoinType.bep:
        return AppLocalizations.of(context).searchFilterSubtitleBEP;
        break;
      case CoinType.avx:
        return AppLocalizations.of(context).searchFilterSubtitleAVX;
        break;
      case CoinType.plg:
        return AppLocalizations.of(context).searchFilterSubtitlePLG;
        break;
      case CoinType.qrc:
        return AppLocalizations.of(context).searchFilterSubtitleQRC;
        break;
      case CoinType.krc:
        return AppLocalizations.of(context).searchFilterSubtitleKRC;
        break;
      case CoinType.etc:
        return AppLocalizations.of(context).searchFilterSubtitleETC;
        break;
      case CoinType.sbch:
        return AppLocalizations.of(context).searchFilterSubtitleSBCH;
        break;
      case CoinType.ubiq:
        return AppLocalizations.of(context).searchFilterSubtitleUBQ;
        break;
      case CoinType.utxo:
        return AppLocalizations.of(context).searchFilterSubtitleutxo;
        break;
      case CoinType.ftm:
        return AppLocalizations.of(context).searchFilterSubtitleFTM;
        break;
      case CoinType.mvr:
        return AppLocalizations.of(context).searchFilterSubtitleMVR;
        break;
      case CoinType.hco:
        return AppLocalizations.of(context).searchFilterSubtitleHCO;
        break;
      case CoinType.smartChain:
        return AppLocalizations.of(context).searchFilterSubtitleSmartChain;
      case CoinType.slp:
        return AppLocalizations.of(context).searchFilterSubtitleSLP;
        break;
      case CoinType.iris:
        return AppLocalizations.of(context).searchFilterSubtitleIris;
        break;
      case CoinType.cosmos:
        return AppLocalizations.of(context).searchFilterSubtitleCosmos;
        break;
    }

    // titleType == null for test assets
    return AppLocalizations.of(context).searchFilterSubtitleTestCoins;
  }

  bool _areAllActive(List<CoinToActivate> coinsBeforeActivation) {
    bool areAllActive = true;

    for (CoinToActivate item in coinsBeforeActivation) {
      if (item.isActive) continue;

      // `widget.type == null` for test coins
      if (widget.type == null) {
        if (isCoinPresent(item.coin, widget.query, widget.filterType) &&
            item.coin.testCoin) {
          if (item.isActive)
            continue;
          else
            areAllActive = false;
        } else if (widget.filterType.isEmpty &&
            widget.query.isEmpty &&
            item.coin.testCoin) areAllActive = false;
      } else {
        if (item.coin.type.name == widget.type &&
            !item.coin.testCoin &&
            isCoinPresent(item.coin, widget.query, widget.filterType)) {
          if (item.isActive)
            continue;
          else
            areAllActive = false;
        } else if (widget.filterType.isEmpty &&
            widget.query.isEmpty &&
            item.coin.type.name == widget.type &&
            !item.coin.testCoin) areAllActive = false;
      }
    }

    return areAllActive;
  }
}
