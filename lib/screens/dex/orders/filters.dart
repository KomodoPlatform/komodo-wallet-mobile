import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';

class Filters extends StatefulWidget {
  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  ActiveFilters _filters = ActiveFilters();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    return InkWell(
      onTap: _showDialog,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(
              Icons.filter_alt_outlined,
              size: 14,
            ),
            SizedBox(width: 2),
            Text('Filters'),
          ],
        ),
      ),
    );
  }

  void _showDialog() {
    dialogBloc.dialog = showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SimpleDialog(
              titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 20),
              title: Text(
                'Filters',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              children: [
                _buildSellCoinFilter(),
              ],
            );
          });
        });
  }

  Widget _buildSellCoinFilter() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            'Sell coin:',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        _buildCoinSelect(current: _filters.sellCoin),
        Container(
          padding: EdgeInsets.fromLTRB(8, 8, 0, 8),
          child: InkWell(
            child: Opacity(
              opacity: _filters.sellCoin == null ? 0.5 : 1,
              child: Icon(
                Icons.clear,
                size: 16,
              ),
            ),
            onTap: _filters.sellCoin == null ? null : () {},
          ),
        )
      ],
    );
  }

  Widget _buildCoinSelect({String current}) {
    final Color color =
        current == null ? Theme.of(context).textTheme.bodyText1.color : null;

    return InkWell(
      onTap: () {},
      child: Container(
        width: 100,
        padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(
            color: Theme.of(context).accentColor.withAlpha(150),
            width: 1,
          ),
        )),
        child: Row(
          children: [
            CircleAvatar(
              radius: 7,
              backgroundColor: color,
              backgroundImage: current != null
                  ? AssetImage('assets/${current.toLowerCase()}.png')
                  : null,
            ),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                current ?? 'All',
                style: TextStyle(color: color),
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: color,
            )
          ],
        ),
      ),
    );
  }
}

class ActiveFilters {
  ActiveFilters({
    this.sellCoin,
    this.receiveCoin,
  });

  String sellCoin;
  String receiveCoin;
}
