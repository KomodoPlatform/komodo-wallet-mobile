import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komodo_dex/screens/dex/orders/swap/detail_swap.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/screens/dex/orders/swap/share_preview_overlay.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/swap_share_card.dart';
import 'package:share/share.dart';

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

  final repaintKey = GlobalKey();

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
      child: ListView(
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              if (appConfig.isSwapShareCardEnabled)
                Positioned(
                  width: 256,
                  height: 144,
                  left: 10000,
                  child: RepaintBoundary(
                    key: repaintKey,
                    child: SwapShareCard(swap: widget.swap),
                  ),
                ),
              Column(
                children: [
                  const SizedBox(
                    height: 32,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: Container(
                      height: 200,
                      child: SvgPicture.asset(
                          settingsBloc.isLightTheme
                              ? 'assets/svg_light/trade_success.svg'
                              : 'assets/svg/trade_success.svg',
                          semanticsLabel: 'Trade Success'),
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Column(
                    children: <Widget>[
                      Text(AppLocalizations.of(context).trade,
                          style: Theme.of(context).textTheme.headline6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SizedBox(),
                          ),
                          Text(
                            AppLocalizations.of(context).tradeCompleted,
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(color: Theme.of(context).accentColor),
                          ),
                          Expanded(
                            child: appConfig.isSwapShareCardEnabled
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        _shareCard();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(Icons.share),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ),
                        ],
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
                ],
              ),
            ],
          ),
          DetailSwap(
            swap: widget.swap,
          ),
        ],
      ),
    );
  }

  Future<void> _shareCard() async {
    final RenderRepaintBoundary boundary =
        repaintKey.currentContext.findRenderObject();
    final ui.Image image = await boundary.toImage(pixelRatio: 4);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData.buffer.asUint8List();

    final String directory = (await applicationDocumentsDirectory).path;
    final imgFile = File('$directory/screenshot.png');
    await imgFile.writeAsBytes(pngBytes);

    final myCoin = widget.swap.result.myInfo.myCoin;
    final otherCoin = widget.swap.result.myInfo.otherCoin;
    final shareText = "I've just atomic swapped $myCoin/$otherCoin"
        ' on my phone! You can try it too: https://atomicdex.io\n'
        '#blockchain #dex #atomicdex #komodoplatform #atomicswap';

    await Share.shareFiles(
      [imgFile.path],
      text: shareText,
      mimeTypes: ['image/png'],
    );

    if (Platform.isIOS) {
      dialogBloc.dialog = Navigator.of(context)
          .push(SharePreviewOverlay(imgFile))
          .then((_) => dialogBloc.dialog = null);
    }
  }
}
