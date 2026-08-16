import '../../models/legal_aid_category.dart';
import '../../models/case_type_master.dart';
import '../../models/document_master.dart';
import '../../data/models/caste_type.dart';
import '../../data/models/document_mapping.dart';
import '../../data/models/gender_option.dart';
import '../../data/models/district.dart';

abstract class ApplyRepository {
  Future<List<LegalAidCategory>> getLegalAidCategories();
  Future<List<CaseTypeMaster>> getCaseTypes();
  Future<List<DocumentMaster>> getDocumentTypes();
  Future<List<CasteType>> getCasteTypes();
  Future<List<GenderOption>> getGenderOptions();
  Future<List<District>> getDistricts();
  Future<List<DocumentMaster>> getRequiredDocuments({
    required int categoryId,
    required int caseTypeId,
    int? casteTypeId,
  });
  Future<List<DocumentMapping>> getDocumentMappings();
}
