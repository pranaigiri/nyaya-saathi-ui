import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../core/services/hive_draft_service.dart';
import '../core/localization/app_localizations.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _isFirstLaunch = true;

  Locale get locale => _locale;
  bool get isFirstLaunch => _isFirstLaunch;

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

  Future<void>? _initFuture;

  /// Idempotent init – safe to call multiple times (main.dart + SplashScreen).
  /// Memoized so repeat calls are free.
  Future<void> init() => _initFuture ??= _doInit();

  Future<void> _doInit() async {
    _isFirstLaunch = await HiveDraftService.isFirstLaunch();
    var langStr = await HiveDraftService.getLanguage();
    if (!AppLocalizations.isLanguageSupported(langStr)) {
      langStr = 'en';
    }
    _locale = Locale(langStr);
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    final code = AppLocalizations.isLanguageSupported(langCode) ? langCode : 'en';
    _locale = Locale(code);
    _isFirstLaunch = false;
    await HiveDraftService.setLanguage(code);
    notifyListeners();
  }

  Future<void> completeFirstLaunch(String langCode) async {
    final code = AppLocalizations.isLanguageSupported(langCode) ? langCode : 'en';
    _locale = Locale(code);
    _isFirstLaunch = false;
    await HiveDraftService.markFirstLaunchCompleted(code);
    notifyListeners();
  }
}
