abstract class Symbol {
  const Symbol({required this.text});

  final String text;

  static String typeName(Type type) => typeNames[type]!;

  static Map<Type, String> get typeNames => {
        FiatCurrencySymbol: 'FiatCurrencySymbol',
        CryptoCurrencySymbol: 'CryptoCurrencySymbol',
        NFTSymbol: 'NFTSymbol',
      };

  @override
  String toString() {
    return text;
  }

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

  Map<String, dynamic> toJson() {
    return {
      'type': typeName(runtimeType),
      'text': text,
    };
  }
}

class FiatCurrencySymbol extends Symbol {
  const FiatCurrencySymbol(String currency) : super(text: currency);

  @override
  static String get type => 'FiatCurrencySymbol';

  static FiatCurrencySymbol fromJson(Map<String, dynamic> json) {
    final currency = json['text'] as String;
    return FiatCurrencySymbol(currency);
  }
}

class CryptoCurrencySymbol extends Symbol {
  const CryptoCurrencySymbol(String ticker) : super(text: ticker);

  @override
  static String get type => 'CryptoCurrencySymbol';

  static CryptoCurrencySymbol fromJson(Map<String, dynamic> json) {
    final ticker = json['text'] as String;
    return CryptoCurrencySymbol(ticker);
  }
}

class NFTSymbol extends Symbol {
  const NFTSymbol() : super(text: 'NFT');

  @override
  static String get type => 'NFTSymbol';

  static NFTSymbol fromJson(Map<String, dynamic> json) {
    return NFTSymbol();
  }
}
