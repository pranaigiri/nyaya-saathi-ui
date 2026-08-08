import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../core/services/hive_draft_service.dart';
import '../core/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  AppFontScale _fontScale = AppFontScale.medium;

  ThemeMode get themeMode => _themeMode;
  AppFontScale get fontScale => _fontScale;

  @override
  void notifyListeners() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        super.notifyListeners();
      });
    } else {
      super.notifyListeners();
    }
  }

  Future<void> loadPreferences() async {
    final themeStr = await HiveDraftService.getTheme();
    if (themeStr == 'light') _themeMode = ThemeMode.light;
    else if (themeStr == 'dark') _themeMode = ThemeMode.dark;
    else _themeMode = ThemeMode.system;

    final fontStr = await HiveDraftService.getFontScale();
    if (fontStr == 'small') _fontScale = AppFontScale.small;
    else if (fontStr == 'large') _fontScale = AppFontScale.large;
    else _fontScale = AppFontScale.medium;

    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    String str = 'system';
    if (mode == ThemeMode.light) str = 'light';
    if (mode == ThemeMode.dark) str = 'dark';
    HiveDraftService.setTheme(str);
    notifyListeners();
  }

  void setFontScale(AppFontScale scale) {
    _fontScale = scale;
    String str = 'medium';
    if (scale == AppFontScale.small) str = 'small';
    if (scale == AppFontScale.large) str = 'large';
    HiveDraftService.setFontScale(str);
    notifyListeners();
  }
}
