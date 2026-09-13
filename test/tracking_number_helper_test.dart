import 'package:flutter_test/flutter_test.dart';
import 'package:nyaya_saathi/core/utils/tracking_number_formatter.dart';

void main() {
  group('TrackingNumberHelper Normalization', () {
    test('normalizes raw lowercase continuous input without hyphens', () {
      final res = TrackingNumberHelper.normalize('skgtk2600034');
      expect(res, equals('SK-GTK-26-00034'));
    });

    test('normalizes lowercase hyphenated input', () {
      final res = TrackingNumberHelper.normalize('sk-gtk-26-00034');
      expect(res, equals('SK-GTK-26-00034'));
    });

    test('normalizes space-separated input', () {
      final res = TrackingNumberHelper.normalize('sk gtk 26 00034');
      expect(res, equals('SK-GTK-26-00034'));
    });

    test('normalizes input with fixed district code and continuous digits', () {
      final res = TrackingNumberHelper.normalize('2600034', defaultDistrictCode: 'GTK');
      expect(res, equals('SK-GTK-26-00034'));
    });

    test('normalizes input with fixed district code and hyphenated digits', () {
      final res = TrackingNumberHelper.normalize('26-00034', defaultDistrictCode: 'GTK');
      expect(res, equals('SK-GTK-26-00034'));
    });

    test('normalizes input with fixed district code and spaced digits', () {
      final res = TrackingNumberHelper.normalize('26 00034', defaultDistrictCode: 'GTK');
      expect(res, equals('SK-GTK-26-00034'));
    });

    test('handles district aliases like NCH -> NAM, PKY -> PAK', () {
      final res1 = TrackingNumberHelper.normalize('sknch2600012');
      expect(res1, equals('SK-NAM-26-00012'));

      final res2 = TrackingNumberHelper.normalize('skpky2600012');
      expect(res2, equals('SK-PAK-26-00012'));
    });
  });

  group('RemainingDigitsFormatter', () {
    final formatter = RemainingDigitsFormatter();

    test('auto-formats 2 digits with hyphen', () {
      final val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '26'),
      );
      expect(val.text, equals('26-'));
    });

    test('formats continuous digits into year-sequence', () {
      final val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '2600034'),
      );
      expect(val.text, equals('26-00034'));
    });
  });

  group('TrackingNumberFormatter TextInputFormatter', () {
    final formatter = TrackingNumberFormatter();

    test('auto-hyphenates skgtk2600034 into SK-GTK-26-00034', () {
      final val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'skgtk2600034'),
      );
      expect(val.text, equals('SK-GTK-26-00034'));
    });

    test('formats space separated input cleanly', () {
      final val = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'sk gtk 26 00034'),
      );
      expect(val.text, equals('SK-GTK-26-00034'));
    });
  });
}
