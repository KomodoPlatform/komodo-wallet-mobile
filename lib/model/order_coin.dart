import 'package:decimal/decimal.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/orderbook.dart';

class OrderCoin {
  OrderCoin(
      {this.coinRel,
      this.coinBase,
      this.orderbook,
      this.bestPrice,
      this.maxVolume});

  Coin coinRel;
  Coin coinBase;
  Orderbook orderbook;
  Decimal bestPrice;
  Decimal maxVolume;

  Decimal getBuyAmount(Decimal amountToSell) {
    Decimal buyAmount = amountToSell / bestPrice;
    if (buyAmount >= maxVolume) buyAmount = maxVolume;
    return buyAmount;
  }
}
