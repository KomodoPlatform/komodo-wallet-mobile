import 'package:flutter/material.dart';
import 'package:komodo_dex/model/feed_provider.dart';
import 'package:komodo_dex/screens/help-feedback/support_channel_item.dart';

AppConfig appConfig = AppConfig();

class AppConfig {
  int get maxCoinsEnabledAndroid => 50;
  int get maxCoinEnabledIOS => 20;

  // number of decimal places for trade amount input fields
  int get tradeFormPrecision => 8;

  int get batteryLevelLow => 30; // show warnign on swap confirmation page
  int get batteryLevelCritical => 20; // swaps disabled

  // Brand config below

  String get appName => 'atomicDEX';
  String get appCompanyLong => 'Komodo Platform';
  String get appCompanyShort => 'Komodo';

  List<String> get defaultCoins => ['KMD', 'BTC'];
  List<String> get coinsFiat => ['BTC', 'KMD'];
  List<String> get walletOnlyCoins => ['USDT-ERC20'];
  final List<String> protocolSuffixes = [
    'ERC20',
    'BEP20',
    'PLG20',
    'FTM20',
    'HRC20',
  ];
  List<String> get defaultTestCoins => ['RICK', 'MORTY'];

  bool get isSwapShareCardEnabled => true;

  // support channels (showed on help page)
  List<SupportChannel> supportChannels = [
    SupportChannel(
      title: 'DISCORD',
      subtitle: 'Komodo #support',
      link: 'http://komodoplatform.com/discord',
      icon: SizedBox(
        width: 60,
        child: Image.asset('assets/discord_logo.png'),
      ),
    ),
  ];

  // endpoint source code:
  // https://github.com/KomodoPlatform/discord_feed_parser
  bool get isFeedEnabled => true;
  String get feedProviderSourceUrl => 'https://komodo.live/messages';
  NewsSource get defaultNewsSource => NewsSource(
        name: 'Komodo #official-news',
        url:
            'https://discord.com/channels/412898016371015680/412915799251222539',
        pic:
            'https://cdn.discordapp.com/icons/412898016371015680/a_157cb08c4198ad53b9e9b7168c930571.png',
      );

  // endpoint source code (currently same as news feed endpoint):
  // https://github.com/KomodoPlatform/discord_feed_parser
  bool get isUpdateCheckerEnabled => true;
  String get updateCheckerEndpoint => 'https://komodo.live/adexversion';

  // endpoint source code:
  // https://github.com/KomodoPlatform/mobile_endpoints_proxy/blob/main/main.py#L113
  String get fiatPricesEndpoint => 'https://rates.komodo.live/api/v1/usd_rates';

  // endpoint source code:
  // https://github.com/KomodoPlatform/mobile_endpoints_proxy/blob/main/main.py#L95
  String get cryptoPricesEndpoint =>
      'https://rates.komodo.live/api/v1/gecko_rates/';
  String get cryptoPricesFallback =>
      'https://api.coingecko.com/api/v3/simple/price?ids=';

  // endpoint source code:
  // https://github.com/KomodoPlatform/CexPricesEndpoint
  String get candlestickTickersList =>
      'https://komodo.live:3333/api/v1/ohlc/tickers_list';
  String get candlestickData => 'https://komodo.live:3333/api/v1/ohlc';

  // At the moment (8/24/2020) tx history is disabled on parity nodes,
  // so we switching ETH/ERC20, BNB/BEP20 tx history to
  // the web endpoint
  //
  // API calls:
  // '/api/v1/eth_tx_history/{address}' - ETH transaction history for address
  // '/api/v1/erc_tx_history/{token}/{address}' - ERC20 transaction history
  // endpoint source code:
  // https://github.com/KomodoPlatform/etherscan-mm2-proxy
  String get ethUrl => 'https://komodo.live:3334/api/v1/eth_tx_history';
  String get ercUrl => 'https://komodo.live:3334/api/v2/erc_tx_history';
  String get bnbUrl => 'https://komodo.live:3334/api/v1/bnb_tx_history';
  String get bepUrl => 'https://komodo.live:3334/api/v2/bep_tx_history';
  String get maticUrl => 'https://komodo.live:3334/api/v1/plg_tx_history';
  String get plgUrl => 'https://komodo.live:3334/api/v2/plg_tx_history';
  String get fantomUrl => 'https://komodo.live:3334/api/v1/ftm_tx_history';
  String get ftmUrl => 'https://komodo.live:3334/api/v2/ftm_tx_history';
  String get oneUrl => 'https://komodo.live:3334/api/v1/hrc_tx_history';
  String get hrcUrl => 'https://komodo.live:3334/api/v2/hrc_tx_history';
  String get ubqUrl => 'https://komodo.live:3334/api/v1/ubq_tx_history';

  /// We're using different rpc ports for different wallet packages
  /// in order to allow multiple wallets to run simultaneously.
  int get rpcPort => 7783;
}
