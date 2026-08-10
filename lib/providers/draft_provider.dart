import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/draft_application_model.dart';
import '../models/document_master.dart';
import '../core/services/hive_draft_service.dart';
import '../core/services/supabase_service.dart';

class DraftProvider extends ChangeNotifier {
  DraftApplicationModel? _draft;
  List<DocumentMaster> _requiredDocuments = [];
  bool _isLoading = false;

  DraftApplicationModel? get draft => _draft;
  List<DocumentMaster> get requiredDocuments => _requiredDocuments;
  bool get isLoading => _isLoading;

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

  Future<void> startNewDraft() async {
    _isLoading = true;
    notifyListeners();

    await HiveDraftService.clearDraft();
    _draft = await HiveDraftService.createOrGetDraft();
    _requiredDocuments = [];

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

  Future<void> updateCategory(int catId, String code, String name) async {
    _draft ??= await HiveDraftService.createOrGetDraft();
    _draft!.categoryId = catId;
    _draft!.categoryCode = code;
    _draft!.categoryName = name;

    // Auto update gender if category is Women
    if (code == 'CAT_WOMEN') {
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
    required int districtId,
    required String districtName,
    required String email,
    required String phone
  }) async {
    _draft ??= await HiveDraftService.createOrGetDraft();
    _draft!.fullName = fullName;
    _draft!.gender = gender;
    _draft!.dob = dob;
    _draft!.villageTown = villageTown;
    _draft!.districtId = districtId;
    _draft!.districtName = districtName;
    _draft!.email = email;
    _draft!.phone = phone;

    await saveDraft();
  }

  Future<void> updateCaseType(int caseTypeId, String code, String name) async {
    _draft ??= await HiveDraftService.createOrGetDraft();
    _draft!.caseTypeId = caseTypeId;
    _draft!.caseTypeCode = code;
    _draft!.caseTypeName = name;

    await saveDraft();
    await updateRequiredDocuments();
  }

  Future<void> updateGrievanceDetails(String summary, String relief) async {
    _draft ??= await HiveDraftService.createOrGetDraft();
    _draft!.summaryOfGrievance = summary;
    _draft!.reliefSought = relief;
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
      _requiredDocuments = await SupabaseService().getRequiredDocuments(
        categoryId: _draft!.categoryId!,
        caseTypeId: _draft!.caseTypeId!,
      );
      notifyListeners();
    }
  }

  Future<void> attachDocument(String docCode, String fileName, List<int> bytes) async {
    if (_draft == null) return;
    final storagePath = await SupabaseService().uploadDraftDocument(
      draftUuid: _draft!.draftUuid,
      docCode: docCode,
      fileName: fileName,
      bytes: bytes,
    );

    _draft!.documentStoragePaths[docCode] = storagePath;
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

    final appNo = await SupabaseService().submitApplication(_draft!, loggedInCitizenId: loggedInCitizenId);
    await HiveDraftService.clearDraft();
    _draft = null;
    _requiredDocuments = [];
    notifyListeners();
    return appNo;
  }
}
