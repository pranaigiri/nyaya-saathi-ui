/// Utility class for Indian phone number normalization and validation.
///
/// Matches the backend Edge Function validation in `supabase/functions/_shared/validation.ts`.
class PhoneUtils {
  static const List<String> _sequentialPatterns = [
    '1234567890',
    '0123456789',
    '9876543210',
    '0987654321',
  ];

  /// Normalizes a phone input to a clean 10-digit Indian mobile number.
  ///
  /// Strips non-digit characters, removes leading +91 or 91 country codes,
  /// and trims leading zeros or takes the last 10 digits if longer.
  static String normalize(String? phone) {
    if (phone == null) return '';
    var clean = phone.replaceAll(RegExp(r'\D'), '');

    if (clean.length > 10 && clean.startsWith('91')) {
      clean = clean.substring(2);
    } else if (clean.length > 10) {
      clean = clean.substring(clean.length - 10);
    }

    return clean;
  }

  /// Validates whether a phone number string meets all statutory mobile criteria.
  ///
  /// Requirements:
  /// - Exactly 10 digits
  /// - Starts with 6, 7, 8, or 9
  /// - Not all identical digits (e.g. 9999999999)
  /// - Not sequential series (e.g. 1234567890, 9876543210)
  static PhoneValidationResult validate(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return const PhoneValidationResult(
        isValid: false,
        reason: 'Phone number is required',
      );
    }

    final clean = normalize(phone);

    if (clean.length != 10) {
      return const PhoneValidationResult(
        isValid: false,
        reason: 'Phone number must be exactly 10 digits',
      );
    }

    if (!RegExp(r'^[6-9]').hasMatch(clean)) {
      return const PhoneValidationResult(
        isValid: false,
        reason: 'Mobile number must start with 6, 7, 8, or 9',
      );
    }

    if (RegExp(r'^(\d)\1{9}$').hasMatch(clean)) {
      return const PhoneValidationResult(
        isValid: false,
        reason: 'Phone number cannot consist of identical repeated digits',
      );
    }

    if (_sequentialPatterns.contains(clean)) {
      return const PhoneValidationResult(
        isValid: false,
        reason: 'Phone number cannot be a sequential series of digits',
      );
    }

    return PhoneValidationResult(
      isValid: true,
      normalized: clean,
    );
  }

  /// Masks a phone number displaying only the last 4 digits (e.g., "******1234").
  static String maskPhone(String? phone) {
    final clean = normalize(phone);
    if (clean.length < 4) return '******';
    final last4 = clean.substring(clean.length - 4);
    return '******$last4';
  }
}

class PhoneValidationResult {
  final bool isValid;
  final String? normalized;
  final String? reason;

  const PhoneValidationResult({
    required this.isValid,
    this.normalized,
    this.reason,
  });
}
