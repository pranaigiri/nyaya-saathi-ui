import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../models/legal_aid_category.dart';
import '../../models/case_type_master.dart';
import '../../models/document_master.dart';
import '../../models/taluka.dart';
import '../../models/advocate.dart';
import '../../data/models/district.dart';
import '../../data/models/gender_option.dart';
import '../../data/repositories/apply_repository.dart';

class ApplyDataProvider extends ChangeNotifier {
  final ApplyRepository repository;

  ApplyDataProvider(this.repository);

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

  List<LegalAidCategory>? _cachedCategories;
  List<CaseTypeMaster>? _cachedCaseTypes;
  List<DocumentMaster>? _cachedDocuments;
  List<GenderOption>? _cachedGenderOptions;
  List<District>? _cachedDistricts;

  bool _isLoadingCategories = false;
  bool _isLoadingCaseTypes = false;
  bool _isLoadingDocuments = false;
  bool _isLoadingGenderOptions = false;
  bool _isLoadingDistricts = false;

  String? _categoriesError;
  String? _caseTypesError;
  String? _documentsError;
  String? _districtsError;

  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingCaseTypes => _isLoadingCaseTypes;
  bool get isLoadingDocuments => _isLoadingDocuments;
  bool get isLoadingGenderOptions => _isLoadingGenderOptions;
  bool get isLoadingDistricts => _isLoadingDistricts;

  String? get categoriesError => _categoriesError;
  String? get caseTypesError => _caseTypesError;
  String? get documentsError => _documentsError;
  String? get districtsError => _districtsError;

  Future<List<LegalAidCategory>> getLegalAidCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }
    _isLoadingCategories = true;
    _categoriesError = null;
    notifyListeners();
    try {
      _cachedCategories = await repository.getLegalAidCategories();
      return _cachedCategories!;
    } catch (e) {
      _categoriesError = 'Failed to load categories. Please try again.';
      return [];
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<List<CaseTypeMaster>> getCaseTypes() async {
    if (_cachedCaseTypes != null) {
      return _cachedCaseTypes!;
    }
    _isLoadingCaseTypes = true;
    _caseTypesError = null;
    notifyListeners();
    try {
      _cachedCaseTypes = await repository.getCaseTypes();
      return _cachedCaseTypes!;
    } catch (e) {
      _caseTypesError = 'Failed to load case types. Please try again.';
      return [];
    } finally {
      _isLoadingCaseTypes = false;
      notifyListeners();
    }
  }

  Future<List<DocumentMaster>> getDocumentTypes() async {
    if (_cachedDocuments != null) {
      return _cachedDocuments!;
    }
    _isLoadingDocuments = true;
    _documentsError = null;
    notifyListeners();
    try {
      _cachedDocuments = await repository.getDocumentTypes();
      return _cachedDocuments!;
    } catch (e) {
      _documentsError = 'Failed to load document types. Please try again.';
      return [];
    } finally {
      _isLoadingDocuments = false;
      notifyListeners();
    }
  }

  Future<List<GenderOption>> getGenderOptions() async {
    if (_cachedGenderOptions != null) {
      return _cachedGenderOptions!;
    }
    _isLoadingGenderOptions = true;
    notifyListeners();
    try {
      _cachedGenderOptions = await repository.getGenderOptions();
      return _cachedGenderOptions!;
    } finally {
      _isLoadingGenderOptions = false;
      notifyListeners();
    }
  }

  Future<List<District>> getDistricts() async {
    if (_cachedDistricts != null) {
      return _cachedDistricts!;
    }
    _isLoadingDistricts = true;
    _districtsError = null;
    notifyListeners();
    try {
      _cachedDistricts = await repository.getDistricts();
      return _cachedDistricts!;
    } catch (e) {
      _districtsError = 'Failed to load districts. Please try again.';
      return [];
    } finally {
      _isLoadingDistricts = false;
      notifyListeners();
    }
  }

  Future<List<Taluka>> getTalukas({String? districtId}) async {
    return repository.getTalukas(districtId: districtId);
  }

  Future<List<DocumentMaster>> getRequiredDocuments({
    required String categoryId,
    required String caseTypeId,
  }) async {
    return repository.getRequiredDocuments(
      categoryId: categoryId,
      caseTypeId: caseTypeId,
    );
  }

  Future<List<Advocate>> getAdvocatesForDistrict(String districtId) async {
    return repository.getAdvocatesForDistrict(districtId);
  }

  IconData resolveIcon(String? iconUrl) {
    if (iconUrl == null || iconUrl.isEmpty) return Icons.gavel_outlined;
    // Map known icon_url values to IconData
    final key = iconUrl.toLowerCase();
    switch (key) {
      case 'payments':
      case 'account_balance_wallet':
        return Icons.account_balance_wallet_outlined;
      case 'female':
      case 'woman':
        return Icons.female_outlined;
      case 'groups':
      case 'people':
        return Icons.groups_outlined;
      case 'accessible':
      case 'wheelchair':
        return Icons.accessible_outlined;
      case 'warning':
      case 'storm':
        return Icons.warning_amber_rounded;
      case 'home':
      case 'family_restroom':
        return Icons.family_restroom_outlined;
      case 'landscape':
      case 'location_city':
        return Icons.landscape_outlined;
      case 'card_giftcard':
      case 'history_edu':
        return Icons.history_edu_outlined;
      case 'shield':
      case 'gavel':
        return Icons.gavel_outlined;
      case 'work':
      case 'badge':
        return Icons.work_outline;
      case 'shopping_bag':
      case 'store':
        return Icons.storefront_outlined;
      case 'male':
        return Icons.male_rounded;
      default:
        return Icons.gavel_outlined;
    }
  }

  void clearCache() {
    _cachedCategories = null;
    _cachedCaseTypes = null;
    _cachedDocuments = null;
    _cachedGenderOptions = null;
    _cachedDistricts = null;
    _categoriesError = null;
    _caseTypesError = null;
    _documentsError = null;
    _districtsError = null;
    notifyListeners();
  }
}
