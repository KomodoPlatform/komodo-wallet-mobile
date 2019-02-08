import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/active_coin.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_active_coin.dart';
import 'package:komodo_dex/model/get_balance.dart';

String url = 'http://10.0.2.2:7783';
String userpass = "80c55cfc36648f2541c3ca95e163ee9da904987e28c33a69fd735032f0523058";

Future<dynamic> getBalance(Coin coin) async {
  GetBalance getBalance = new GetBalance(
    userpass: userpass,
    method: "my_balance",
    coin: coin.abbr
  );
  final response = await http.post(url, body: json.encode(getBalance));
  try {
    return balanceFromJson(response.body);
  } catch (e) {
    return errorFromJson(response.body);
  }
}

Future<dynamic> activeCoin(Coin coin) async {
  GetActiveCoin getActiveCoin = new GetActiveCoin(
    userpass: userpass,
    method: "electrum",
    coin: coin.abbr,
    urls: coin.serverList
  );


  final response = await http.post(url, body: json.encode(getActiveCoin));
  print("coin" + coin.name + " result:" + response.body);
  try {
    return activeCoinFromJson(response.body);
  } catch (e) {
    return errorFromJson(response.body);
  }
}