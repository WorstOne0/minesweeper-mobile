// ignore_for_file: constant_identifier_names

// Flutter packages
import 'package:intl/intl.dart';

// Enhanced Enums (https://dart.dev/language/enums)
enum MyDateFormat {
  DATE_TIME_REQUEST('yyyy-MM-dd HH:mm:ss'),
  DATE_TIME_RESULT('dd-MM-yyyy HH:mm:ss'),
  DATE_RESULT('dd-MM-yyyy'),
  TIME('HH:mm'),
  DAY_MONTH_YEAR('EEE d MMM yyyy'),
  ONLY_DAY_MONTH_YEAR('d MMM yyyy'),
  MONTH_DAY_YEAR('MMM d, yyyy'),
  YEAR_MONTH_DAY('yyyy-MM-dd'),
  MONGO_DB('yyyy-MM-ddTHH:mm:ssZ');

  const MyDateFormat(this.strDate);
  final String strDate;

  String format(DateTime? value, {String defaultValue = ""}) {
    try {
      return DateFormat(strDate).format(value!);
    } catch (e) {
      return defaultValue;
    }
  }

  /// Null when there is nothing to parse, where [parse] would answer "now" and make
  /// an absent date read as today.
  DateTime? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      return parseStrict(value);
    } catch (e) {
      return null;
    }
  }

  DateTime parse(String? value, {DateTime? defaultValue}) {
    try {
      return parseStrict(value!);
    } catch (e) {
      return defaultValue ?? DateTime.now();
    }
  }

  /// intl consumes the `Z` of an ISO stamp without applying the offset; only
  /// `DateTime.parse` turns it into the right local instant.
  DateTime parseStrict(String value) => switch (this) {
    MONGO_DB => DateTime.parse(value).toLocal(),
    _ => DateFormat(strDate).parse(value),
  };
}
