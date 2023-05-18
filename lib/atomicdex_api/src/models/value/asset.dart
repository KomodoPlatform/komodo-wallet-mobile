import 'package:flutter/foundation.dart';
import 'package:komodo_dex/atomicdex_api/src/models/value/symbol.dart';

enum FiatCurrency { USD, EUR, GBP, CNY, RUB, TRY }

@immutable
abstract class IValue {
  const IValue({
    required this.amount,
    required this.symbol,
  });

  final double amount;

  final Symbol symbol;

  String format();
  String formatWithPrecision(int precision);
}

class FiatAsset extends IValue {
  const FiatAsset({
    required double amount,
    required FiatCurrencySymbol symbol,
  }) : super(amount: amount, symbol: symbol);

  FiatAsset.currency(FiatCurrency currency, double amount)
      : super(amount: amount, symbol: FiatCurrencySymbol(currency.name));

  FiatAsset.parsedCurrency(String currency, double amount)
      : super(amount: amount, symbol: FiatCurrencySymbol(currency));

  @override
  String format() => formatWithPrecision(2);

  @override
  String formatWithPrecision(int precision) {
    // Implement the logic to format the fiat currency amount with the specified precision
    return '${symbol.longFormat} ${amount.toStringAsFixed(precision)}';
  }
}

class CryptoAsset extends IValue {
  const CryptoAsset({
    required double amount,
    required CryptoCurrencySymbol symbol,
    required this.blockchain,
    // required this.contractAddress,
  }) : super(amount: amount, symbol: symbol);

  final String blockchain;
  // final String contractAddress;

  @override
  String format() {
    // Implement the logic to format the cryptocurrency amount as a string
    return '$symbol ${amount.toStringAsFixed(8)}';
  }

  @override
  String formatWithPrecision(int precision) {
    // Implement the logic to format the cryptocurrency amount with the specified precision
    return '$symbol ${amount.toStringAsFixed(precision)}';
  }
}

class NFT extends IValue {
  const NFT({
    required NFTSymbol symbol,
    required this.tokenId,
    required this.metadata,
  }) : super(amount: 1, symbol: symbol);

  final String tokenId;
  final Map<String, dynamic> metadata;

  @override
  String format() {
    // Implement the logic to format the NFT amount as a string
    return '$symbol ${amount.toStringAsFixed(0)}';
  }

  @override
  String formatWithPrecision(int precision) {
    // Implement the logic to format the NFT amount with the specified precision
    return '$symbol ${amount.toStringAsFixed(precision)}';
  }
}
