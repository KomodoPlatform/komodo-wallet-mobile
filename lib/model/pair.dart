class Pair {
  Pair({this.base, this.rel});

  factory Pair.fromJson(List<dynamic> json) {
    return Pair(
      base: json[0],
      rel: json[1],
    );
  }

  String? base;
  String? rel;

  List<dynamic> toJson() {
    return <dynamic>[
      base,
      rel,
    ];
  }
}
