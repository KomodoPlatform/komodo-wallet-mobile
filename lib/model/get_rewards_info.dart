class GetRewardsInfo {
  GetRewardsInfo({
    this.method = 'kmd_rewards_info',
    this.userpass,
  });

  String method;
  String userpass;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'userpass': userpass,
    };
  }
}
