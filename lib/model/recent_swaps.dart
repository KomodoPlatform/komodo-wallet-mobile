// To parse this JSON data, do
//
//     final recentSwaps = recentSwapsFromJson(jsonString);

import 'dart:convert';

import 'package:komodo_dex/model/swap.dart';

RecentSwaps recentSwapsFromJson(String str) =>
    RecentSwaps.fromJson(json.decode(str));

String recentSwapsToJson(RecentSwaps data) => json.encode(data.toJson());

class RecentSwaps {
  Result result;

  RecentSwaps({
    this.result,
  });

  factory RecentSwaps.fromJson(Map<String, dynamic> json) => new RecentSwaps(
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result.toJson(),
      };
}

class Result {
  dynamic fromUuid;
  int limit;
  int skipped;
  List<dynamic> swaps;
  int total;

  Result({
    this.fromUuid,
    this.limit,
    this.skipped,
    this.swaps,
    this.total,
  });

  factory Result.fromJson(Map<String, dynamic> json) => new Result(
        fromUuid: json["from_uuid"],
        limit: json["limit"],
        skipped: json["skipped"],
        swaps: new List<dynamic>.from(json["swaps"].map((x) {
          return x;
        })),
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "from_uuid": fromUuid,
        "limit": limit,
        "skipped": skipped,
        "swaps": new List<dynamic>.from(swaps.map((x) {
          return x;
        })),
        "total": total,
      };
}
