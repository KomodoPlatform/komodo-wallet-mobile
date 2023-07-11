import 'dart:collection';

import 'package:flutter/material.dart';

class CoinSymbolGroup {
  CoinSymbolGroup({
    @required this.symbol,
    @required this.name,
    @required this.tickers,
    this.imageUrl,
  });

  CoinSymbolGroup.fromTickerList(
    List<CoinTickerData> tickers, {
    @required this.symbol,
    @required this.name,
    this.imageUrl,
  }) : tickers = LinkedHashMap.fromEntries(
          tickers.map(
            (CoinTickerData ticker) => MapEntry(ticker.ticker, ticker),
          ),
        );

  final String symbol;
  final String name;
  final LinkedHashMap<String, CoinTickerData> tickers;
  final String imageUrl;
}

class CoinTickerData {
  CoinTickerData({
    @required this.name,
    @required this.ticker,
    @required this.imageUrl,
    this.platform,
    this.chainImageUrl,
  });

  CoinTickerData.fromGroup(
    CoinSymbolGroup parent, {
    @required this.ticker,
    String name,
    this.platform,
    this.chainImageUrl,
  })  : imageUrl = parent.imageUrl,
        // platform = parent.name,
        name = name ?? parent.name;

  final String name;
  final String ticker;

  // Nullable:
  final String platform;
  final String chainImageUrl;
  final String imageUrl;
}

List<CoinSymbolGroup> coinGroups = [
  // Ethereum Group
  CoinSymbolGroup(
    symbol: 'ETH',
    name: 'Ethereum',
    imageUrl:
        'https://github.com/KomodoPlatform/atomicdex-mobile/blob/master/assets/coin-icons/eth.png?raw=true',
    tickers: LinkedHashMap.fromEntries(
      [
        CoinTickerData(
          name: 'Ethereum',
          ticker: 'ETH',
          imageUrl:
              'https://github.com/KomodoPlatform/atomicdex-mobile/blob/master/assets/coin-icons/eth.png?raw=true',
          // platform: 'Ethereum',
          chainImageUrl:
              'https://github.com/KomodoPlatform/atomicdex-mobile/blob/master/assets/coin-icons/erc.png?raw=true',
        ),
        CoinTickerData(
          name: 'Ethereum',
          ticker: 'ETH-BEP20',
          imageUrl:
              'https://github.com/KomodoPlatform/atomicdex-mobile/blob/master/assets/coin-icons/eth.png?raw=true',
          platform: 'Binance Smart Chain',
          chainImageUrl:
              'https://github.com/KomodoPlatform/atomicdex-mobile/blob/master/assets/coin-icons/bep.png?raw=true',
        ),
      ].map((CoinTickerData ticker) => MapEntry(ticker.ticker, ticker)),
    ),
  ),
  // Bitcoin Group
  CoinSymbolGroup(
    symbol: 'BTC',
    name: 'Bitcoin',
    imageUrl:
        'https://github.com/KomodoPlatform/atomicdex-mobile/blob/master/assets/coin-icons/btc.png?raw=true',
    tickers: LinkedHashMap.fromEntries(
      [
        CoinTickerData(
          name: 'Bitcoin',
          ticker: 'BTC',
          imageUrl:
              'https://github.com/KomodoPlatform/atomicdex-mobile/blob/master/assets/coin-icons/btc.png?raw=true',
          platform: 'Smart Chain',
          chainImageUrl:
              'https://github.com/KomodoPlatform/atomicdex-mobile/blob/master/assets/coin-icons/smart%20chain.png?raw=true',
        ),
        CoinTickerData(
          name: 'Bitcoin',
          ticker: 'BTC-BEP20',
          imageUrl:
              'https://github.com/KomodoPlatform/atomicdex-mobile/blob/master/assets/coin-icons/btc.png?raw=true',
          platform: 'Binance Smart Chain',
          chainImageUrl:
              'https://github.com/KomodoPlatform/atomicdex-mobile/blob/master/assets/coin-icons/bep.png?raw=true',
        ),
      ].map((CoinTickerData ticker) => MapEntry(ticker.ticker, ticker)),
    ),
  ),
];
