import '../repositories/apply_repository.dart';
import '../../models/legal_aid_category.dart';
import '../../models/case_type_master.dart';
import '../../models/document_master.dart';
import '../../models/taluka.dart';
import '../../models/advocate.dart';
import '../../data/models/district.dart';
import '../../data/models/gender_option.dart';
import '../../data/local/gender_options.dart';

class LocalApplyRepository implements ApplyRepository {
  static final LocalApplyRepository _instance = LocalApplyRepository._internal();
  factory LocalApplyRepository() => _instance;
  LocalApplyRepository._internal();

  @override
  Future<List<LegalAidCategory>> getLegalAidCategories() async {
    return const [
      LegalAidCategory(
        id: '5793c5e6-9236-4dfd-8b82-fbb3d82dc092',
        categoryCode: 'SC_ST',
        categoryName: 'Scheduled Caste or Scheduled Tribe',
        description: 'Members of Scheduled Caste or Scheduled Tribe communities',
        displayOrder: 1,
      ),
      LegalAidCategory(
        id: '837cce7d-b165-42d1-b6c8-7bcbcce502d1',
        categoryCode: 'WOMAN',
        categoryName: 'Woman',
        description: 'All women are eligible regardless of income',
        displayOrder: 2,
      ),
      LegalAidCategory(
        id: 'f3595cfc-9d99-4e1f-89be-b0186267de66',
        categoryCode: 'GENERAL',
        categoryName: 'General – Annual income below ₹3 Lakh',
        description: 'Individuals with annual household income less than 3 Lakh Rupees',
        displayOrder: 3,
      ),
    ];
  }

  @override
  Future<List<CaseTypeMaster>> getCaseTypes() async {
    return const [
      CaseTypeMaster(
        id: '1061ce0c-c230-47cc-b6d0-226e17acffbc',
        caseTypeCode: 'SUCCESSION_CERTIFICATE',
        caseTypeName: 'Succession Certificate',
        displayOrder: 1,
      ),
      CaseTypeMaster(
        id: 'ff25398e-f2f5-4968-86d1-7720a5bd88f2',
        caseTypeCode: 'DOMESTIC_VIOLENCE',
        caseTypeName: 'Domestic Violence',
        displayOrder: 2,
      ),
      CaseTypeMaster(
        id: '0e6b1747-e003-44e6-86dc-34ccb988658e',
        caseTypeCode: 'PROPERTY_DISPUTE',
        caseTypeName: 'Property Dispute',
        displayOrder: 3,
      ),
    ];
  }

  @override
  Future<List<DocumentMaster>> getDocumentTypes() async {
    return const [
      DocumentMaster(
        id: '2d30eaa3-ae5c-419c-9962-e13ad6a9333e',
        documentCode: 'IDENTIFICATION_DOCUMENT',
        documentName: 'Identification Document (Voter, Aadhar)',
        description: 'A government-approved identification document',
      ),
      DocumentMaster(
        id: '05cffb0c-2ae7-469f-918c-9208720dd9d9',
        documentCode: 'INCOME_CERTIFICATE',
        documentName: 'Income Certificate',
        description: 'Government issued annual income certificate',
      ),
    ];
  }

  @override
  Future<List<GenderOption>> getGenderOptions() async {
    return List<GenderOption>.unmodifiable(localGenderOptions);
  }

  @override
  Future<List<District>> getDistricts() async {
    return const [
      District(id: '162e0db6-feb9-44ea-9476-483c844f4956', districtName: 'Gangtok', districtCode: 'GANGTOK', stateId: ''),
      District(id: '7c7faa9f-4cbb-450d-9046-15ef51430cd9', districtName: 'Namchi', districtCode: 'NAMCHI', stateId: ''),
      District(id: '18bcf408-b669-4e7d-b52c-d3b0a9b7c89d', districtName: 'Mangan', districtCode: 'MANGAN', stateId: ''),
      District(id: 'd434b194-4038-4342-b475-0f1ef7b44ae4', districtName: 'Gyalshing', districtCode: 'GYALSHING', stateId: ''),
    ];
  }

  @override
  Future<List<Taluka>> getTalukas({String? districtId}) async {
    return const [
      Taluka(id: 'b8961244-05cf-4f40-8104-c06656479aeb', talukaName: 'Gangtok', talukaCode: 'GANGTOK_TALUKA', districtId: '162e0db6-feb9-44ea-9476-483c844f4956'),
    ];
  }

  @override
  Future<List<DocumentMaster>> getRequiredDocuments({
    required String categoryId,
    required String caseTypeId,
  }) async {
    return getDocumentTypes();
  }

  @override
  Future<List<Advocate>> getAdvocatesForDistrict(String districtId) async {
    return const [];
  }
}
