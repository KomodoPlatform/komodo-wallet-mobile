import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/packages/trading/widgets/coin_select/wallet_address_tile.dart';

class TickerAccountAddress {
  TickerAccountAddress({
    @required this.address,
    @required this.ticker,
    @required this.account,
    this.balance,
  });

  final String address;
  final String ticker;
  final String account;
  final double balance;

  String get formattedAddress {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String get formattedBalance {
    if (balance == null) return null;
    return NumberFormat.currency(
      symbol: ticker,
      decimalDigits: 4,
    ).format(balance);
  }
}

List<TickerAccountAddress> get tickerAccountSampleData =>
    publicKeyBalances.entries
        .map((e) => TickerAccountAddress(
              address: e.key,
              balance: e.value,
              ticker: 'KMD',
              account: 'Main Account',
            ))
        .toList();
