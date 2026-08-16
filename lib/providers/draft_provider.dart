import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/draft_application_model.dart';
import '../models/document_master.dart';
import '../core/services/hive_draft_service.dart';
import '../data/repositories/application_repository.dart';
import 'apply_data_provider.dart';

import '../models/profile.dart';

class DraftProvider extends ChangeNotifier {
  DraftApplicationModel? _draft;
  List<DocumentMaster> _requiredDocuments = [];
  bool _isLoading = false;
  ApplyDataProvider? _applyDataProvider;
  final ApplicationRepository _appRepo = ApplicationRepository();

  DraftApplicationModel? get draft => _draft;
  List<DocumentMaster> get requiredDocuments => _requiredDocuments;
  bool get isLoading => _isLoading;

  void setApplyDataProvider(ApplyDataProvider provider) {
    _applyDataProvider = provider;
  }

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

  Future<void> loadDraft() async {
    _isLoading = true;
    notifyListeners();

    _draft = await HiveDraftService.getDraft();

    if (_draft != null && _draft!.categoryId != null && _draft!.caseTypeId != null) {
      await updateRequiredDocuments();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> startNewDraft({Profile? profile, String? districtName}) async {
    _isLoading = true;
    notifyListeners();

    await HiveDraftService.clearDraft();
    _draft = await HiveDraftService.createOrGetDraft();
    _requiredDocuments = [];

    if (profile != null) {
      _draft!.fullName = profile.fullName;
      _draft!.email = profile.email ?? '';
      _draft!.phone = profile.phoneNumber ?? '';
      if (profile.gender != null && profile.gender!.trim().isNotEmpty) {
        final g = profile.gender!.trim();
        _draft!.gender = g[0].toUpperCase() + (g.length > 1 ? g.substring(1).toLowerCase() : '');
      }
      _draft!.dob = profile.dob;
      _draft!.villageTown = profile.villageOrTown ?? '';
      _draft!.districtId = profile.districtId;
      _draft!.districtName = districtName ?? '';
      await HiveDraftService.saveDraft(_draft!);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearDraft() async {
    _isLoading = true;
    notifyListeners();

    await HiveDraftService.clearDraft();
    _draft = null;
    _requiredDocuments = [];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCategory(dynamic catId, String code, String name) async {
    _draft ??= await HiveDraftService.createOrGetDraft();
    _draft!.categoryId = catId?.toString();
    _draft!.categoryCode = code;
    _draft!.categoryName = name;

    if (code == 'CAT_WOMEN' || code == 'WOMAN') {
      _draft!.gender = 'Female';
    }

    await saveDraft();
    await updateRequiredDocuments();
  }

  Future<void> updateApplicantDetails({
    required String fullName,
    required String gender,
    String? dob,
    required String villageTown,
    required dynamic districtId,
    required String districtName,
    String? talukaId,
    String? talukaName,
    required String email,
    required String phone,
    String? preferredAdvocateId,
  }) async {
    _draft ??= await HiveDraftService.createOrGetDraft();
    _draft!.fullName = fullName;
    _draft!.gender = gender;
    _draft!.dob = dob;
    _draft!.villageTown = villageTown;
    _draft!.districtId = districtId?.toString();
    _draft!.districtName = districtName;
    if (talukaId != null) _draft!.talukaId = talukaId;
    if (talukaName != null) _draft!.talukaName = talukaName;
    _draft!.email = email;
    _draft!.phone = phone;
    if (preferredAdvocateId != null) _draft!.preferredAdvocateId = preferredAdvocateId;

    await saveDraft();
  }

  Future<void> updateCaseType(dynamic caseTypeId, String code, String name) async {
    _draft ??= await HiveDraftService.createOrGetDraft();
    _draft!.caseTypeId = caseTypeId?.toString();
    _draft!.caseTypeCode = code;
    _draft!.caseTypeName = name;

    await saveDraft();
    await updateRequiredDocuments();
  }

  Future<void> updateGrievanceDetails(String summary, [String? relief]) async {
    _draft ??= await HiveDraftService.createOrGetDraft();
    _draft!.caseDetails = summary;
    _draft!.summaryOfGrievance = summary;
    if (relief != null) _draft!.reliefSought = relief;
    await saveDraft();
  }

  Future<void> setStepIndex(int index) async {
    if (_draft != null) {
      _draft!.stepIndex = index;
      await saveDraft();
    }
  }

  Future<void> updateRequiredDocuments() async {
    if (_draft != null && _draft!.categoryId != null && _draft!.caseTypeId != null) {
      final provider = _applyDataProvider;
      if (provider != null) {
        _requiredDocuments = await provider.getRequiredDocuments(
          categoryId: _draft!.categoryId!,
          caseTypeId: _draft!.caseTypeId!,
        );
      }
      notifyListeners();
    }
  }

  Future<void> attachDocument(String docCode, String fileName, List<int> bytes) async {
    if (_draft == null) return;
    try {
      final storagePath = await _appRepo.uploadDocument(
        draftUuid: _draft!.draftUuid,
        docCode: docCode,
        fileName: fileName,
        bytes: bytes,
      );
      _draft!.documentStoragePaths[docCode] = storagePath;
    } catch (_) {
      // Fallback local tracking if storage fails
      _draft!.documentStoragePaths[docCode] = 'draft-uploads/${_draft!.draftUuid}/$docCode.jpg';
    }

    await saveDraft();
  }

  Future<void> removeDocument(String docCode) async {
    if (_draft == null) return;
    _draft!.documentStoragePaths.remove(docCode);
    await saveDraft();
  }

  Future<void> saveDraft() async {
    if (_draft != null) {
      await HiveDraftService.saveDraft(_draft!);
      notifyListeners();
    }
  }

  Future<String> submitFinalApplication({String? loggedInCitizenId}) async {
    if (_draft == null) throw Exception("No active draft found");

    final app = await _appRepo.submitApplication(_draft!, applicantId: loggedInCitizenId);
    final trackingNo = app.trackingNumber.isNotEmpty ? app.trackingNumber : 'LA-${DateTime.now().millisecondsSinceEpoch}';

    await HiveDraftService.clearDraft();
    _draft = null;
    _requiredDocuments = [];
    notifyListeners();
    return trackingNo;
  }
}
