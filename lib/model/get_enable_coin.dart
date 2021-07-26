class MmEnable {
  MmEnable({
    this.userpass,
    this.method = 'enable',
    this.coin,
    this.urls,
    this.txHistory,
    this.swapContractAddress,
    this.fallbackSwapContract,
  });

  factory MmEnable.fromJson(Map<String, dynamic> json) => MmEnable(
        userpass: json['userpass'] ?? '',
        method: json['method'] ?? '',
        coin: json['coin'] ?? '',
        txHistory: json['tx_history'] ?? false,
        urls:
            List<String>.from(json['urls'].map((dynamic x) => x)) ?? <String>[],
        swapContractAddress: json['swap_contract_address'] ?? '',
        fallbackSwapContract: json['fallback_swap_contract'] ?? '',
      );

  String userpass;
  String method;
  String coin;
  List<String> urls;
  String swapContractAddress;
  String fallbackSwapContract;
  bool txHistory;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'coin': coin ?? '',
        'tx_history': txHistory ?? false,
        'urls': List<dynamic>.from(urls.map<dynamic>((String x) => x)) ??
            <String>[],
        'swap_contract_address': swapContractAddress,
        'fallback_swap_contract': fallbackSwapContract,
      };
}
