import 'package:flutter/material.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:provider/provider.dart';

class BuyForm extends StatefulWidget {
  @override
  _BuyFormState createState() => _BuyFormState();
}

class _BuyFormState extends State<BuyForm> {
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCoin(),
      ],
    );
  }

  Widget _buildCoin() {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    return Card(
      margin: EdgeInsets.fromLTRB(0, 6, 12, 0),
      child: InkWell(
        onTap: () {
          _constrProvider.buyCoin = null;
        },
        child: Container(
            padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 8,
                  backgroundImage: AssetImage(
                      'assets/${_constrProvider.buyCoin.toLowerCase()}.png'),
                ),
                SizedBox(width: 4),
                Text(
                  _constrProvider.buyCoin,
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
