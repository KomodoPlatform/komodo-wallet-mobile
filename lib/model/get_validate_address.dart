class GetValidateAddress {
  GetValidateAddress({
    this.method = 'validateaddress',
    this.userpass,
    this.address,
    this.coin,
  });

  String method;
  String userpass;
  String address;
  String coin;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'userpass': userpass,
      'address': address,
      'coin': coin,
    };
  }
}
