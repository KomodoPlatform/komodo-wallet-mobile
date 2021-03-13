import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';

class BuildTypeHeader extends StatefulWidget {
  const BuildTypeHeader({Key key, this.type}) : super(key: key);

  final String type;

  @override
  _BuildTypeHeaderState createState() => _BuildTypeHeaderState();
}

class _BuildTypeHeaderState extends State<BuildTypeHeader> {
  bool isActive = false;

  String getTitleText() {
    switch (widget.type) {
      case 'erc':
        return AppLocalizations.of(context).searchFilterSubtitleERC;
        break;
      case 'qrc':
        return AppLocalizations.of(context).searchFilterSubtitleQRC;
        break;
      case 'utxo':
        return AppLocalizations.of(context).searchFilterSubtitleutxo;
        break;
      case 'smartChain':
        return AppLocalizations.of(context).searchFilterSubtitleSmartChain;
        break;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isActive = !isActive;
        });
        switch (widget.type) {
          case 'erc':
            isActive
                ? coinsBloc.setIsERCActive(true)
                : coinsBloc.setIsERCActive(false);
            break;
          case 'qrc':
            isActive
                ? coinsBloc.setIsQRCActive(true)
                : coinsBloc.setIsQRCActive(false);
            break;
          case 'utxo':
            isActive
                ? coinsBloc.setIsutxoActive(true)
                : coinsBloc.setIsutxoActive(false);
            break;
          case 'smartChain':
            isActive
                ? coinsBloc.setIsAllSmartChainActive(true)
                : coinsBloc.setIsAllSmartChainActive(false);
            break;
          default:
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        child: Row(
          children: <Widget>[
            Container(
              height: 15,
              width: 15,
              color: isActive
                  ? Theme.of(context).accentColor
                  : Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 24),
            Text(
              getTitleText(),
              style: Theme.of(context).textTheme.subtitle2,
            )
          ],
        ),
      ),
    );
  }
}
