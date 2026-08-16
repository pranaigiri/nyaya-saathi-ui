import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../core/services/hive_draft_service.dart';

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

  Future<void> init() async {
    _isFirstLaunch = await HiveDraftService.isFirstLaunch();
    final langStr = await HiveDraftService.getLanguage();
    _locale = Locale(langStr);
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    _locale = Locale(langCode);
    _isFirstLaunch = false;
    await HiveDraftService.setLanguage(langCode);
    notifyListeners();
  }

  Future<void> completeFirstLaunch(String langCode) async {
    _locale = Locale(langCode);
    _isFirstLaunch = false;
    await HiveDraftService.markFirstLaunchCompleted(langCode);
    notifyListeners();
  }
}
