// Represents a coin with its associated addresses
import 'package:komodo_dex/atomicdex_api/src/models/coin/address.dart';
import 'package:komodo_dex/atomicdex_api/src/models/value/symbol.dart';

class Coin {
  final String name;
  final CryptoCurrencySymbol symbol;
  final List<Address> addresses;

  Coin({
    required this.name,
    required this.symbol,
    required this.addresses,
  });
}
