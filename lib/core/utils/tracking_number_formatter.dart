import 'package:flutter/services.dart';

/// Information about a Sikkim District with official and legacy/alias codes.
class SikkimDistrict {
  final String name;
  final String code; // Primary DB code (e.g. GTK, NAM, PAK, MAN, GYL, SOR)
  final List<String> aliases;

  const SikkimDistrict({
    required this.name,
    required this.code,
    this.aliases = const [],
  });

  /// True if [inputCode] matches primary code or any alias
  bool matches(String inputCode) {
    final clean = inputCode.trim().toUpperCase();
    return code == clean || aliases.any((a) => a.toUpperCase() == clean);
  }
}

/// Helper utilities for tracking numbers in Sikkim Legal Aid Services.
class TrackingNumberHelper {
  static const List<SikkimDistrict> sikkimDistricts = [
    SikkimDistrict(name: 'Gangtok', code: 'GTK', aliases: ['GTK']),
    SikkimDistrict(name: 'Namchi', code: 'NAM', aliases: ['NAM', 'NCH']),
    SikkimDistrict(name: 'Pakyong', code: 'PAK', aliases: ['PAK', 'PKY']),
    SikkimDistrict(name: 'Mangan', code: 'MAN', aliases: ['MAN', 'MGN']),
    SikkimDistrict(name: 'Gyalshing', code: 'GYL', aliases: ['GYL']),
    SikkimDistrict(name: 'Soreng', code: 'SOR', aliases: ['SOR', 'SRG']),
  ];

  /// Find district by code or alias
  static SikkimDistrict? findDistrict(String codeOrAlias) {
    final clean = codeOrAlias.trim().toUpperCase();
    for (final dist in sikkimDistricts) {
      if (dist.matches(clean)) return dist;
    }
    return null;
  }

  /// Get current 2-digit year (e.g. '26' for 2026)
  static String get currentYearDigits {
    return (DateTime.now().year % 100).toString().padLeft(2, '0');
  }

  /// Normalizes any user input into canonical format: `SK-[DISTRICT]-[YY]-[SEQUENCE]`
  ///
  /// Handles:
  /// - `skgtk2600034` -> `SK-GTK-26-00034`
  /// - `sk-gtk-26-00034` -> `SK-GTK-26-00034`
  /// - `sk gtk 26 00034` -> `SK-GTK-26-00034`
  /// - `2600034` with districtCode='GTK' -> `SK-GTK-26-00034`
  /// - `26-00034` with districtCode='GTK' -> `SK-GTK-26-00034`
  /// - `26 00034` with districtCode='GTK' -> `SK-GTK-26-00034`
  /// - `00034` with districtCode='GTK' -> `SK-GTK-26-00034` (defaults to current year)
  static String normalize(String rawInput, {String? defaultDistrictCode}) {
    if (rawInput.trim().isEmpty) return '';

    var clean = rawInput.trim().toUpperCase();

    // If defaultDistrictCode is supplied, check if input is just the remaining digits
    if (defaultDistrictCode != null && defaultDistrictCode.isNotEmpty) {
      final dist = findDistrict(defaultDistrictCode);
      final distCode = dist?.code ?? defaultDistrictCode.toUpperCase();

      // Remove SK and district prefix if user redundantly entered them
      if (clean.startsWith('SK-')) {
        clean = clean.substring(3);
      } else if (clean.startsWith('SK')) {
        clean = clean.substring(2);
      }
      if (clean.startsWith('$distCode-')) {
        clean = clean.substring(distCode.length + 1);
      } else if (clean.startsWith(distCode)) {
        clean = clean.substring(distCode.length);
      }

      // Strip non-alphanumeric except hyphen
      final rawDigits = clean.replaceAll(RegExp(r'[^0-9]'), '');
      if (rawDigits.isEmpty) return 'SK-$distCode-';

      // Parse year and sequence
      String year = currentYearDigits;
      String seq = rawDigits;

      if (rawDigits.length >= 7) {
        // e.g. 2600034 -> year 26, seq 00034
        year = rawDigits.substring(0, 2);
        seq = rawDigits.substring(2);
      } else if (clean.contains('-')) {
        final parts = clean.split('-').where((p) => p.isNotEmpty).toList();
        if (parts.length >= 2) {
          year = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
          seq = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
        }
      } else if (clean.contains(' ')) {
        final parts = clean.split(' ').where((p) => p.isNotEmpty).toList();
        if (parts.length >= 2) {
          year = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
          seq = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
        }
      }

      // Sequence formatted with at least 5 digits if needed
      final paddedSeq = seq.length < 5 ? seq.padLeft(5, '0') : seq;
      return 'SK-$distCode-$year-$paddedSeq';
    }

    // Direct input normalization without pre-selected district
    // Clean alphanumeric characters
    final alphanumericOnly = clean.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (alphanumericOnly.isEmpty) return clean;

    var text = alphanumericOnly;
    // Strip leading SK if present
    if (text.startsWith('SK')) {
      text = text.substring(2);
    }

    // Identify district (3 letters)
    String distCode = 'GTK';
    if (text.length >= 3) {
      final potentialDist = text.substring(0, 3);
      final matched = findDistrict(potentialDist);
      if (matched != null) {
        distCode = matched.code;
        text = text.substring(3);
      } else {
        // Check 2 to 4 letters
        distCode = potentialDist;
        text = text.substring(3);
      }
    }

    // Remaining text should be digits: year (2 digits) + seq
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return 'SK-$distCode';
    }

    String year = currentYearDigits;
    String seq = digits;

    if (digits.length >= 2) {
      year = digits.substring(0, 2);
      seq = digits.substring(2);
    }

    if (seq.isEmpty) {
      return 'SK-$distCode-$year';
    }

    final paddedSeq = seq.length < 5 ? seq.padLeft(5, '0') : seq;
    return 'SK-$distCode-$year-$paddedSeq';
  }

  /// Checks if tracking number is canonically valid (SK-XXX-YY-ZZZZZ)
  static bool isValid(String trackingNumber) {
    final reg = RegExp(r'^SK-[A-Z]{3,4}-\d{2}-\d{4,6}$');
    return reg.hasMatch(trackingNumber.trim());
  }

  /// Returns district aliases for backend RPC fallback queries
  /// (e.g. if searching with NAM, also try NCH; if PKY, try PAK)
  static List<String> getAlternativeTrackingNumbers(String canonicalTrackingNumber) {
    final results = <String>[canonicalTrackingNumber];
    final parts = canonicalTrackingNumber.split('-');
    if (parts.length >= 4) {
      final distCode = parts[1];
      final dist = findDistrict(distCode);
      if (dist != null) {
        for (final alias in dist.aliases) {
          if (alias != distCode) {
            results.add('SK-$alias-${parts[2]}-${parts[3]}');
          }
        }
      }
    }
    return results;
  }
}

/// Formatter for the remaining digits (year + sequence) when district is fixed.
/// Accepts: `2600034`, `26-00034`, `26 00034`, etc.
/// Automatically formats to `26-00034`.
class RemainingDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // If user is deleting / backspacing, allow natural backspace
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // Only allow digits, hyphens, and spaces
    final clean = newValue.text.replaceAll(RegExp(r'[^0-9\s\-]'), '');
    // Pure digits
    final digits = clean.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue();
    }

    final buffer = StringBuffer();

    // Year segment (up to 2 digits)
    if (digits.length <= 2) {
      buffer.write(digits);
      // If user typed exactly 2 digits, auto-append hyphen for intuitive UX
      if (digits.length == 2 && !newValue.text.endsWith('-')) {
        buffer.write('-');
      }
    } else {
      buffer.write(digits.substring(0, 2));
      buffer.write('-');

      // Sequence segment (up to 6 digits)
      final remaining = digits.substring(2);
      if (remaining.length > 6) {
        buffer.write(remaining.substring(0, 6));
      } else {
        buffer.write(remaining);
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// A smart TextInputFormatter that automatically capitalizes tracking numbers
/// and auto-inserts hyphens for Sikkim legal aid formats (e.g. `SK-GTK-26-00034`)
/// while cleanly accommodating arbitrary manual input, continuous typing without hyphens,
/// or spaces.
class TrackingNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // If user is deleting / backspacing, allow natural backspace
    if (newValue.text.length < oldValue.text.length) {
      return TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
      );
    }

    // Always convert to uppercase and strip non-alphanumeric characters
    final upper = newValue.text.toUpperCase();
    final rawClean = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (rawClean.isEmpty) {
      return const TextEditingValue();
    }

    // If string starts with "SK" or user starts typing district directly
    if (rawClean.startsWith('SK')) {
      final buffer = StringBuffer('SK');

      if (rawClean.length > 2) {
        buffer.write('-');
        final afterSk = rawClean.substring(2);

        // District code (typically 3 letters: GTK, NAM, PAK, MAN, GYL, SOR)
        // Detect letters
        final letterMatch = RegExp(r'^[A-Z]+').firstMatch(afterSk);
        final districtLetters = letterMatch?.group(0) ?? '';

        if (districtLetters.length <= 3 && afterSk.length == districtLetters.length) {
          buffer.write(districtLetters);
          // If district code is completed (3 chars), auto-append hyphen
          if (districtLetters.length == 3) {
            buffer.write('-');
          }
        } else {
          final distCode = districtLetters.length >= 3
              ? districtLetters.substring(0, 3)
              : districtLetters;
          buffer.write(distCode);
          buffer.write('-');

          final afterDistrict = afterSk.substring(distCode.length);
          final digitsOnly = afterDistrict.replaceAll(RegExp(r'[^0-9]'), '');

          // Year segment (2 digits, e.g. 26)
          if (digitsOnly.length <= 2) {
            buffer.write(digitsOnly);
            if (digitsOnly.length == 2) {
              buffer.write('-');
            }
          } else {
            buffer.write(digitsOnly.substring(0, 2));
            buffer.write('-');

            // Sequence / serial number (up to 6 digits)
            final serial = digitsOnly.substring(2);
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

    // If user starts typing district directly (e.g. "GTK2600034" without "SK")
    final matchDist = TrackingNumberHelper.findDistrict(rawClean.substring(0, rawClean.length.clamp(0, 3)));
    if (matchDist != null && rawClean.length >= 3) {
      final buffer = StringBuffer('SK-');
      final distCode = matchDist.code;
      buffer.write(distCode);
      buffer.write('-');

      final afterDistrict = rawClean.substring(3);
      final digitsOnly = afterDistrict.replaceAll(RegExp(r'[^0-9]'), '');

      if (digitsOnly.length <= 2) {
        buffer.write(digitsOnly);
        if (digitsOnly.length == 2) {
          buffer.write('-');
        }
      } else {
        buffer.write(digitsOnly.substring(0, 2));
        buffer.write('-');
        final serial = digitsOnly.substring(2);
        if (serial.length > 6) {
          buffer.write(serial.substring(0, 6));
        } else {
          buffer.write(serial);
        }
      }

      final formattedText = buffer.toString();
      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    // Fallback: uppercase text
    return TextEditingValue(
      text: upper,
      selection: newValue.selection,
    );
  }
}
