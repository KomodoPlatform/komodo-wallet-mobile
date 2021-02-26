import 'package:decimal/decimal.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/orderbook.dart';

// Matching order for prepared swap.
// Note, that OrderCoin.coinBase is the coin
// user wants to buy, and OrderCoin.coinRel - the coin user trying to sell.
// So, in case of `buy` request (taker-order) - {base: OrderCoin.coinBase, ...},
// for `setprice` request (maker-order) - {base: OrderCoin.coinRel, ...}
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
