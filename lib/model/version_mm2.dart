class VersionMm2 {
  VersionMm2({this.result, this.datetime});

  factory VersionMm2.fromJson(Map<String, dynamic> json) => VersionMm2(
        result: json['result'] ?? '',
        datetime: json['datetime'] ?? '',
      );

  String result;
  String datetime;
}
