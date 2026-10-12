import 'package:flutter_test/flutter_test.dart';
import 'package:nyaya_saathi/core/utils/phone_utils.dart';

void main() {
  group('PhoneUtils.normalize', () {
    test('normalizes standard 10 digit number', () {
      expect(PhoneUtils.normalize('9876543210'), equals('9876543210'));
    });

    test('strips +91 prefix and whitespace/hyphens', () {
      expect(PhoneUtils.normalize('+91 98765-43210'), equals('9876543210'));
      expect(PhoneUtils.normalize('91-9876543210'), equals('9876543210'));
    });

    test('handles leading zero or spaces', () {
      expect(PhoneUtils.normalize(' 09876543210 '), equals('9876543210'));
    });

    test('handles null and empty strings gracefully', () {
      expect(PhoneUtils.normalize(null), equals(''));
      expect(PhoneUtils.normalize(''), equals(''));
    });
  });

  group('PhoneUtils.validate', () {
    test('validates valid Indian mobile numbers starting with 6, 7, 8, 9', () {
      final res6 = PhoneUtils.validate('6123456789');
      expect(res6.isValid, isTrue);
      expect(res6.normalized, equals('6123456789'));

      final res7 = PhoneUtils.validate('7890123456');
      expect(res7.isValid, isTrue);

      final res8 = PhoneUtils.validate('8901234567');
      expect(res8.isValid, isTrue);

      final res9 = PhoneUtils.validate('9812345678');
      expect(res9.isValid, isTrue);
    });

    test('rejects numbers starting with invalid digits (0-5)', () {
      final res1 = PhoneUtils.validate('5123456789');
      expect(res1.isValid, isFalse);

      final res2 = PhoneUtils.validate('0123456789');
      expect(res2.isValid, isFalse);
    });

    test('rejects numbers of incorrect length', () {
      expect(PhoneUtils.validate('98765').isValid, isFalse);
      expect(PhoneUtils.validate('').isValid, isFalse);
      expect(PhoneUtils.validate(null).isValid, isFalse);
    });

    test('rejects identical repeating digits', () {
      expect(PhoneUtils.validate('9999999999').isValid, isFalse);
      expect(PhoneUtils.validate('8888888888').isValid, isFalse);
      expect(PhoneUtils.validate('7777777777').isValid, isFalse);
    });

    test('rejects sequential digits series', () {
      expect(PhoneUtils.validate('9876543210').isValid, isFalse);
      expect(PhoneUtils.validate('1234567890').isValid, isFalse);
    });
  });

  group('PhoneUtils.maskPhone', () {
    test('masks standard 10-digit number showing last 4 digits', () {
      expect(PhoneUtils.maskPhone('9876543219'), equals('******3219'));
      expect(PhoneUtils.maskPhone('+91 98765 43219'), equals('******3219'));
    });

    test('handles short numbers gracefully', () {
      expect(PhoneUtils.maskPhone('12'), equals('******'));
      expect(PhoneUtils.maskPhone(null), equals('******'));
    });
  });
}
