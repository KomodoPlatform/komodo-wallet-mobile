// anchor: protocols support

enum CoinType {
  utxo,
  slp,
  smartChain,
  erc,
  bep,
  plg,
  ftm,
  qrc,
  hrc,
  mvr,
  hco,
  krc,
  etc,
  sbch,
  ubiq,
  avx,
  zhtlc,
  iris,
  cosmos,
}

CoinType coinTypeFromString(String value) {
  return CoinType.values.firstWhere(
    (e) => e.name.toUpperCase() == value?.toUpperCase(),
    orElse: () => null,
  );
}
