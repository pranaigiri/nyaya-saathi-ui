import 'package:supabase_flutter/supabase_flutter.dart';
import 'apply_repository.dart';
import '../../models/legal_aid_category.dart';
import '../../models/case_type_master.dart';
import '../../models/document_master.dart';
import '../../models/taluka.dart';
import '../../models/advocate.dart';
import '../../data/models/district.dart';
import '../../data/models/gender_option.dart';
import '../../data/local/gender_options.dart';

class SupabaseApplyRepository implements ApplyRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<LegalAidCategory>> getLegalAidCategories() async {
    final res = await _client
        .from('legal_aid_category')
        .select('id, category_code, category_name, description, display_order, icon_url')
        .order('display_order');
    return (res as List).map((x) => LegalAidCategory.fromJson(x)).toList();
  }

  @override
  Future<List<CaseTypeMaster>> getCaseTypes() async {
    final res = await _client
        .from('case_type_master')
        .select('id, case_type_code, case_type_name, icon_url, display_order, is_active')
        .eq('is_active', true)
        .order('display_order');
    return (res as List).map((x) => CaseTypeMaster.fromJson(x)).toList();
  }

  @override
  Future<List<DocumentMaster>> getDocumentTypes() async {
    final res = await _client
        .from('document_master')
        .select('id, document_code, document_name, description, is_active')
        .eq('is_active', true);
    return (res as List).map((x) => DocumentMaster.fromJson(x)).toList();
  }

  @override
  Future<List<GenderOption>> getGenderOptions() async {
    // Gender options are client-side constants (no DB table)
    return List<GenderOption>.unmodifiable(localGenderOptions);
  }

  @override
  Future<List<District>> getDistricts() async {
    final res = await _client
        .from('district_master')
        .select('id, district_name, district_code, state_id')
        .order('district_name');
    return (res as List).map((x) => District.fromJson(x)).toList();
  }

  @override
  Future<List<Taluka>> getTalukas({String? districtId}) async {
    var query = _client
        .from('taluka_master')
        .select('id, taluka_name, taluka_code, district_id');
    if (districtId != null) {
      query = query.eq('district_id', districtId);
    }
    final res = await query.order('taluka_name');
    return (res as List).map((x) => Taluka.fromJson(x)).toList();
  }

  @override
  Future<List<DocumentMaster>> getRequiredDocuments({
    required String categoryId,
    required String caseTypeId,
  }) async {
    // Fetch documents required by the selected category
    final catDocs = await _client
        .from('legal_aid_category_document_map')
        .select('document_id, is_required, document_master(id, document_code, document_name, description, is_active)')
        .eq('category_id', categoryId);

    // Fetch documents required by the selected case type
    final ctDocs = await _client
        .from('case_type_document_map')
        .select('document_id, is_required, document_master(id, document_code, document_name, description, is_active)')
        .eq('case_type_id', caseTypeId);

    // Union of both sets, deduplicated by document id
    final docMap = <String, DocumentMaster>{};

    for (final row in catDocs) {
      final doc = row['document_master'];
      if (doc != null && doc is Map<String, dynamic>) {
        final dm = DocumentMaster.fromJson(doc);
        if (dm.isActive) docMap[dm.id] = dm;
      }
    }

    for (final row in ctDocs) {
      final doc = row['document_master'];
      if (doc != null && doc is Map<String, dynamic>) {
        final dm = DocumentMaster.fromJson(doc);
        if (dm.isActive) docMap[dm.id] = dm;
      }
    }

    return docMap.values.toList();
  }

  @override
  Future<List<Advocate>> getAdvocatesForDistrict(String districtId) async {
    final res = await _client
        .from('advocate_district_mapping')
        .select('advocate_id, advocate_master!inner(id, full_name, gender, enrollment_number, primary_phone_number, experience_years, is_active, is_available_for_assignment)')
        .eq('district_id', districtId);

    final advocates = <Advocate>[];
    for (final row in res) {
      final adv = row['advocate_master'];
      if (adv != null && adv is Map<String, dynamic>) {
        final advocate = Advocate.fromJson(adv);
        if (advocate.isActive && advocate.isAvailableForAssignment) {
          advocates.add(advocate);
        }
      }
    }
    return advocates;
  }
}
