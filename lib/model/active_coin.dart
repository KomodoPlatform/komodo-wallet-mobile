import 'coin.dart';

class ActiveCoin {
  ActiveCoin.fromJson(Map<String, dynamic> json, Coin activeCoin) {
    if (json['mmrpc'] == '2.0') {
      print(json);
      coin = activeCoin.abbr ?? '';
      if (json['result']['bch_addresses_infos'] != null) {
        address = json['result']['bch_addresses_infos'].keys.first;
        balance = json['result']['bch_addresses_infos'].values.first['balances']
            ['spendable'];
        lockedBySwaps = json['result']['bch_addresses_infos']
            .values
            .first['balances']['unspendable'];
      } else {
        address = json['result']['balances'].keys.first;
        balance =
            json['result']['balances'].values.first['spendable'].toString();
        lockedBySwaps =
            json['result']['balances'].values.first['unspendable'].toString();
      }
      result = 'success';
      requiredConfirmations = activeCoin.requiredConfirmations;
      matureConfirmations = activeCoin.matureConfirmations;
      requiresNotarization = activeCoin.requiresNotarization;
    } else {
      coin = json['coin'] ?? '';
      address = json['address'] ?? '';
      balance = json['balance'] ?? '';
      lockedBySwaps = json['locked_by_swaps'] ?? '';
      result = json['result'] ?? '';
      requiredConfirmations = json['required_confirmations'];
      matureConfirmations = json['mature_confirmations'];
      requiresNotarization = json['requires_notarization'];
    }
  }

  String coin;
  String address;
  String balance;
  String lockedBySwaps;
  String result;
  int requiredConfirmations;
  int matureConfirmations;
  bool requiresNotarization;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'coin': coin ?? '',
        'address': address ?? '',
        'balance': balance ?? '',
        'locked_by_swaps': lockedBySwaps ?? '',
        'result': result ?? ''
      };
}
