class ImportSwaps {
  ImportSwaps({
    this.result,
  });

  factory ImportSwaps.fromJson(Map<String, dynamic> json) => ImportSwaps(
        result: Result.fromJson(json['result']) ?? Result(),
      );

  Result? result;
}

class Result {
  Result({
    this.imported,
    this.skipped,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        imported: json['imported'],
        skipped: json['skipped'],
      );

  List<dynamic>? imported;
  Map<String, dynamic>? skipped;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'imported': imported,
        'skipped': skipped,
      };
}
