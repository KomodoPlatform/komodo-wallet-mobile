import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_constructor_bloc.dart';

class SellForm extends StatefulWidget {
  const SellForm({this.coin});

  final String coin;

  @override
  _SellFormState createState() => _SellFormState();
}

class _SellFormState extends State<SellForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCoin(),
      ],
    );
  }

  Widget _buildCoin() {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 6, 12, 0),
      child: InkWell(
        onTap: () {
          constructorBloc.sellCoin = null;
        },
        child: Container(
            padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 8,
                  backgroundImage:
                      AssetImage('assets/${widget.coin.toLowerCase()}.png'),
                ),
                SizedBox(width: 4),
                Text(
                  widget.coin,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Expanded(child: SizedBox()),
                Icon(
                  Icons.clear,
                  size: 12,
                  color: Theme.of(context).textTheme.caption.color,
                ),
              ],
            )),
      ),
    );
  }
}
