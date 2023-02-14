// anchor: protocols support

import 'package:komodo_dex/utils/iterable_utils.dart';

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
}

CoinType? coinTypeFromString(String? value) {
  return CoinType.values.firstWhereOrNull(
    (e) => e.name.toUpperCase() == value?.toUpperCase(),
  );
}
