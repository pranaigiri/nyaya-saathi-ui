import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLanguage {
  final String code;
  final String nativeName;
  final String englishName;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
    this.flag = '🇮🇳',
  });
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// Centralized list of supported languages.
  /// Adding a future language only requires appending an AppLanguage here
  /// and placing the corresponding `<langCode>.json` file in assets/translations/.
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'en', nativeName: 'English', englishName: 'English'),
    AppLanguage(code: 'ne', nativeName: 'नेपाली', englishName: 'Nepali'),
    AppLanguage(code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi'),
  ];

  static List<Locale> get supportedLocales =>
      supportedLanguages.map((l) => Locale(l.code)).toList();

  static List<String> get supportedLanguageCodes =>
      supportedLanguages.map((l) => l.code).toList();

  static bool isLanguageSupported(String languageCode) =>
      supportedLanguageCodes.contains(languageCode);

  static AppLanguage getLanguage(String code) =>
      supportedLanguages.firstWhere(
        (l) => l.code == code,
        orElse: () => supportedLanguages.first,
      );

  late Map<String, String> _localizedStrings;
  static Map<String, String>? _fallbackStrings;

  /// Loads the language translations from the JSON asset file.
  /// Automatically ensures English fallback strings are loaded so missing
  /// keys in non-English locales fall back gracefully to English.
  Future<bool> load() async {
    // Ensure English fallback strings are loaded once
    if (_fallbackStrings == null) {
      try {
        final fallbackJson = await rootBundle.loadString('assets/translations/en.json');
        final Map<String, dynamic> fallbackMap = json.decode(fallbackJson);
        _fallbackStrings = fallbackMap.map((k, v) => MapEntry(k, v.toString()));
      } catch (_) {
        _fallbackStrings = {};
      }
    }

    try {
      final jsonString = await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
    } catch (_) {
      // If requested language file fails to load, fall back to English
      _localizedStrings = _fallbackStrings ?? {};
    }

    return true;
  }

  /// Translates a given key with fallback to English and then to the raw key.
  String translate(String key) {
    final value = _localizedStrings[key];
    if (value != null && value.isNotEmpty) {
      return value;
    }
    final fallback = _fallbackStrings?[key];
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.isLanguageSupported(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension TranslateExtension on BuildContext {
  /// Looks up localized string by key with optional fallback and parameter interpolation.
  /// Example: `context.tr('filed_on', args: {'date': '25 Oct 2026'})`
  String tr(String key, {String? fallback, Map<String, String>? args}) {
    String translated = AppLocalizations.of(this)?.translate(key) ?? (fallback ?? key);
    if (translated == key && fallback != null) {
      translated = fallback;
    }
    if (args != null && args.isNotEmpty) {
      args.forEach((k, v) {
        translated = translated.replaceAll('{$k}', v);
      });
    }
    return translated;
  }
}
