import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/legal_aid_application.dart';
import '../data/repositories/application_repository.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApplicationRepository _repository;
  RealtimeChannel? _realtimeChannel;

  ApplicationProvider(this._repository);

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

  List<LegalAidApplication> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasFetched = false;

  List<LegalAidApplication> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _hasFetched && _applications.isEmpty && _errorMessage == null;

  /// Initial or manual fetch with loading indicator
  Future<void> fetchApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _applications = await _repository.getMyApplications();
      _hasFetched = true;
      _initRealtimeSubscription();
    } catch (e) {
      _errorMessage = 'Unable to load applications. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Silently update applications list in background (used for realtime updates)
  Future<void> fetchApplicationsSilently() async {
    try {
      final updatedList = await _repository.getMyApplications();
      _applications = updatedList;
      _hasFetched = true;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('[ApplicationProvider] Realtime silent refresh failed: $e');
    }
  }

  /// Initialize realtime subscription to legal_aid_application
  void _initRealtimeSubscription() {
    if (_realtimeChannel != null) return;

    try {
      _realtimeChannel = _repository.subscribeToApplications(
        onData: (payload) {
          // ignore: avoid_print
          print('[ApplicationProvider] Realtime change detected: ${payload.eventType}');
          fetchApplicationsSilently();
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('[ApplicationProvider] Could not subscribe to realtime: $e');
    }
  }

  /// Ensure realtime subscription is active
  void subscribeToRealtime() {
    _initRealtimeSubscription();
  }

  Future<void> refresh() async {
    _hasFetched = false;
    await fetchApplications();
  }

  void clear() {
    _cleanupRealtime();
    _applications = [];
    _hasFetched = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _cleanupRealtime() {
    if (_realtimeChannel != null) {
      _repository.unsubscribe(_realtimeChannel!);
      _realtimeChannel = null;
    }
  }

  @override
  void dispose() {
    _cleanupRealtime();
    super.dispose();
  }
}

