// To parse this JSON data, do
//
//     final withdrawResponse = withdrawResponseFromJson(jsonString);

import 'dart:convert';

WithdrawResponse withdrawResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return WithdrawResponse.fromJson(jsonData);
}

String withdrawResponseToJson(WithdrawResponse data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class WithdrawResponse {
  String txHex;
  String from;
  String to;
  double amount;
  FeeDetails feeDetails;

  WithdrawResponse({
    this.txHex,
    this.from,
    this.to,
    this.amount,
    this.feeDetails,
  });

  factory WithdrawResponse.fromJson(Map<String, dynamic> json) =>
      new WithdrawResponse(
        txHex: json["tx_hex"],
        from: json["from"],
        to: json["to"],
        amount: json["amount"].toDouble(),
        feeDetails: FeeDetails.fromJson(json["fee_details"]),
      );

  Map<String, dynamic> toJson() => {
        "tx_hex": txHex,
        "from": from,
        "to": to,
        "amount": amount,
        "fee_details": feeDetails.toJson(),
      };
}

class FeeDetails {
  double amount;
  String coin;
  int gas;
  double gasPrice;
  double totalFee;

  FeeDetails({
    this.amount,
    this.coin,
    this.gas,
    this.gasPrice,
    this.totalFee,
  });

  factory FeeDetails.fromJson(Map<String, dynamic> json) => new FeeDetails(
        amount: json["amount"]?.toDouble(),
        coin: json["coin"],
        gas: json["gas"],
        gasPrice: json["gas_price"]?.toDouble(),
        totalFee: json["total_fee"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "coin": coin,
        "gas": gas,
        "gas_price": gasPrice,
        "total_fee": totalFee,
      };
}
