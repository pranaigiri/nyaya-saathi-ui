import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyaya_saathi/core/localization/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization JSON Integrity & Key Parity Tests', () {
    late Map<String, dynamic> enJson;
    late Map<String, dynamic> neJson;
    late Map<String, dynamic> hiJson;

    setUpAll(() {
      final enFile = File('assets/translations/en.json');
      final neFile = File('assets/translations/ne.json');
      final hiFile = File('assets/translations/hi.json');

      expect(enFile.existsSync(), isTrue, reason: 'en.json must exist');
      expect(neFile.existsSync(), isTrue, reason: 'ne.json must exist');
      expect(hiFile.existsSync(), isTrue, reason: 'hi.json must exist');

      enJson = json.decode(enFile.readAsStringSync()) as Map<String, dynamic>;
      neJson = json.decode(neFile.readAsStringSync()) as Map<String, dynamic>;
      hiJson = json.decode(hiFile.readAsStringSync()) as Map<String, dynamic>;
    });

    test('all three translation files are valid non-empty JSON maps', () {
      expect(enJson.isNotEmpty, isTrue);
      expect(neJson.isNotEmpty, isTrue);
      expect(hiJson.isNotEmpty, isTrue);
      expect(enJson.keys.length, greaterThan(80));
    });

    test('ne.json matches en.json keys perfectly without missing or extra keys', () {
      final enKeys = enJson.keys.toSet();
      final neKeys = neJson.keys.toSet();

      final missingInNe = enKeys.difference(neKeys);
      final extraInNe = neKeys.difference(enKeys);

      expect(missingInNe, isEmpty, reason: 'Keys in en.json missing in ne.json: $missingInNe');
      expect(extraInNe, isEmpty, reason: 'Keys in ne.json not in en.json: $extraInNe');
    });

    test('hi.json matches en.json keys perfectly without missing or extra keys', () {
      final enKeys = enJson.keys.toSet();
      final hiKeys = hiJson.keys.toSet();

      final missingInHi = enKeys.difference(hiKeys);
      final extraInHi = hiKeys.difference(enKeys);

      expect(missingInHi, isEmpty, reason: 'Keys in en.json missing in hi.json: $missingInHi');
      expect(extraInHi, isEmpty, reason: 'Keys in hi.json not in en.json: $extraInHi');
    });

    test('no translation values are empty or blank strings', () {
      for (final entry in enJson.entries) {
        expect(entry.value.toString().trim().isNotEmpty, isTrue,
            reason: 'en.json has empty value for key: ${entry.key}');
      }
      for (final entry in neJson.entries) {
        expect(entry.value.toString().trim().isNotEmpty, isTrue,
            reason: 'ne.json has empty value for key: ${entry.key}');
      }
      for (final entry in hiJson.entries) {
        expect(entry.value.toString().trim().isNotEmpty, isTrue,
            reason: 'hi.json has empty value for key: ${entry.key}');
      }
    });

    test('AppLocalizations configuration exposes supported languages correctly', () {
      expect(AppLocalizations.supportedLanguageCodes, containsAll(['en', 'ne', 'hi']));
      expect(AppLocalizations.isLanguageSupported('en'), isTrue);
      expect(AppLocalizations.isLanguageSupported('ne'), isTrue);
      expect(AppLocalizations.isLanguageSupported('hi'), isTrue);
      expect(AppLocalizations.isLanguageSupported('unknown'), isFalse);

      final english = AppLocalizations.getLanguage('en');
      expect(english.nativeName, 'English');

      final nepali = AppLocalizations.getLanguage('ne');
      expect(nepali.nativeName, 'नेपाली');

      final hindi = AppLocalizations.getLanguage('hi');
      expect(hindi.nativeName, 'हिन्दी');
    });
  });
}
