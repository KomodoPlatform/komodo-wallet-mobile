abstract class Symbol {
  const Symbol({required this.text});

  final String text;

  static String typeName(Type type) => typeNames[type]!;

  static Map<Type, String> get typeNames => {
        FiatCurrencySymbol: 'FiatCurrencySymbol',
        CryptoCurrencySymbol: 'CryptoCurrencySymbol',
        NFTSymbol: 'NFTSymbol',
      };

  static Symbol fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'FiatCurrencySymbol':
        return FiatCurrencySymbol.fromJson(json);
      case 'CryptoCurrencySymbol':
        return CryptoCurrencySymbol.fromJson(json);
      case 'NFTSymbol':
        return NFTSymbol.fromJson(json);
      default:
        throw ArgumentError.value(type, 'type', 'Invalid symbol type');
    }
  }

  Map<String, dynamic> toJson() => throw UnimplementedError();

  @override
  String toString() => '$runtimeType($text)';

  String get longFormat => text;

  String get shortFormat => throw UnimplementedError();
}

class FiatCurrencySymbol extends Symbol {
  const FiatCurrencySymbol(String currency) : super(text: currency);

  factory FiatCurrencySymbol.fromJson(Map<String, dynamic> json) =>
      FiatCurrencySymbol(json['text'] as String);

  @override
  Map<String, dynamic> toJson() => {
        'type': Symbol.typeName(runtimeType),
        'text': text,
      };
}

class CryptoCurrencySymbol extends Symbol {
  const CryptoCurrencySymbol(String ticker) : super(text: ticker);

  factory CryptoCurrencySymbol.fromJson(Map<String, dynamic> json) =>
      CryptoCurrencySymbol(json['text'] as String);
}

class NFTSymbol extends Symbol {
  const NFTSymbol() : super(text: 'NFT');

  factory NFTSymbol.fromJson(Map<String, dynamic> json) => NFTSymbol();
}
