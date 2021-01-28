class ActiveCoin {
  ActiveCoin.fromJson(Map<String, dynamic> json) {
    coin = json['coin'] ?? '';
    address = json['address'] ?? '';
    balance = json['balance'] ?? '';
    lockedBySwaps = json['locked_by_swaps'] ?? '';
    result = json['result'] ?? '';
    requiredConfirmations = json['required_confirmations'];
    matureConfirmations = json['mature_confirmations'];
    requiresNotarization = json['requires_notarization'];
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
