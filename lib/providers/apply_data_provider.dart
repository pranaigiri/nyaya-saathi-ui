import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/legal_aid_category.dart';
import '../../models/case_type_master.dart';
import '../../models/document_master.dart';
import '../../data/models/caste_type.dart';
import '../../data/models/document_mapping.dart';
import '../../data/models/gender_option.dart';
import '../../data/models/district.dart';
import '../../data/repositories/apply_repository.dart';

class ApplyDataProvider extends ChangeNotifier {
  final ApplyRepository repository;

  ApplyDataProvider(this.repository);

  List<LegalAidCategory>? _cachedCategories;
  List<CaseTypeMaster>? _cachedCaseTypes;
  List<DocumentMaster>? _cachedDocuments;
  List<CasteType>? _cachedCasteTypes;
  List<GenderOption>? _cachedGenderOptions;
  List<District>? _cachedDistricts;
  List<DocumentMapping>? _cachedDocumentMappings;

  bool _isLoadingCategories = false;
  bool _isLoadingCaseTypes = false;
  bool _isLoadingDocuments = false;
  bool _isLoadingCasteTypes = false;
  bool _isLoadingGenderOptions = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingDocumentMappings = false;

  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingCaseTypes => _isLoadingCaseTypes;
  bool get isLoadingDocuments => _isLoadingDocuments;
  bool get isLoadingCasteTypes => _isLoadingCasteTypes;
  bool get isLoadingGenderOptions => _isLoadingGenderOptions;
  bool get isLoadingDistricts => _isLoadingDistricts;
  bool get isLoadingDocumentMappings => _isLoadingDocumentMappings;

  Future<List<LegalAidCategory>> getLegalAidCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }
    _isLoadingCategories = true;
    notifyListeners();
    try {
      _cachedCategories = await repository.getLegalAidCategories();
      return _cachedCategories!;
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
    notifyListeners();
    try {
      _cachedCaseTypes = await repository.getCaseTypes();
      return _cachedCaseTypes!;
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
    notifyListeners();
    try {
      _cachedDocuments = await repository.getDocumentTypes();
      return _cachedDocuments!;
    } finally {
      _isLoadingDocuments = false;
      notifyListeners();
    }
  }

  Future<List<CasteType>> getCasteTypes() async {
    if (_cachedCasteTypes != null) {
      return _cachedCasteTypes!;
    }
    _isLoadingCasteTypes = true;
    notifyListeners();
    try {
      _cachedCasteTypes = await repository.getCasteTypes();
      return _cachedCasteTypes!;
    } finally {
      _isLoadingCasteTypes = false;
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
    notifyListeners();
    try {
      _cachedDistricts = await repository.getDistricts();
      return _cachedDistricts!;
    } finally {
      _isLoadingDistricts = false;
      notifyListeners();
    }
  }

  Future<List<DocumentMapping>> getDocumentMappings() async {
    if (_cachedDocumentMappings != null) {
      return _cachedDocumentMappings!;
    }
    _isLoadingDocumentMappings = true;
    notifyListeners();
    try {
      _cachedDocumentMappings = await repository.getDocumentMappings();
      return _cachedDocumentMappings!;
    } finally {
      _isLoadingDocumentMappings = false;
      notifyListeners();
    }
  }

  Future<List<DocumentMaster>> getRequiredDocuments({
    required int categoryId,
    required int caseTypeId,
    int? casteTypeId,
  }) async {
    return repository.getRequiredDocuments(
      categoryId: categoryId,
      caseTypeId: caseTypeId,
      casteTypeId: casteTypeId,
    );
  }

  IconData resolveIcon(String iconName) {
    switch (iconName.toLowerCase()) {
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
    _cachedCasteTypes = null;
    _cachedGenderOptions = null;
    _cachedDistricts = null;
    _cachedDocumentMappings = null;
    notifyListeners();
  }
}
