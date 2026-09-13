import 'package:intl/intl.dart';

extension DateTimeX on DateTime? {
  String formattedDateTime([String? locale]) {
    if (this == null) return 'N/A';
    return DateFormat('d MMM yyyy, hh:mm a', locale).format(this!);
  }

  String formattedDate([String? locale]) {
    if (this == null) return 'N/A';
    return DateFormat('d MMM yyyy', locale).format(this!);
  }

  String formattedDayOrDate([String? locale]) {
    if (this == null) return 'N/A';
    final now = DateTime.now();
    if (now.year == this!.year && now.month == this!.month && now.day == this!.day) {
      return 'Today';
    }
    return formattedDate(locale);
  }
}
