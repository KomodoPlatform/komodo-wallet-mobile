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
}
