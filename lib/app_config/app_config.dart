import 'package:komodo_dex/model/feed_provider.dart';

AppConfig appConfig = AppConfig();

class AppConfig {
  int get maxCoinsEnabledAndroid => 50;
  int get maxCoinEnabledIOS => 20;

  // number of decimal places for trade amount input fields
  int get tradeFormPrecision => 8;

  int get batteryLevelLow => 30; // show warnign on swap confirmation page
  int get batteryLevelCritical => 20; // swaps disabled

  String get appName => 'atomicDEX';
  String get appCompanyLong => 'Komodo Platform';
  String get appCompanyShort => 'Komodo';
  String get appCompanyDiscord => 'http://komodoplatform.com/discord';

  bool get isFeedEnabled => true;
  String get feedProviderSourceUrl => 'https://komodo.live/messages';

  List<String> get defaultCoins => ['KMD', 'BTC'];
  List<String> get coinsFiat => ['BTC', 'KMD'];

  bool get isSwapShareCardEnabled => true;

  bool get isUpdateCheckerEnabled => true;
  String get updateCheckerEndpoint => 'https://komodo.live/adexversion';

  String get fiatPricesEndpoint => 'https://rates.komodo.live/api/v1/usd_rates';
  String get cryptoPricesEndpoint =>
      'https://rates.komodo.live/api/v1/gecko_rates/';
  String get cryptoPricesFallback =>
      'https://api.coingecko.com/api/v3/simple/price?ids=';
  String get candlestickTickersList =>
      'https://komodo.live:3333/api/v1/ohlc/tickers_list';
  String get candlestickData => 'https://komodo.live:3333/api/v1/ohlc';

// At the moment (8/24/2020) tx history is disabled on parity nodes,
// so we switching ETH/ERC20, BNB/BEP20 tx history to
// the https://komodo.live:3334 endpoint
//
// API calls:
// '/api/v1/eth_tx_history/{address}' - ETH transaction history for address
// '/api/v1/erc_tx_history/{token}/{address}' - ERC20 transaction history
//
// ref: https://github.com/ca333/komodoDEX/issues/872

  String get ethUrl => 'https://komodo.live:3334/api/v1/eth_tx_history';
  String get ercUrl => 'https://komodo.live:3334/api/v2/erc_tx_history';
  String get bnbUrl => 'https://komodo.live:3334/api/v1/bnb_tx_history';
  String get bepUrl => 'https://komodo.live:3334/api/v2/bep_tx_history';

  NewsSource get defaultNewsSource => NewsSource(
        name: 'Komodo #official-news',
        url:
            'https://discord.com/channels/412898016371015680/412915799251222539',
        pic:
            'https://cdn.discordapp.com/icons/412898016371015680/a_157cb08c4198ad53b9e9b7168c930571.png',
      );
}
