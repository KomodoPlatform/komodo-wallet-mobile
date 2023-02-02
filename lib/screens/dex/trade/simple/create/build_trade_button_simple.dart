import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../../generic_blocs/main_bloc.dart';
import '../../../../../localizations.dart';
import '../../../../../model/swap_constructor_provider.dart';
import '../../../../dex/trade/simple/confirm/swap_confirmation_page_simple.dart';
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

    return Opacity(
      opacity: _isEnabled() ? 1 : 0.6,
      child: Row(
        children: [
          SizedBox(width: 70),
          Expanded(
            child: ElevatedButton(
              key: const Key('trade-button-simple'),
              onPressed:
                  _isEnabled() ? () => _validateAndConfirm(context) : null,
              style: ElevatedButton.styleFrom(
                onPrimary: _isEnabled() ? null : Theme.of(context).hintColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(AppLocalizations.of(context).next.toUpperCase()),
            ),
          ),
          SizedBox(width: 70),
        ],
      ),
    );
  }

  Future<void> _validateAndConfirm(BuildContext mContext) async {
    String errorMessage;
    if (mainBloc.networkStatus != NetworkStatus.Online) {
      return errorMessage = AppLocalizations.of(context).noInternet;
    }

    if (errorMessage == null) {
      _constrProvider.warning = null;
      Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => SwapConfirmationPageSimple()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
