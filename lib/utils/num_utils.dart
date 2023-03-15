import 'package:komodo_dex/app_config/app_config.dart';
import 'package:rational/rational.dart';
import 'package:decimal/decimal.dart';

extension RationalToDecimalString on Rational {
  /// Returns a string representation of this rational number in decimal form.
  /// Precision defaults to [AppConfig.toDecimalStringPrecision].
  String toDecimalString([int? precision]) {
    return toDecimal().toStringAsFixed(appConfig.toDecimalStringPrecision);
  }
}

extension RationalToStringAsFixed on Rational {
  String toStringAsFixed(int precision) {
    return toDecimal(scaleOnInfinitePrecision: precision)
        .toStringAsFixed(precision);
  }
}
