import 'package:flutter/material.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:intl/intl.dart';

class SwapShareCard extends StatelessWidget {
  const SwapShareCard({Key key, @required this.swap}) : super(key: key);

  final Swap swap;

  @override
  Widget build(BuildContext context) {
    final startedEvent = swap.result.events
        .firstWhere((e) => e.event.type == 'Started', orElse: () => null);
    final finishedEvent = swap.result.events
        .firstWhere((e) => e.event.type == 'Finished', orElse: () => null);
    int durationMinutes = 0;
    String dateFormatted = '';
    if (finishedEvent != null && startedEvent != null) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(
          startedEvent.event.data.startedAt * 1000);
      final finalTime =
          DateTime.fromMillisecondsSinceEpoch(finishedEvent.timestamp);

      final DateFormat formatter = DateFormat.yMMMd();

      final Duration timeDifference = finalTime.difference(startTime);
      durationMinutes = timeDifference.inMinutes;

      dateFormatted = formatter.format(finalTime);
    }
    return Container(
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
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            Image.asset(
                              'assets/swap_share/swap_share_atomicdex_logo.png',
                              height: 24,
                            ),
                            Text(
                              'Powered by Komodo',
                              style: TextStyle(fontSize: 4),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                swap.result.myInfo.myCoin +
                                    '/' +
                                    swap.result.myInfo.otherCoin +
                                    ' '
                                        'Swap Complete!',
                                style: TextStyle(fontSize: 8),
                              ),
                              SizedBox(height: 6),
                              Table(
                                columnWidths: const {
                                  1: IntrinsicColumnWidth(),
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Image.asset(
                                        'assets/' +
                                            swap.result.myInfo.myCoin
                                                .toLowerCase() +
                                            '.png',
                                        height: 18,
                                        alignment: Alignment.centerRight,
                                      ),
                                      Icon(
                                        Icons.swap_horiz_rounded,
                                        size: 18,
                                      ),
                                      Image.asset(
                                        'assets/' +
                                            swap.result.myInfo.otherCoin
                                                .toLowerCase() +
                                            '.png',
                                        height: 18,
                                        alignment: Alignment.centerLeft,
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Text(
                                        cutTrailingZeros(formatPrice(
                                                swap.result.myInfo.myAmount,
                                                4)) +
                                            ' ' +
                                            swap.result.myInfo.myCoin,
                                        style: TextStyle(fontSize: 6),
                                        textAlign: TextAlign.right,
                                      ),
                                      SizedBox(),
                                      Text(
                                        cutTrailingZeros(formatPrice(
                                                swap.result.myInfo.otherAmount,
                                                4)) +
                                            ' ' +
                                            swap.result.myInfo.otherCoin,
                                        style: TextStyle(fontSize: 6),
                                        textAlign: TextAlign.left,
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
                        flex: 1,
                        child: Table(
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: IntrinsicColumnWidth(),
                          },
                          children: [
                            TableRow(
                              children: [
                                Text(
                                  'Details',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 6,
                                  ),
                                ),
                                SizedBox(width: 8),
                                SizedBox(),
                              ],
                            ),
                            const TableRow(
                              children: [
                                SizedBox(height: 8),
                                SizedBox(height: 8),
                                SizedBox(height: 8),
                              ],
                            ),
                            TableRow(
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(fontSize: 6),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  dateFormatted,
                                  style: TextStyle(fontSize: 6),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Text(
                                  'Duration',
                                  style: TextStyle(fontSize: 6),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '$durationMinutes Minutes',
                                  style: TextStyle(fontSize: 6),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    Image.asset(
                      'assets/swap_share/swap_share_illustration.png',
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: SizedBox()),
                          Image.asset(
                            'assets/swap_share/swap_share_qrcode.png',
                            height: 34,
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
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
