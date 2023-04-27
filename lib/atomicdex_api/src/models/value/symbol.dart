abstract class Symbol {
  const Symbol({required this.text});

  final String text;

  @override
  String toString() {
    return text;
  }
}

class FiatCurrencySymbol extends Symbol {
  const FiatCurrencySymbol(String currency) : super(text: currency);
}

class CryptoCurrencySymbol extends Symbol {
  const CryptoCurrencySymbol(String ticker) : super(text: ticker);
}

class NFTSymbol extends Symbol {
  const NFTSymbol() : super(text: 'NFT');
}
