import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isAdvocate = false;
  String _userPhoneOrEmail = '';
  String _userName = 'Citizen User';

  bool get isAuthenticated => _isAuthenticated;
  bool get isAdvocate => _isAdvocate;
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
    _isAdvocate = false;
    _userPhoneOrEmail = identity;
    _userName = identity.contains('@') ? identity.split('@')[0] : 'Citizen ($identity)';
    notifyListeners();
  }

  void loginAsAdvocate(String identity) {
    _isAuthenticated = true;
    _isAdvocate = true;
    _userPhoneOrEmail = identity;
    _userName = "Adv. Tashi Bhutia";
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _isAdvocate = false;
    _userPhoneOrEmail = '';
    _userName = 'Citizen User';
    notifyListeners();
  }
}
