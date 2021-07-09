import 'package:flutter/material.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/dex/trade/build_detailed_fees.dart';
import 'package:komodo_dex/screens/dex/trade/simple/evaluation_simple.dart';
import 'package:komodo_dex/screens/dex/trade/simple/exchange_rate_simple.dart';
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
        _buildFeesOrError(),
        _buildRate(),
        _buildEvaluation(),
      ],
    );
  }

  Widget _buildRate() {
    if (_constrProvider.matchingOrder == null) return SizedBox();

    return Container(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: ExchangeRateSimple());
  }

  Widget _buildEvaluation() {
    if (_constrProvider.matchingOrder == null) return SizedBox();

    return Container(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 24), child: EvaluationSimple());
  }

  Widget _buildFeesOrError() {
    if (_constrProvider.error != null) {
      return Container(
        padding: EdgeInsets.fromLTRB(12, 24, 12, 14),
        child: Text(
          _constrProvider.error,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Theme.of(context).errorColor),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_constrProvider.matchingOrder != null) {
      return Container(
        padding: EdgeInsets.fromLTRB(12, 24, 12, 8),
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
