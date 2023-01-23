import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/zcash_bloc.dart';

import '../../../../model/coin.dart';
import '../../utils/utils.dart';

class ItemZCoin extends StatefulWidget {
  const ItemZCoin({Key key, this.task}) : super(key: key);
  final ZTask task;
  @override
  _ItemZCoinState createState() => _ItemZCoinState();
}

class _ItemZCoinState extends State<ItemZCoin> {
  @override
  Widget build(BuildContext context) {
    final Coin coin = coinsBloc.getKnownCoinByAbbr(widget.task.abbr);

    if (widget.task.type == ZTaskType.DOWNLOADING)
      return Column(
        children: [
          LinearProgressIndicator(value: widget.task.progress / 100),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text('${widget.task.message}: ${widget.task.progress}%'),
              ),
              Spacer(),
              if (widget.task.result != null &&
                  widget.task.type == ZTaskType.WITHDRAW)
                InkWell(
                  onTap: () {
                    zcashBloc.confirmWithdraw(widget.task);
                  },
                  child: Text(
                    'Confirm',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              InkWell(
                onTap: () {
                  zcashBloc.cancelTask(widget.task);
                },
                child: Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              ),
            ],
          )
        ],
      );

    return Opacity(
      opacity: .6,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          children: [
            Row(
              children: <Widget>[
                Container(
                  height: 128,
                  color: Color(int.parse(coin.colorCoin)),
                  width: 8,
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 110,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                AssetImage(getCoinIconPath(coin.abbr)),
                          ),
                          if (coin.suspended)
                            Icon(
                              Icons.warning_rounded,
                              size: 20,
                              color: Colors.yellow[600],
                            ),
                        ],
                        alignment: Alignment.bottomRight,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        coin.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 8, bottom: 8, right: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          widget.task.message,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: widget.task.progress / 100,
                            ),
                            Text(
                              '${widget.task.progress}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    color: Colors.grey,
                                  ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: InkWell(
                  onTap: () {
                    zcashBloc.cancelTask(widget.task);
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
