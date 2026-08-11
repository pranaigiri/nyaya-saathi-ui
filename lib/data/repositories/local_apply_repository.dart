import '../repositories/apply_repository.dart';
import '../../models/legal_aid_category.dart';
import '../../models/case_type_master.dart';
import '../../models/document_master.dart';
import '../../data/models/caste_type.dart';
import '../../data/models/document_mapping.dart';
import '../../data/models/gender_option.dart';
import '../../data/models/district.dart';
import '../../data/local/legal_aid_categories.dart';
import '../../data/local/case_types.dart';
import '../../data/local/document_types.dart';
import '../../data/local/caste_types.dart';
import '../../data/local/document_mappings.dart';
import '../../data/local/gender_options.dart';
import '../../data/local/districts.dart';

class LocalApplyRepository implements ApplyRepository {
  static final LocalApplyRepository _instance = LocalApplyRepository._internal();
  factory LocalApplyRepository() => _instance;
  LocalApplyRepository._internal();

  @override
  Future<List<LegalAidCategory>> getLegalAidCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<LegalAidCategory>.unmodifiable(localLegalAidCategories);
  }

  @override
  Future<List<CaseTypeMaster>> getCaseTypes() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<CaseTypeMaster>.unmodifiable(localCaseTypes);
  }

  @override
  Future<List<DocumentMaster>> getDocumentTypes() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<DocumentMaster>.unmodifiable(localDocumentTypes);
  }

  @override
  Future<List<CasteType>> getCasteTypes() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<CasteType>.unmodifiable(localCasteTypes);
  }

  @override
  Future<List<GenderOption>> getGenderOptions() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<GenderOption>.unmodifiable(localGenderOptions);
  }

  @override
  Future<List<District>> getDistricts() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<District>.unmodifiable(localDistricts);
  }

  @override
  Future<List<DocumentMapping>> getDocumentMappings() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<DocumentMapping>.unmodifiable(localDocumentMappings);
  }

  @override
  Future<List<DocumentMaster>> getRequiredDocuments({
    required int categoryId,
    required int caseTypeId,
    int? casteTypeId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final allDocs = Map<int, DocumentMaster>.fromIterable(
      localDocumentTypes,
      key: (d) => (d as DocumentMaster).documentId,
    );

    final mappings = localDocumentMappings;
    final result = <DocumentMaster>{};

    for (final mapping in mappings) {
      if (!mapping.isRequired) continue;

      final doc = allDocs[mapping.documentTypeId];
      if (doc == null) continue;

      final matchesCategory = mapping.legalAidCategoryId != null &&
          mapping.legalAidCategoryId == categoryId;
      final matchesCaseType = mapping.caseTypeId != null &&
          mapping.caseTypeId == caseTypeId;
      final matchesCasteType = mapping.casteTypeId != null &&
          mapping.casteTypeId == casteTypeId;
      final isGlobal = mapping.legalAidCategoryId == null &&
          mapping.caseTypeId == null &&
          mapping.casteTypeId == null;

      if (isGlobal || matchesCategory || matchesCaseType || matchesCasteType) {
        result.add(doc);
      }
    }

    final sorted = result.toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return sorted;
  }
}
