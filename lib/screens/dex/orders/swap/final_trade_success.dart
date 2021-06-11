import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komodo_dex/screens/dex/orders/swap/detail_swap.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/utils/utils.dart';
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
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Positioned(
                width: 256,
                height: 144,
                left: 10000,
                child: RepaintBoundary(
                  key: repaintKey,
                  child: Container(
                    width: 256,
                    height: 144,
                    child: Stack(
                      children: <Widget>[
                        Image.asset(
                          'assets/swap_share/swap_share_background.png',
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                child: Column(
                                  children: [
                                    Stack(
                                      alignment: AlignmentDirectional.bottomEnd,
                                      children: [
                                        Image.asset(
                                          'assets/swap_share/swap_share_atomicdex_logo.png',
                                          height: 24,
                                        ),
                                        Text(
                                          'Powered by Komodo',
                                          style: TextStyle(fontSize: 6),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      widget.swap.result.myInfo.myCoin +
                                          '/' +
                                          widget.swap.result.myInfo.otherCoin +
                                          ' '
                                              'Swap Complete!',
                                      style: TextStyle(fontSize: 8),
                                    ),
                                    SizedBox(height: 6),
                                    Table(
                                      children: [
                                        TableRow(
                                          children: [
                                            Image.asset(
                                              'assets/' +
                                                  widget
                                                      .swap.result.myInfo.myCoin
                                                      .toLowerCase() +
                                                  '.png',
                                              height: 18,
                                            ),
                                            Icon(
                                              Icons.swap_horiz_rounded,
                                              size: 18,
                                            ),
                                            Image.asset(
                                              'assets/' +
                                                  widget.swap.result.myInfo
                                                      .otherCoin
                                                      .toLowerCase() +
                                                  '.png',
                                              height: 18,
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            Text(
                                              widget.swap.result.myInfo
                                                      .myAmount +
                                                  ' ' +
                                                  widget.swap.result.myInfo
                                                      .myCoin,
                                              style: TextStyle(fontSize: 6),
                                            ),
                                            Icon(Icons.swap_horiz_rounded,
                                                size: 8),
                                            Text(
                                              widget.swap.result.myInfo
                                                      .otherAmount +
                                                  ' ' +
                                                  widget.swap.result.myInfo
                                                      .otherCoin,
                                              style: TextStyle(fontSize: 6),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Details',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 6,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Table(
                                      children: [
                                        TableRow(
                                          children: [
                                            Text(
                                              'Date',
                                              style: TextStyle(fontSize: 6),
                                            ),
                                            Text(
                                              'TODO',
                                              style: TextStyle(fontSize: 6),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            Text(
                                              'Duration',
                                              style: TextStyle(fontSize: 6),
                                            ),
                                            Text(
                                              'TODO',
                                              style: TextStyle(fontSize: 6),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Stack(
                                    alignment: AlignmentDirectional.bottomEnd,
                                    children: [
                                      Image.asset(
                                        'assets/swap_share/swap_share_illustration.png',
                                      ),
                                      Image.asset(
                                        'assets/swap_share/swap_share_qrcode.png',
                                        height: 33,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Download AtomicDEX on atomicdex.io',
                                    style: TextStyle(fontSize: 6),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () async {
                    final RenderRepaintBoundary boundary =
                        repaintKey.currentContext.findRenderObject();
                    final ui.Image image =
                        await boundary.toImage(pixelRatio: 4);
                    final byteData =
                        await image.toByteData(format: ui.ImageByteFormat.png);
                    final pngBytes = byteData.buffer.asUint8List();

                    final String directory =
                        (await applicationDocumentsDirectory).path;
                    final imgFile = File('$directory/screenshot.png');
                    await imgFile.writeAsBytes(pngBytes);

                    Share.shareFiles(
                      [imgFile.path],
                      subject: 'Share',
                      text: 'Example text',
                    );
                  },
                ),
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
}
