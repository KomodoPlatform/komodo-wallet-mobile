import 'package:http/http.dart' show Response;
import 'package:http/http.dart' as http;

import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/disable_coin.dart';
import 'package:komodo_dex/model/error_disable_coin_active_swap.dart';
import 'package:komodo_dex/model/error_disable_coin_order_is_matched.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_disable_coin.dart';

class ApiProvider {
  String url = 'http://localhost:7783';
  Response response;

  Future<dynamic> disableCoin(
      http.Client client, Coin coin, GetDisableCoin getDisableCoin) async {
    return await client
        .post(url, body: getDisableCoinToJson(getDisableCoin))
        .then((Response response) {
      print(response.body);
      try {
        return disableCoinFromJson(response.body);
      } catch (e) {
        try {
          return errorDisableCoinActiveSwapFromJson(response.body);
        } catch (e) {
          try {
            return errorDisableCoinOrderIsMatchedFromJson(response.body);
          } catch (e) {
            try {
              return errorStringFromJson(response.body);
            } catch (e) {
              rethrow;
            }
          }
        }
      }
    }).catchError(
            (dynamic onError) => throw Exception('Failed to disable coin'));
  }
}
