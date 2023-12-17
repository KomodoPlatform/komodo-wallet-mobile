// To parse this JSON data, do
//
//     final transactions = transactionsFromJson(jsonString);

import 'dart:convert';

import '../blocs/camo_bloc.dart';
import '../model/transaction_data.dart';

Transactions transactionsFromJson(String str) =>
    Transactions.fromJson(json.decode(str));

String transactionsToJson(Transactions data) => json.encode(data.toJson());

class Transactions {
  Transactions({
    this.result,
  });

  factory Transactions.fromJson(Map<String, dynamic> json) => Transactions(
        result: Result.fromJson(json['result']),
      );

  Result result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result.toJson(),
      };

  void camouflageIfNeeded() {
    if (!camoBloc.isCamoActive) return;

    result.transactions.forEach(camoBloc.camouflageTransaction);
  }
}

class Result {
  Result({
    this.fromId,
    this.currentBlock,
    this.syncStatus,
    this.limit,
    this.skipped,
    this.total,
    this.transactions,
  });

  static Result fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    final fromIdRaw = json['from_id'] ??
        (json['paging_options'] != null &&
                json['paging_options']['FromId'] != null
            ? json['paging_options']['FromId']
            : null);

    final fromId = fromIdRaw is int ? fromIdRaw.toString() : fromIdRaw;

    return Result(
      fromId: fromId,
      limit: json['limit'] ?? 0,
      skipped: json['skipped'] ?? 0,
      total: json['total'] ?? 0,
      currentBlock: json['current_block'] ?? 0,
      syncStatus: json['sync_status'] == null
          ? SyncStatus()
          : SyncStatus.fromJson(json['sync_status']),
      transactions: List<Transaction>.from(
        json['transactions'].map((dynamic x) => Transaction.fromJson(x)),
      ),
    );
  }

  String fromId;
  int currentBlock;
  SyncStatus syncStatus;
  int limit;
  int skipped;
  int total;
  List<Transaction> transactions;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'from_id': fromId,
        'current_block': currentBlock ?? 0,
        'limit': limit ?? 0,
        'skipped': skipped ?? 0,
        'total': total ?? 0,
        'sync_status': syncStatus.toJson() ?? SyncStatus().toJson(),
        'transactions': List<dynamic>.from(
            transactions.map<dynamic>((dynamic x) => x.toJson())),
      };
}

class SyncStatus {
  SyncStatus({
    this.additionalInfo,
    this.state,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) => SyncStatus(
        additionalInfo: json['additional_info'] == null
            ? null
            : AdditionalInfo.fromJson(json['additional_info']),
        state: json['state'] ?? '',
      );

  AdditionalInfo additionalInfo;
  String state;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'additional_info': additionalInfo?.toJson(),
        'state': state ?? '',
      };
}

class AdditionalInfo {
  AdditionalInfo({
    this.code,
    this.message,
    this.transactionsLeft,
    this.blocksLeft,
  });

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) => AdditionalInfo(
        code: json['code'] ?? 0,
        message: json['message'] ?? '',
        transactionsLeft: json['transactions_left'] ?? 0,
        blocksLeft: json['blocks_left'] ?? 0,
      );

  int code;
  String message;
  int transactionsLeft;
  int blocksLeft;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'code': code ?? 0,
        'message': message ?? '',
        'transactions_left': transactionsLeft ?? 0,
        'blocks_left': blocksLeft ?? 0,
      };
}

enum StateOfSync { NotEnabled, NotStarted, InProgress, Error, Finished }
