import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/draft_application_model.dart';

class HiveDraftService {
  static const String _draftKey = 'nyaya_saathi_active_draft_v1';
  static const String _prefLanguageKey = 'nyaya_saathi_pref_lang';
  static const String _prefThemeKey = 'nyaya_saathi_pref_theme';
  static const String _prefFontScaleKey = 'nyaya_saathi_pref_font_scale';
  static const String _prefInfoModalSeenKey = 'nyaya_saathi_info_modal_seen';

  // Single preference record flag check
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_prefInfoModalSeenKey) ?? false);
  }

  static Future<void> markFirstLaunchCompleted(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageKey, languageCode);
    await prefs.setBool(_prefInfoModalSeenKey, true);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefLanguageKey) ?? 'en';
  }

  static Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageKey, lang);
  }

  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefThemeKey) ?? 'system';
  }

  static Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefThemeKey, theme);
  }

  static Future<String> getFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefFontScaleKey) ?? 'medium';
  }

  static Future<void> setFontScale(String scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefFontScaleKey, scale);
  }

  // Draft operations
  static Future<DraftApplicationModel?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_draftKey);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final Map<String, dynamic> map = json.decode(jsonString);
      return DraftApplicationModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<DraftApplicationModel> createOrGetDraft() async {
    final existing = await getDraft();
    if (existing != null) return existing;

    final newDraft = DraftApplicationModel(draftUuid: const Uuid().v4());
    await saveDraft(newDraft);
    return newDraft;
  }

  static Future<void> saveDraft(DraftApplicationModel draft) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(draft.toJson());
    await prefs.setString(_draftKey, jsonString);
  }

  static Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }
}
