import 'package:komodo_dex/atomicdex_api/src/models/value/asset.dart';
import 'package:komodo_dex/atomicdex_api/src/models/value/symbol.dart';

extension IValueConverter on IValue {
  IValue? convertTo(Symbol target) {
    // TODO: Implement the logic to convert the value to the other value.
    // Will require initializing the conversion matrix at app startup so that
    // this can be called synchronously. Alternatively, this can be made async
    // and the conversion matrix can be initialized on demand.
    throw UnimplementedError();
    final conversionRate = 1.0;
    if (target is FiatCurrencySymbol) {
      return FiatAsset.parsedCurrency(target.text, amount);
    } else if (target is CryptoCurrencySymbol) {
      return CryptoAsset(
        amount: amount,
        symbol: target,
        blockchain: '',
      );
    }

    return null;
  }
}
