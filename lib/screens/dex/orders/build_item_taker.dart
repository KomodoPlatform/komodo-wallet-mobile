import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/swap_detail_page.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/utils.dart';

class BuildItemTaker extends StatefulWidget {
  const BuildItemTaker(this.order);

  final Order order;

  @override
  _BuildItemTakerState createState() => _BuildItemTakerState();
}

class _BuildItemTakerState extends State<BuildItemTaker> {
  bool isNoteExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      onTap: () {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => SwapDetailPage(
                    swap: Swap(
                        status: Status.ORDER_MATCHING,
                        result: MmSwap(
                          uuid: widget.order.uuid,
                          myInfo: SwapMyInfo(
                              myAmount: widget.order.baseAmount,
                              otherAmount: widget.order.relAmount,
                              myCoin: widget.order.base,
                              otherCoin: widget.order.rel,
                              startedAt: DateTime.now().millisecondsSinceEpoch),
                        )),
                  )),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              widget.order.base,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 4),
                            _buildIcon(widget.order.base),
                          ],
                        ),
                        Text(
                          '${formatPrice(widget.order.baseAmount, 8)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
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
                            _buildIcon(widget.order.rel),
                            const SizedBox(width: 4),
                            Text(
                              widget.order.rel,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Text(
                          '${formatPrice(widget.order.relAmount, 8)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                FutureBuilder<String>(
                    future: Db.getNote(widget.order.uuid),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }

                      return InkWell(
                        onTap: () {
                          setState(() {
                            isNoteExpanded = !isNoteExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  snapshot.data,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  maxLines: isNoteExpanded ? null : 1,
                                  overflow: isNoteExpanded
                                      ? null
                                      : TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      DateFormat('dd MMM yyyy HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              widget.order.createdAt * 1000)),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('stepStatus',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(color: Colors.white)),
                            const SizedBox(
                              width: 4,
                            ),
                            Text('swapStatus',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                      color: Colors.white,
                                    ))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildIcon(String coin) {
    return Container(
      height: 25,
      width: 25,
      child: Image.asset(
        'assets/${coin.toLowerCase()}.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
