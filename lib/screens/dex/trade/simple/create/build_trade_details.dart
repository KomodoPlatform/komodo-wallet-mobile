import 'package:flutter/material.dart';
import '../../../../../model/swap_constructor_provider.dart';
import '../../../../dex/trade/simple/build_detailed_fees_simple.dart';
import '../../../../dex/trade/simple/create/build_trade_message.dart';
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
        _buildFees(),
      ],
    );
  }

  Widget _buildFees() {
    if (_constrProvider.matchingOrder != null) {
      return Container(
        padding: EdgeInsets.fromLTRB(12, 24, 12, 12),
        child: BuildDetailedFeesSimple(
          preimage: _constrProvider.preimage,
          alignCenter: true,
          hideIfLow: true,
        ),
      );
    } else {
      return SizedBox();
    }
  }
}
