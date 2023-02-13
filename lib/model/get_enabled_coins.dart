class GetEnabledCoins {
  GetEnabledCoins({
    this.method = 'get_enabled_coins',
    this.userpass,
  });

  String method;
  String? userpass;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'userpass': userpass,
    };
  }
}
