import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _userPhoneOrEmail = '';
  String _userName = 'Citizen User';

  bool get isAuthenticated => _isAuthenticated;
  String get userPhoneOrEmail => _userPhoneOrEmail;
  String get userName => _userName;

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

  void loginAsCitizen(String identity) {
    _isAuthenticated = true;
    _userPhoneOrEmail = identity;
    _userName = identity.contains('@') ? identity.split('@')[0] : 'Citizen ($identity)';
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userPhoneOrEmail = '';
    _userName = 'Citizen User';
    notifyListeners();
  }
}
