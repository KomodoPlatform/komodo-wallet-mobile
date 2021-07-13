import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/dex/trade/simple/confirm/swap_confirmation_page_simple.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class BuildTradeButtonSimple extends StatefulWidget {
  @override
  _BuildTradeButtonSimpleState createState() => _BuildTradeButtonSimpleState();
}

class _BuildTradeButtonSimpleState extends State<BuildTradeButtonSimple> {
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    if (_constrProvider.matchingOrder == null) return SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: PrimaryButton(
        key: const Key('trade-button-simple'),
        onPressed: _isEnabled() ? () => _validateAndConfirm(context) : null,
        text: AppLocalizations.of(context).trade,
      ),
    );
  }

  Future<void> _validateAndConfirm(BuildContext mContext) async {
    String errorMessage;
    if (mainBloc.networkStatus != NetworkStatus.Online) {
      return errorMessage = AppLocalizations.of(context).noInternet;
    }

    if (errorMessage == null) {
      Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => SwapConfirmationPageSimple()));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(errorMessage),
      ));
    }
  }

  bool _isEnabled() {
    if (_constrProvider.inProgress) return false;
    if (_constrProvider.error != null) return false;
    if (_constrProvider.preimage == null) return false;
    if (_constrProvider.matchingOrder == null) return false;
    if (_constrProvider.sellCoin == null || _constrProvider.buyCoin == null) {
      return false;
    }
    if ((_constrProvider.sellAmount?.toDouble() ?? 0) == 0) return false;
    if ((_constrProvider.buyAmount?.toDouble() ?? 0) == 0) return false;

    return true;
  }
}
