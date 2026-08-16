import '../../models/legal_aid_category.dart';
import '../../models/case_type_master.dart';
import '../../models/document_master.dart';
import '../../models/taluka.dart';
import '../../models/advocate.dart';
import '../../data/models/district.dart';
import '../../data/models/gender_option.dart';

abstract class ApplyRepository {
  Future<List<LegalAidCategory>> getLegalAidCategories();
  Future<List<CaseTypeMaster>> getCaseTypes();
  Future<List<DocumentMaster>> getDocumentTypes();
  Future<List<GenderOption>> getGenderOptions();
  Future<List<District>> getDistricts();
  Future<List<Taluka>> getTalukas({String? districtId});
  Future<List<DocumentMaster>> getRequiredDocuments({
    required String categoryId,
    required String caseTypeId,
  });
  Future<List<Advocate>> getAdvocatesForDistrict(String districtId);
}
