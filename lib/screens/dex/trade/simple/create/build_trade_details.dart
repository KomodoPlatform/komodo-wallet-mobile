import 'package:flutter/material.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/dex/trade/build_detailed_fees.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/build_trade_message.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/top_order_details.dart';
import 'package:provider/provider.dart';

class BuildTradeDetails extends StatefulWidget {
  @override
  _BuildTradeDetailsState createState() => _BuildTradeDetailsState();
}

class _BuildTradeDetailsState extends State<BuildTradeDetails> {
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    return Column(
      children: [
        BuildTradeMessage(),
        //_buildOrderDetails(),
        //_buildEvaluation(),
        _buildFees(),
      ],
    );
  }

  Widget _buildOrderDetails() {
    if (_constrProvider.matchingOrder == null) return SizedBox();

    return Container(
        padding: EdgeInsets.fromLTRB(12, 24, 12, 10), child: TopOrderDetails());
  }

  Widget _buildFees() {
    if (_constrProvider.matchingOrder != null) {
      return Container(
        padding: EdgeInsets.fromLTRB(12, 24, 12, 12),
        child: BuildDetailedFees(
          preimage: _constrProvider.preimage,
          alignCenter: true,
        ),
      );
    } else {
      return SizedBox();
    }
  }
}
