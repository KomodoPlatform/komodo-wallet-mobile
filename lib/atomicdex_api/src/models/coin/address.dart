// Represents an address associated with a coin
import 'package:komodo_dex/model/coin.dart';

class Address<T extends Protocol> {
  Address({
    required this.address,
    required this.balance,
    required this.protocol,
  });

  final String address;
  final double balance;
  final T protocol;
}
