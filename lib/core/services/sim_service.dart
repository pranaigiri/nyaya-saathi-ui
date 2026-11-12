import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/phone_utils.dart';

/// Information about a device's SIM card.
class SimCardInfo {
  final int slotIndex;
  final String carrierName;
  final String displayName;
  final String? phoneNumber;

  const SimCardInfo({
    required this.slotIndex,
    required this.carrierName,
    required this.displayName,
    this.phoneNumber,
  });

  factory SimCardInfo.fromMap(Map<dynamic, dynamic> map) {
    return SimCardInfo(
      slotIndex: (map['slotIndex'] as num?)?.toInt() ?? 0,
      carrierName: (map['carrierName'] as String?) ?? '',
      displayName: (map['displayName'] as String?) ?? 'SIM ${(map['slotIndex'] as num?)?.toInt() ?? 1}',
      phoneNumber: map['number'] as String?,
    );
  }
}

/// A suggested phone number ready for citizen selection.
class SuggestedPhoneNumber {
  final String number; // Clean 10 digits
  final String displayFormatted; // e.g. +91 98765 43210
  final String label; // e.g. "SIM 1 (Jio)" or "Account Mobile"
  final String? carrier;
  final bool isFromSim;

  const SuggestedPhoneNumber({
    required this.number,
    required this.displayFormatted,
    required this.label,
    this.carrier,
    this.isFromSim = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestedPhoneNumber &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;
}

/// Service providing native SIM card queries and effortless phone number suggestions.
class SimService {
  static const MethodChannel _channel =
      MethodChannel('com.sikkim.slsa.nyaya_saathi/sim_service');

  /// Detects active SIM subscriptions on Android devices.
  static Future<List<SimCardInfo>> getSimCards() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return [];
    }

    try {
      final List<dynamic>? result =
          await _channel.invokeMethod<List<dynamic>>('getSimCards');
      if (result == null) return [];

      return result
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => SimCardInfo.fromMap(m))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Gathers all available phone number suggestions without requesting sensitive permissions.
  ///
  /// Combines:
  /// 1. Logged-in profile phone number (if authenticated)
  /// 2. Active SIM card number(s) if provided by Android telephony
  ///
  /// Returns a deduplicated list of valid Indian mobile numbers.
  static Future<List<SuggestedPhoneNumber>> getSuggestedPhoneNumbers({
    String? profilePhone,
  }) async {
    final suggestions = <SuggestedPhoneNumber>[];
    final seenNumbers = <String>{};

    // 1. Profile / Account Phone
    if (profilePhone != null && profilePhone.trim().isNotEmpty) {
      final clean = PhoneUtils.normalize(profilePhone);
      final validation = PhoneUtils.validate(clean);
      if (validation.isValid && !seenNumbers.contains(clean)) {
        seenNumbers.add(clean);
        suggestions.add(
          SuggestedPhoneNumber(
            number: clean,
            displayFormatted: PhoneUtils.formatForDisplay(clean),
            label: 'Saved Account Mobile',
            isFromSim: false,
          ),
        );
      }
    }

    // 2. Query native SIMs if on Android
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final simCards = await getSimCards();
        for (final sim in simCards) {
          if (sim.phoneNumber != null && sim.phoneNumber!.isNotEmpty) {
            final clean = PhoneUtils.normalize(sim.phoneNumber);
            final validation = PhoneUtils.validate(clean);
            if (validation.isValid && !seenNumbers.contains(clean)) {
              seenNumbers.add(clean);
              suggestions.add(
                SuggestedPhoneNumber(
                  number: clean,
                  displayFormatted: PhoneUtils.formatForDisplay(clean),
                  label: sim.displayName,
                  carrier: sim.carrierName.isNotEmpty ? sim.carrierName : null,
                  isFromSim: true,
                ),
              );
            }
          }
        }
      } catch (_) {
        // Fallback gracefully
      }
    }

    return suggestions;
  }
}

