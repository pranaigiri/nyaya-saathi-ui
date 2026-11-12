import 'package:flutter_test/flutter_test.dart';
import 'package:nyaya_saathi/core/services/sim_service.dart';
import 'package:nyaya_saathi/core/utils/phone_utils.dart';
import 'package:nyaya_saathi/data/repositories/application_repository.dart';

void main() {
  group('SimService & Phone Number Suggestions Unit Tests', () {
    test('SimCardInfo parses map correctly', () {
      final sim = SimCardInfo.fromMap({
        'slotIndex': 0,
        'carrierName': 'Jio 5G',
        'displayName': 'SIM 1 (Jio 5G)',
        'number': '+919876543210',
      });

      expect(sim.slotIndex, 0);
      expect(sim.carrierName, 'Jio 5G');
      expect(sim.displayName, 'SIM 1 (Jio 5G)');
      expect(sim.phoneNumber, '+919876543210');
    });

    test('SuggestedPhoneNumber equality is based on clean number', () {
      const s1 = SuggestedPhoneNumber(
        number: '9876543210',
        displayFormatted: '+91 98765 43210',
        label: 'SIM 1',
      );
      const s2 = SuggestedPhoneNumber(
        number: '9876543210',
        displayFormatted: '+91 98765 43210',
        label: 'Account Phone',
      );

      expect(s1, equals(s2));
    });

    test('getSuggestedPhoneNumbers creates suggestion from valid profile phone', () async {
      final list = await SimService.getSuggestedPhoneNumbers(
        profilePhone: '9832012345',
      );

      expect(list.length, 1);
      expect(list.first.number, '9832012345');
      expect(list.first.displayFormatted, '+91 98320 12345');
      expect(list.first.label, 'Saved Account Mobile');
    });

    test('getSuggestedPhoneNumbers normalizes +91 profile phone', () async {
      final list = await SimService.getSuggestedPhoneNumbers(
        profilePhone: '+91 98320 12345',
      );

      expect(list.length, 1);
      expect(list.first.number, '9832012345');
      expect(list.first.displayFormatted, '+91 98320 12345');
    });

    test('getSuggestedPhoneNumbers ignores invalid profile phone', () async {
      final list = await SimService.getSuggestedPhoneNumbers(
        profilePhone: '12345',
      );

      expect(list, isEmpty);
    });
  });

  group('Duplicate Callback Prevention & Queue Estimation Result Tests', () {
    test('QuickApplyResult parses successful non-duplicate submission', () {
      const result = QuickApplyResult(
        trackingNumber: 'SK-GTK-26-00010',
        isDuplicate: false,
        queuePosition: 3,
        totalPending: 8,
        estimatedWaitText: 'Within approximately 1–3 working hours',
        isReliableEstimate: true,
      );

      expect(result.trackingNumber, 'SK-GTK-26-00010');
      expect(result.isDuplicate, isFalse);
      expect(result.queuePosition, 3);
      expect(result.totalPending, 8);
      expect(result.estimatedWaitText, 'Within approximately 1–3 working hours');
      expect(result.isReliableEstimate, isTrue);
    });

    test('QuickApplyResult parses duplicate callback submission', () {
      const result = QuickApplyResult(
        trackingNumber: 'SK-GTK-26-00005',
        isDuplicate: true,
        queuePosition: 2,
        totalPending: 5,
        estimatedWaitText: 'Within approximately 3–5 working hours',
        isReliableEstimate: true,
      );

      expect(result.trackingNumber, 'SK-GTK-26-00005');
      expect(result.isDuplicate, isTrue);
      expect(result.queuePosition, 2);
      expect(result.totalPending, 5);
      expect(result.estimatedWaitText, 'Within approximately 3–5 working hours');
    });

    test('QuickApplyResult handles fallback estimation when insufficient historical data', () {
      const result = QuickApplyResult(
        trackingNumber: 'SK-GEN-26-00001',
        isDuplicate: true,
        queuePosition: 1,
        totalPending: 1,
        estimatedWaitText: null,
        isReliableEstimate: false,
      );

      expect(result.isDuplicate, isTrue);
      expect(result.estimatedWaitText, isNull);
      expect(result.isReliableEstimate, isFalse);
    });
  });

  group('PhoneUtils Display & Normalization Tests', () {
    test('formats valid 10-digit number to display format', () {
      expect(PhoneUtils.formatForDisplay('9876543210'), '+91 98765 43210');
    });

    test('formats number with +91 country code', () {
      expect(PhoneUtils.formatForDisplay('+919876543210'), '+91 98765 43210');
    });

    test('formats number with spaces and dashes', () {
      expect(PhoneUtils.formatForDisplay('+91-98765-43210'), '+91 98765 43210');
    });

    test('masks phone number correctly', () {
      expect(PhoneUtils.maskPhone('9876543210'), '******3210');
      expect(PhoneUtils.maskPhone('+91 98765 43210'), '******3210');
    });

    test('validates valid Indian mobile numbers', () {
      expect(PhoneUtils.validate('9832012345').isValid, isTrue);
      expect(PhoneUtils.validate('8765912345').isValid, isTrue);
      expect(PhoneUtils.validate('7001234567').isValid, isTrue);
      expect(PhoneUtils.validate('6001234567').isValid, isTrue);
    });

    test('rejects non-mobile and invalid patterns', () {
      expect(PhoneUtils.validate('5123456789').isValid, isFalse);
      expect(PhoneUtils.validate('9999999999').isValid, isFalse);
      expect(PhoneUtils.validate('9876543210').isValid, isFalse); // sequential
      expect(PhoneUtils.validate('1234567890').isValid, isFalse); // sequential
      expect(PhoneUtils.validate('98123').isValid, isFalse);
      expect(PhoneUtils.validate('').isValid, isFalse);
    });
  });
}
