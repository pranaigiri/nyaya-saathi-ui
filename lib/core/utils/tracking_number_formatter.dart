import 'package:flutter/services.dart';

/// A smart TextInputFormatter that automatically capitalizes tracking numbers
/// and auto-inserts hyphens for Sikkim legal aid formats (e.g. `SK-GTK-26-00013`)
/// while cleanly accommodating arbitrary manual input or legacy formats.
class TrackingNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Always convert to uppercase
    final upper = newValue.text.toUpperCase();

    // If user is deleting / backspacing, allow natural backspace
    if (newValue.text.length < oldValue.text.length) {
      return TextEditingValue(
        text: upper,
        selection: newValue.selection,
      );
    }

    // Clean alphanumeric characters only for smart auto-formatting
    final rawClean = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    // If string starts with "SK" and user is typing continuously without hyphens
    if (rawClean.startsWith('SK') && rawClean.length >= 2) {
      final buffer = StringBuffer('SK');

      // District segment (typically 3 letters like GTK, NCH, MGN, GYL, PKY, SRG)
      if (rawClean.length > 2) {
        buffer.write('-');
        final remaining = rawClean.substring(2);

        // Detect if district is 3 letters (or 2-4 letters)
        if (remaining.length <= 3) {
          buffer.write(remaining);
        } else {
          buffer.write(remaining.substring(0, 3));
          buffer.write('-');

          final afterDistrict = remaining.substring(3);
          // Year segment (2 digits, e.g. 26)
          if (afterDistrict.length <= 2) {
            buffer.write(afterDistrict);
          } else {
            buffer.write(afterDistrict.substring(0, 2));
            buffer.write('-');

            // Sequence / serial number (up to 6 digits)
            final serial = afterDistrict.substring(2);
            if (serial.length > 6) {
              buffer.write(serial.substring(0, 6));
            } else {
              buffer.write(serial);
            }
          }
        }
      }

      final formattedText = buffer.toString();
      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    // Fallback: If it does not start with SK (e.g. LA-2026-001 or other), just uppercase it
    return TextEditingValue(
      text: upper,
      selection: newValue.selection,
    );
  }
}
