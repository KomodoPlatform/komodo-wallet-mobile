import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/utils/utils.dart';

class SwapSharePreview extends StatefulWidget {
  const SwapSharePreview({Key key, this.swap}) : super(key: key);

  final Swap swap;

  @override
  _SwapSharePreviewState createState() => _SwapSharePreviewState();
}

class _SwapSharePreviewState extends State<SwapSharePreview> {
  final repaintKey = GlobalKey();
  final containerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Preview'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RepaintBoundary(
              key: repaintKey,
              child: Center(
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
                                                widget.swap.result.myInfo.myCoin
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
                                            widget.swap.result.myInfo.myAmount +
                                                ' ' +
                                                widget
                                                    .swap.result.myInfo.myCoin,
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
            RaisedButton(
              child: Text('Share'),
              onPressed: () async {
                final RenderRepaintBoundary boundary =
                    repaintKey.currentContext.findRenderObject();
                final ui.Image image = await boundary.toImage(pixelRatio: 4);
                final byteData =
                    await image.toByteData(format: ui.ImageByteFormat.png);
                final pngBytes = byteData.buffer.asUint8List();

                final String directory =
                    (await applicationDocumentsDirectory).path;
                final imgFile = File('$directory/screenshot.png');
                await imgFile.writeAsBytes(pngBytes);
              },
            ),
          ],
        ),
      ),
    );
  }
}
