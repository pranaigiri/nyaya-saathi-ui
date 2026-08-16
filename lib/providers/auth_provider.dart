import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/notification_service.dart';
import '../models/profile.dart';

class AuthProvider extends ChangeNotifier {
  Profile? _profile;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSubscription;

  Profile? get profile => _profile;
  bool get isAuthenticated => Supabase.instance.client.auth.currentUser != null && _profile != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userName => _profile?.fullName ?? 'Citizen User';
  String get userEmail => _profile?.email ?? currentUser?.email ?? '';
  String get userPhoneOrEmail => _profile?.phoneNumber ?? _profile?.email ?? currentUser?.email ?? '';
  User? get currentUser => Supabase.instance.client.auth.currentUser;

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

  void listenToAuthChanges() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        _profile = null;
        notifyListeners();
      } else if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        NotificationService.instance.syncTokenWithBackend();
      }
    });
  }

  /// Attempt to restore existing session on app startup.
  /// Returns: 'citizen' if valid citizen session, 'non_citizen' if non-citizen, 'none' if no session.
  Future<String> restoreSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        _isLoading = false;
        notifyListeners();
        return 'none';
      }

      // Fetch profile to validate role
      final result = await _fetchProfile();
      if (result == 'citizen') {
        NotificationService.instance.syncTokenWithBackend();
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to restore session';
      notifyListeners();
      return 'none';
    }
  }

  /// Sign in with email and password
  Future<String> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Fetch and validate profile
      final result = await _fetchProfile();
      _isLoading = false;

      if (result == 'citizen') {
        NotificationService.instance.syncTokenWithBackend();
      } else if (result == 'non_citizen') {
        _errorMessage = 'Access denied. Only citizens may use this application.';
        await signOut(silent: true);
      }

      notifyListeners();
      return result;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = _mapAuthError(e);
      notifyListeners();
      return 'error';
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Unable to connect. Please check your internet connection.';
      notifyListeners();
      return 'error';
    }
  }

  /// Register a new citizen user with email, password, full name, and optional phone
  /// Returns: 'citizen' if logged in immediately, 'confirmation_required' if email confirmation is required, 'error' on failure
  Future<String> registerCitizen({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{
        'full_name': fullName.trim(),
      };
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        data['phone_number'] = phoneNumber.trim();
      }

      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: data,
      );

      if (response.session != null) {
        // User is immediately authenticated
        final result = await _fetchProfile();
        _isLoading = false;
        if (result == 'citizen') {
          NotificationService.instance.syncTokenWithBackend();
        }
        notifyListeners();
        return result == 'citizen' ? 'citizen' : 'error';
      } else if (response.user != null) {
        // User created, confirmation email sent
        _isLoading = false;
        notifyListeners();
        return 'confirmation_required';
      } else {
        _isLoading = false;
        _errorMessage = 'Registration could not be completed. Please try again.';
        notifyListeners();
        return 'error';
      }
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = _mapAuthError(e);
      notifyListeners();
      return 'error';
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Unable to connect. Please check your internet connection.';
      notifyListeners();
      return 'error';
    }
  }

  /// Alias for backward compatibility with older UI calls
  Future<void> loginAsCitizen(String identifier) async {
    // Used if any legacy screen calls loginAsCitizen
  }

  /// Fetch profile from DB using get_my_profile() RPC
  Future<String> _fetchProfile() async {
    try {
      final response = await Supabase.instance.client.rpc('get_my_profile');

      if (response == null) {
        _profile = null;
        return 'none';
      }

      final profile = Profile.fromJson(response as Map<String, dynamic>);

      if (!profile.isCitizen) {
        _profile = null;
        return 'non_citizen';
      }

      if (!profile.isActive) {
        _profile = null;
        _errorMessage = 'Your account has been suspended. Please contact SLSA.';
        return 'error';
      }

      _profile = profile;
      return 'citizen';
    } catch (e) {
      // If RPC fails, try direct table query
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) return 'none';

        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (response == null) return 'none';

        final profile = Profile.fromJson(response);
        if (!profile.isCitizen) return 'non_citizen';
        if (!profile.isActive) {
          _errorMessage = 'Your account has been suspended. Please contact SLSA.';
          return 'error';
        }

        _profile = profile;
        return 'citizen';
      } catch (_) {
        return 'error';
      }
    }
  }

  /// Sign out / logout
  Future<void> signOut({bool silent = false}) async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Ignore sign out errors
    }
    _profile = null;
    _errorMessage = null;
    if (!silent) {
      notifyListeners();
    }
  }

  Future<void> logout() => signOut();

  /// Update profile fields
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? dob,
    String? gender,
    String? villageOrTown,
    String? districtId,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return false;

    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName.trim();
      if (phoneNumber != null) updates['phone_number'] = phoneNumber.trim();
      if (email != null) updates['email'] = email.trim();
      if (dob != null) updates['dob'] = dob.trim();
      if (gender != null) updates['gender'] = gender.trim();
      if (villageOrTown != null) updates['village_or_town'] = villageOrTown.trim();
      if (districtId != null) updates['district_id'] = districtId;
      updates['updated_at'] = DateTime.now().toIso8601String();

      if (updates.isEmpty) return true;

      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', userId);

      // Refresh profile
      await _fetchProfile();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile. Please try again.';
      notifyListeners();
      return false;
    }
  }

  String _mapAuthError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (msg.contains('already registered') || msg.contains('user already exists') || msg.contains('email already in use')) {
      return 'An account with this email already exists. Please sign in instead.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please confirm your email address first.';
    }
    if (msg.contains('password') && (msg.contains('least 6') || msg.contains('weak') || msg.contains('short'))) {
      return 'Password should be at least 6 characters long.';
    }
    if (msg.contains('too many requests') || msg.contains('rate_limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return 'Authentication error: ${e.message}';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
