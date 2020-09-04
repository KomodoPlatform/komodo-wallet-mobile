import 'package:flutter/material.dart';
import 'package:komodo_dex/model/rewards_provider.dart';
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
          : SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 12),
                    _buildTable(),
                  ],
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

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withAlpha(15),
          ),
        ),
      ),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
        },
        children: rows,
      ),
    );
  }

  TableRow _buildTableRow(int i, RewardsItem item) {
    return TableRow(
        decoration: BoxDecoration(
            color: i % 2 == 0 ? Colors.white.withAlpha(10) : null,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withAlpha(15),
              ),
            )),
        children: [
          Container(
            padding:
                const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
            child: Text(item.index.toString()),
          ),
          Container(
            padding:
                const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
            child: Text('${item.amount} KMD'),
          ),
          item.reward == null
              ? Container()
              : Container(
                  padding: const EdgeInsets.only(
                      left: 12, right: 6, top: 6, bottom: 6),
                  child: Text(item.reward.toString()),
                ),
          item.reward != null
              ? Container()
              : Container(
                  padding: const EdgeInsets.only(
                      left: 12, right: 6, top: 6, bottom: 6),
                  child: Text(
                    item.error['short'],
                    style: TextStyle(
                      color: Theme.of(context).errorColor,
                    ),
                  ),
                ),
        ]);
  }
}
