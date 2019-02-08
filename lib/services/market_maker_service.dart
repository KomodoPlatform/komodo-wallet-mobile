import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/balance.dart';

String url = 'http://10.0.2.2:7783';

Future<Balance> getBalance(String coin) async {
  final response = await http.post(url, body: "{\"userpass\":\"80c55cfc36648f2541c3ca95e163ee9da904987e28c33a69fd735032f0523058\",\"method\":\"my_balance\", \"coin\":\"$coin\"}");
  return balanceFromJson(response.body);
}