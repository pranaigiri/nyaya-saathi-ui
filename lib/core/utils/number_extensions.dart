import 'package:intl/intl.dart';

extension NumX on num {
  String humanizedCount({int? decimalDigits, String? locale}) {
    return NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: decimalDigits,
    ).format(this);
  }

  String humanizedCurrency(String code, {String? locale}) {
    return NumberFormat.simpleCurrency(name: code, locale: locale).format(this);
  }

  String humanizedCompact({String? locale}) {
    return NumberFormat.compact(locale: locale).format(this);
  }
}
