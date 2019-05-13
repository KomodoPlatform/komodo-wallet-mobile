import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:komodo_dex/model/transaction.dart';

final getTransactionObj = GetTransactionService();

///This class
class GetTransactionService {
  int calc = 100000000;
  int numTxs = 0;
  bool coinAvailable = false;
  bool out = false;
  int numTx = 0;
  // Below getTransaction function does fetch transaction details from blockexplorer API - this is a alpha feature and
  // is being replaced with our own SPV solution for the beta release. Hence why the below URLs and data is not set through config file
  //
  Future<List<Transaction>> getTransactions(String coin, String pubkey) async {
    List<Transaction> transactions = new List<Transaction>();
    // Explorer API:
    //
    // ETH:  http://api.ethplorer.io/getAddressTransactions/0x6ce989d2E0361f1201aDf57CD324723018Cf3ce4?apiKey=freekey

    String pubkeyApi = 'https://' + coin.toLowerCase() + '.kmd.dev/api/';
    if (coin == "RFOX")
      pubkeyApi = 'http://rfox.explorer.dexstats.info/insight-api-komodo/';
    else if (coin == "BTC")
      pubkeyApi = 'https://insight.bitpay.com/api/';
    else if (coin == "RICK")
      pubkeyApi = 'https://rick.kmd.dev/api/';
    else if (coin == "MORTY")
      pubkeyApi = 'https://morty.kmd.dev/api/';
    else if (coin == "KMD") pubkeyApi = 'https://api.kmd.dev/api/';

    if (coin != "USDT" && coin != "ETH") {
      final response = await http.get(pubkeyApi + 'addr/' + pubkey);
      Map decoded = jsonDecode(response.body);
      numTx = decoded['txApperances'];
      if (numTx > 10) numTx = 10;
      for (int i = 0; i < numTx; i++) {
        out = false;
        final response =
            await http.get(pubkeyApi + 'tx/' + decoded['transactions'][i]);
        Map decoded2 = jsonDecode(response.body);

        for (int j = 0; j < decoded2['vin'].length; j++) {
          if (decoded2['vin'][j]['addr'] == pubkey) {
            out = true;
            break;
          }
        }
        double val = 0.0;
        for (int j = 0; j < decoded2['vout'].length; j++) {
          for (int k = 0;
              k < decoded2['vout'][j]['scriptPubKey']['addresses'].length;
              k++) {
            if (pubkey ==
                decoded2['vout'][j]['scriptPubKey']['addresses'][k].toString())
              val += double.parse(decoded2['vout'][j]['value']);
          }
        }

        if (out) val = double.parse(decoded2['vout'][0]['value']);
        transactions.add(Transaction(
            txid: decoded2['txid'],
            isIn: !out,
            value: val,
            isConfirm: (decoded2['confirmations'] > 0),
            date:
                DateTime.fromMillisecondsSinceEpoch(decoded2['time'] * 1000)));
      }
    } else {
      //case where its ETH or ERC tokens
      pubkeyApi = 'http://api.ethplorer.io/getAddressTransactions/' +
          pubkey +
          '?apiKey=freekey';
      final response = await http.get(pubkeyApi);
      List decoded = jsonDecode(response.body);
      numTx = decoded.length;
      for (int i = 0; i < numTx; i++) {
        out = false;
        transactions.add(Transaction(
            txid: decoded[i]['hash'],
            isIn: !(decoded[i]['from'].toLowerCase() == pubkey.toLowerCase()),
            value: decoded[i]['value'],
            isConfirm: decoded[i]['success'],
            date: DateTime.fromMillisecondsSinceEpoch(
                decoded[i]['timestamp'] * 1000)));
      }
    }
    return transactions;
  }
}
