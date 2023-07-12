import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
