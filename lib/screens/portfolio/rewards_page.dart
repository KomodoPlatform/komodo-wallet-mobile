import 'package:flutter/material.dart';
import 'package:komodo_dex/model/rewards_provider.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class RewardsPage extends StatefulWidget {
  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  RewardsProvider rewardsProvider;

  @override
  Widget build(BuildContext context) {
    rewardsProvider = Provider.of<RewardsProvider>(context);
    final List<RewardsItem> rewards = rewardsProvider.rewards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards info'),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: rewards == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                rewardsProvider.update();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 12),
                      _buildTable(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTable() {
    final List<TableRow> rows = [];
    for (int i = 0; i < rewardsProvider.rewards.length; i++) {
      final RewardsItem item = rewardsProvider.rewards[i];
      rows.add(_buildTableRow(i, item));
    }

    return Table(
      border: TableBorder.all(color: Colors.white.withAlpha(15)),
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
              border: Border(
            bottom: BorderSide(
              color: Colors.white.withAlpha(15),
            ),
          )),
          children: [
            Container(
              padding:
                  const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
              child: Text(
                'UTXO amt,\nKMD',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
              child: Text(
                'Rewards,\nKMD',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              alignment: const Alignment(0, 0),
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
              child: Text(
                'Time left',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.only(left: 8, right: 12, top: 8, bottom: 8),
              alignment: const Alignment(1, 0),
              child: Text(
                'Status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        ...rows,
      ],
    );
  }

  TableRow _buildTableRow(int i, RewardsItem item) {
    return TableRow(
        decoration: BoxDecoration(
          color: i % 2 == 0 ? Colors.black.withAlpha(25) : null,
        ),
        children: [
          Container(
            padding:
                const EdgeInsets.only(left: 12, right: 8, top: 12, bottom: 12),
            child: Text(
              formatPrice(item.amount, 4),
              maxLines: 1,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          item.reward == null
              ? Container(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 12, bottom: 12),
                  child: const Text(
                    '-',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              : Container(
                  color: Colors.green.withAlpha(30),
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 12, bottom: 12),
                  child: Text(
                    formatPrice(item.reward, 4),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
          Container(
            alignment: const Alignment(0, 0),
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
            child: item.stopAt == null || item.stopAt == null
                ? Container()
                : Builder(builder: (context) {
                    final duration = Duration(
                        milliseconds: item.stopAt * 1000 -
                            DateTime.now().millisecondsSinceEpoch);

                    return Text(
                      _timeLeft(duration),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        color: duration.inDays < 2 ? Colors.orange : null,
                      ),
                    );
                  }),
          ),
          item.reward != null
              ? Container(
                  alignment: const Alignment(1, 0),
                  padding: const EdgeInsets.only(
                      left: 8, right: 12, top: 12, bottom: 12),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.green,
                  ),
                )
              : Container(
                  alignment: const Alignment(1, 0),
                  padding: const EdgeInsets.only(
                      left: 8, right: 12, top: 12, bottom: 12),
                  child: Text(
                    item.error['short'],
                    maxLines: 1,
                    style: TextStyle(
                      color: Theme.of(context).hintColor.withAlpha(150),
                      fontSize: 13,
                    ),
                  ),
                ),
        ]);
  }

  String _timeLeft(Duration duration) {
    final int dd = duration.inDays;
    final int hh = duration.inHours;
    final int mm = duration.inMinutes;

    if (dd > 0) {
      return '$dd day${dd > 1 ? 's' : ''}';
    }
    if (hh > 0) {
      String minutes = mm.remainder(60).toString();
      if (minutes.length < 2) minutes = '0$minutes';
      return '${hh}h ${minutes}m';
    }
    return '${mm}min';
  }
}
