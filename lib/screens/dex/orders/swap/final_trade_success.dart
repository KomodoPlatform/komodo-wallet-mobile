import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komodo_dex/screens/dex/orders/swap/detail_swap.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';

class FinalTradeSuccess extends StatefulWidget {
  const FinalTradeSuccess({@required this.swap});

  final Swap swap;

  @override
  _FinalTradeSuccessState createState() => _FinalTradeSuccessState();
}

class _FinalTradeSuccessState extends State<FinalTradeSuccess>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<dynamic> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    animation = Tween<double>(begin: -0.5, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));
    animationController.forward();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animationController.drive(CurveTween(curve: Curves.easeOut)),
      child: Center(
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 32,
            ),
            Container(
              height: 200,
              child: SvgPicture.asset(
                  settingsBloc.isLightTheme
                      ? 'assets/svg_light/trade_success.svg'
                      : 'assets/svg/trade_success.svg',
                  semanticsLabel: 'Trade Success'),
            ),
            const SizedBox(
              height: 32,
            ),
            Column(
              children: <Widget>[
                Text(AppLocalizations.of(context).trade,
                    style: Theme.of(context).textTheme.headline6),
                Text(
                  AppLocalizations.of(context).tradeCompleted,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Theme.of(context).accentColor),
                ),
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            Container(
              color: const Color.fromARGB(255, 52, 62, 76),
              height: 1,
              width: double.infinity,
            ),
            DetailSwap(
              swap: widget.swap,
            )
          ],
        ),
      ),
    );
  }
}