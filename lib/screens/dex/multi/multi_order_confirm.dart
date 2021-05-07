import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:komodo_dex/screens/dex/trade/confirm/protection_control.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class MultiOrderConfirm extends StatefulWidget {
  @override
  _MultiOrderConfirmState createState() => _MultiOrderConfirmState();
}

class _MultiOrderConfirmState extends State<MultiOrderConfirm> {
  MultiOrderProvider multiOrderProvider;
  final List<String> expanded = [];
  bool inProgress = false;

  @override
  Widget build(BuildContext context) {
    multiOrderProvider ??= Provider.of<MultiOrderProvider>(context);
    final Map<String, MultiOrderRelCoin> rel = multiOrderProvider.relCoins;

    return Column(
      children: <Widget>[
        inProgress
            ? const SizedBox(
                height: 1,
                child: LinearProgressIndicator(),
              )
            : Container(height: 1),
        Flexible(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
                    child: Text(
                      AppLocalizations.of(context)
                          .multiConfirmTitle(rel.length),
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  _buildList(),
                  _buildButton(),
                  _buildWarning(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FlatButton(
            onPressed: inProgress
                ? null
                : () {
                    multiOrderProvider.validated = false;
                  },
            child: Text(AppLocalizations.of(context).multiConfirmCancel),
          ),
          RaisedButton(
            onPressed: inProgress
                ? null
                : () async {
                    setState(() {
                      inProgress = true;
                    });
                    await multiOrderProvider.create();
                    setState(() {
                      inProgress = false;
                      if (multiOrderProvider.relCoins.isEmpty) {
                        multiOrderProvider.reset();
                        swapBloc.setIndexTabDex(1);
                      }
                    });
                  },
            disabledColor: Theme.of(context).disabledColor.withAlpha(100),
            child: Text(AppLocalizations.of(context).multiConfirmConfirm),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Opacity(
      opacity: inProgress ? 0.5 : 1,
      child: Stack(
        children: <Widget>[
          Column(
            children: _buildRows(),
          ),
          if (inProgress)
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.transparent,
              ),
            )
        ],
      ),
    );
  }

  List<Widget> _buildRows() {
    final List<Widget> rows = [];

    multiOrderProvider.relCoins.forEach((coin, _) {
      rows.add(
        Card(
          child: Column(
            children: <Widget>[
              _buildTitle(coin),
              if (expanded.contains(coin))
                Column(
                  children: <Widget>[
                    _buildProtectionSettings(coin),
                  ],
                ),
            ],
          ),
        ),
      );
    });

    return rows;
  }

  Widget _buildProtectionSettings(String abbr) {
    final Coin coin = coinsBloc.getCoinByAbbr(abbr);
    return Container(
      color: Theme.of(context).highlightColor.withAlpha(10),
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: ProtectionControl(
        coin: coin,
        activeColor: Colors.transparent,
        onChange: (ProtectionSettings settings) {
          multiOrderProvider.setProtectionSettings(abbr, settings);
        },
      ),
    );
  }

  Widget _buildTitle(String coin) {
    return InkWell(
      onTap: () {
        setState(() {
          if (expanded.contains(coin)) {
            expanded.remove(coin);
          } else {
            expanded.add(coin);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(multiOrderProvider.baseCoin),
                        const SizedBox(width: 2),
                        CircleAvatar(
                          maxRadius: 9,
                          backgroundImage: AssetImage(
                              'assets/${multiOrderProvider.baseCoin.toLowerCase()}.png'),
                        ),
                      ],
                    ),
                    Text(
                      formatPrice(multiOrderProvider.baseAmt, 8),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Icon(Icons.swap_horiz),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          maxRadius: 9,
                          backgroundImage:
                              AssetImage('assets/${coin.toLowerCase()}.png'),
                        ),
                        const SizedBox(width: 2),
                        Text(coin),
                      ],
                    ),
                    Text(
                      formatPrice(multiOrderProvider.getRelCoinAmt(coin), 8),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
                Expanded(child: Container()),
                Icon(expanded.contains(coin)
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down)
              ],
            ),
            _buildError(coin),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String coin) {
    final String error = multiOrderProvider.getError(coin);
    if (error == null) return Container();

    return Container(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        error,
        style: Theme.of(context).textTheme.caption.copyWith(
              color: Theme.of(context).errorColor,
            ),
      ),
    );
  }

  Widget _buildWarning() {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  color: Theme.of(context).backgroundColor,
                  height: 32,
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 32),
                      child: Column(
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).infoTrade1,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            AppLocalizations.of(context).infoTrade2,
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
                left: 32,
                top: 8,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(52)),
                  child: Container(
                    height: 52,
                    width: 52,
                    color: Theme.of(context).backgroundColor,
                    child: Icon(
                      Icons.info,
                      size: 48,
                    ),
                  ),
                )),
          ],
        )
      ],
    );
  }
}
