import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/legal_aid_category.dart';
import '../../models/case_type_master.dart';
import '../../models/document_master.dart';
import '../../models/legal_aid_application.dart';
import '../../models/application_applicant_details.dart';
import '../../models/draft_application_model.dart';
import '../../models/notification_model.dart';
import '../../models/chat_message_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // Simulated backend in-memory cache for standalone local execution
  final List<LegalAidApplication> _mockApplications = [];
  final List<NotificationModel> _mockNotifications = [];
  final List<ChatMessageModel> _mockChatMessages = [];

  bool get isLiveSupabaseAvailable => client != null;

  Future<void> init() async {
    _seedMockData();
  }

  void _seedMockData() {
    _mockApplications.addAll([
      LegalAidApplication(
        applicationId: 101,
        applicationNumber: "SK-LA-2026-1001",
        citizenId: "citizen-uuid-001",
        categoryId: 1,
        categoryName: "General (Income < ₹3,00,000/yr)",
        caseTypeId: 2,
        caseTypeName: "Land & Property Dispute",
        districtId: 1,
        districtName: "Gangtok (East Sikkim)",
        summaryOfGrievance: "Land boundary dispute regarding ancestral farmland in Gangtok village area.",
        reliefSought: "Legal advocate representation for proceedings in Civil Court.",
        currentStatus: "CASE_IN_PROGRESS",
        submittedAt: DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
        applicantDetails: ApplicationApplicantDetails(
          applicationId: 101,
          fullName: "Pema Lepcha",
          gender: "Male",
          dateOfBirth: "1988-05-14",
          villageOrTown: "Tadong, Gangtok",
          districtId: 1,
          phoneNumber: "9876543210",
          email: "pema.lepcha@example.com",
        ),
        assignedAdvocateName: "Adv. Tashi Bhutia (Bar Reg SK/2018/44)",
      ),
      LegalAidApplication(
        applicationId: 102,
        applicationNumber: "SK-LA-2026-1002",
        citizenId: "citizen-uuid-001",
        categoryId: 2,
        categoryName: "Women & Children",
        caseTypeId: 1,
        caseTypeName: "Domestic Violence & Maintenance",
        districtId: 2,
        districtName: "Namchi (South Sikkim)",
        summaryOfGrievance: "Request for maintenance and protection order under PWDVA 2005.",
        reliefSought: "Monthly maintenance order & free legal representation.",
        currentStatus: "APPROVED_SLSA",
        submittedAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        applicantDetails: ApplicationApplicantDetails(
          applicationId: 102,
          fullName: "Passang Lhamu",
          gender: "Female",
          dateOfBirth: "1994-09-22",
          villageOrTown: "Namchi Bazaar",
          districtId: 2,
          phoneNumber: "9876543210",
        ),
      ),
    ]);

    _mockNotifications.addAll([
      NotificationModel(
        id: 1,
        title: "Application Approved",
        body: "Your legal aid application SK-LA-2026-1002 has been approved by SLSA. Advocate assignment in progress.",
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        applicationId: 102,
      ),
      NotificationModel(
        id: 2,
        title: "Advocate Assigned",
        body: "Adv. Tashi Bhutia has been assigned to your case SK-LA-2026-1001.",
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        applicationId: 101,
      ),
    ]);

    _mockChatMessages.addAll([
      ChatMessageModel(
        id: 1,
        applicationId: 101,
        senderId: "authority-uuid",
        recipientId: "citizen-uuid-001",
        message: "Greetings. Please ensure you carry your original Aadhaar card when meeting your advocate on Monday.",
        isFromAuthority: true,
        sentAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      ),
    ]);
  }

  // Icon Resolver Helper
  static IconData getIconData(String iconName) {
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
      default:
        return Icons.gavel_outlined;
    }
  }

  // Master Data Fetchers
  Future<List<LegalAidCategory>> getCategories() async {
    if (client != null) {
      try {
        final res = await client!.from('legal_aid_category').select().eq('is_active', true);
        return (res as List).map((x) => LegalAidCategory.fromJson(x)).toList();
      } catch (_) {}
    }
    return [
      LegalAidCategory(categoryId: 1, categoryCode: 'CAT_GEN', categoryName: 'General (Income < ₹3,00,000/yr)', description: 'Annual family income below ₹3 Lakhs', incomeLimit: 300000, iconName: 'account_balance_wallet'),
      LegalAidCategory(categoryId: 2, categoryCode: 'CAT_WOMEN', categoryName: 'Women & Children', description: 'Women and minor children regardless of income', iconName: 'female'),
      LegalAidCategory(categoryId: 3, categoryCode: 'CAT_SC_ST', categoryName: 'Scheduled Caste / Scheduled Tribe', description: 'Members of SC/ST communities', iconName: 'groups'),
      LegalAidCategory(categoryId: 4, categoryCode: 'CAT_DISABLED', categoryName: 'Mentally Ill / Differently Abled', description: 'Persons with physical or mental disabilities', iconName: 'accessible'),
      LegalAidCategory(categoryId: 5, categoryCode: 'CAT_DISASTER', categoryName: 'Victim of Mass Disaster / Ethnic Violence', description: 'Victims of disaster or violence', iconName: 'warning'),
    ];
  }

  Future<List<CaseTypeMaster>> getCaseTypes() async {
    if (client != null) {
      try {
        final res = await client!.from('case_type_master').select().eq('is_active', true);
        return (res as List).map((x) => CaseTypeMaster.fromJson(x)).toList();
      } catch (_) {}
    }
    return [
      CaseTypeMaster(caseTypeId: 1, caseTypeCode: 'CT_DOMESTIC', caseTypeName: 'Domestic Violence & Maintenance', categoryGroup: 'Family Law', iconName: 'home'),
      CaseTypeMaster(caseTypeId: 2, caseTypeCode: 'CT_PROPERTY', caseTypeName: 'Land & Property Dispute', categoryGroup: 'Civil Law', iconName: 'landscape'),
      CaseTypeMaster(caseTypeId: 3, caseTypeCode: 'CT_SUCCESSION', caseTypeName: 'Succession & Heirship Certificate', categoryGroup: 'Civil Law', iconName: 'history_edu'),
      CaseTypeMaster(caseTypeId: 4, caseTypeCode: 'CT_CRIMINAL_DEFENSE', caseTypeName: 'Criminal Defense / Bail Application', categoryGroup: 'Criminal Law', iconName: 'gavel'),
      CaseTypeMaster(caseTypeId: 5, caseTypeCode: 'CT_LABOUR', caseTypeName: 'Wages & Labour Dispute', categoryGroup: 'Labour Law', iconName: 'work'),
      CaseTypeMaster(caseTypeId: 6, caseTypeCode: 'CT_CONSUMER', caseTypeName: 'Consumer Protection', categoryGroup: 'Civil Law', iconName: 'shopping_bag'),
    ];
  }

  // Union of required documents based on category + case type
  Future<List<DocumentMaster>> getRequiredDocuments({required int categoryId, required int caseTypeId}) async {
    final allDocs = [
      DocumentMaster(documentId: 1, documentCode: 'DOC_ID', documentName: 'Identity Proof (Aadhaar / Voter ID)', description: 'Valid Govt photo identity', isMandatoryDefault: true),
      DocumentMaster(documentId: 2, documentCode: 'DOC_INCOME', documentName: 'Income Certificate', description: 'Tehsildar issued income proof'),
      DocumentMaster(documentId: 3, documentCode: 'DOC_GENDER_PROOF', documentName: 'Gender / Identity Declaration', description: 'Self declaration or ID proof for women'),
      DocumentMaster(documentId: 4, documentCode: 'DOC_CASTE_CERT', documentName: 'Caste Certificate (SC/ST)', description: 'Official SC/ST certificate'),
      DocumentMaster(documentId: 5, documentCode: 'DOC_DISABILITY_CERT', documentName: 'Disability Certificate', description: 'Medical civil surgeon certificate'),
      DocumentMaster(documentId: 6, documentCode: 'DOC_DEATH_CERT', documentName: 'Death Certificate of Deceased', description: 'Inheritance/succession cases'),
      DocumentMaster(documentId: 7, documentCode: 'DOC_FIR_COPY', documentName: 'FIR / Police Complaint Copy', description: 'Copy of police report'),
    ];

    List<DocumentMaster> requiredList = [allDocs[0]]; // Identity proof always required

    if (categoryId == 1) { // General category requires income proof
      requiredList.add(allDocs[1]);
    } else if (categoryId == 2) { // Women
      requiredList.add(allDocs[2]);
    } else if (categoryId == 3) { // SC/ST
      requiredList.add(allDocs[3]);
    } else if (categoryId == 4) { // Disabled
      requiredList.add(allDocs[4]);
    }

    if (caseTypeId == 3) { // Succession
      requiredList.add(allDocs[5]);
    } else if (caseTypeId == 4) { // Criminal Defense
      requiredList.add(allDocs[6]);
    }

    return requiredList;
  }

  // Upload picked file to Supabase Storage immediately under draft UUID
  Future<String> uploadDraftDocument({required String draftUuid, required String docCode, required String fileName, required List<int> bytes}) async {
    final path = 'draft-uploads/$draftUuid/$docCode.jpg';
    if (client != null) {
      try {
        await client!.storage.from('legal-documents').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(upsert: true),
        );
        return path;
      } catch (_) {}
    }
    return path; // Return storage path key
  }

  // Track application without OTP (Requires application_number + secondary identifier)
  Future<LegalAidApplication?> trackApplication({required String appNumber, required String secondaryIdentifier, String? deviceId}) async {
    // Log attempt in tracking_attempt_log
    final normalizedAppNo = appNumber.trim().toUpperCase();
    final normalizedSecId = secondaryIdentifier.trim().replaceAll('-', '').toLowerCase();

    // Check mock applications
    final matched = _mockApplications.firstWhere(
      (app) {
        if (app.applicationNumber.toUpperCase() != normalizedAppNo) return false;
        final applicant = app.applicantDetails;
        if (applicant == null) return false;
        final phone = applicant.phoneNumber.trim();
        final dob = (applicant.dateOfBirth ?? '').replaceAll('-', '').toLowerCase();
        
        final last4Phone = phone.length >= 4 ? phone.substring(phone.length - 4) : phone;
        return normalizedSecId.contains(last4Phone) || normalizedSecId == dob || dob.endsWith(normalizedSecId);
      },
      orElse: () => LegalAidApplication(
        applicationId: -1,
        applicationNumber: '',
        categoryId: 0,
        categoryName: '',
        caseTypeId: 0,
        caseTypeName: '',
        districtId: 0,
        districtName: '',
        summaryOfGrievance: '',
        currentStatus: '',
        submittedAt: '',
      ),
    );

    if (matched.applicationId != -1) {
      return matched;
    }
    return null;
  }

  // Final submission of draft application
  Future<String> submitApplication(DraftApplicationModel draft, {String? loggedInCitizenId}) async {
    final appNo = 'SK-LA-2026-${1000 + Random().nextInt(8999)}';
    
    final newApp = LegalAidApplication(
      applicationId: DateTime.now().millisecondsSinceEpoch,
      applicationNumber: appNo,
      citizenId: loggedInCitizenId ?? "auto-citizen-${Random().nextInt(9999)}",
      categoryId: draft.categoryId ?? 1,
      categoryName: draft.categoryName ?? 'General',
      caseTypeId: draft.caseTypeId ?? 1,
      caseTypeName: draft.caseTypeName ?? 'Civil Dispute',
      districtId: draft.districtId,
      districtName: draft.districtName,
      summaryOfGrievance: draft.summaryOfGrievance,
      reliefSought: draft.reliefSought,
      currentStatus: 'SUBMITTED',
      submittedAt: DateTime.now().toIso8601String(),
      applicantDetails: ApplicationApplicantDetails(
        fullName: draft.fullName,
        gender: draft.gender,
        dateOfBirth: draft.dob,
        villageOrTown: draft.villageTown,
        districtId: draft.districtId,
        email: draft.email,
        phoneNumber: draft.phone,
      ),
    );

    _mockApplications.insert(0, newApp);
    _mockNotifications.insert(0, NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: "Application Submitted Successfully",
      body: "Your application $appNo has been submitted to Sikkim SLSA.",
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
      applicationId: newApp.applicationId,
    ));

    return appNo;
  }

  // Fetch applications for logged in user
  Future<List<LegalAidApplication>> getCitizenApplications() async {
    return _mockApplications;
  }

  // Fetch advocate assigned applications
  Future<List<LegalAidApplication>> getAdvocateAssignedCases() async {
    return _mockApplications.where((a) => a.currentStatus == 'CASE_IN_PROGRESS' || a.currentStatus == 'ASSIGNED_TO_ADVOCATE').toList();
  }

  Future<List<NotificationModel>> getNotifications() async {
    return _mockNotifications;
  }

  Future<List<ChatMessageModel>> getChatMessages() async {
    return _mockChatMessages;
  }

  void addChatMessage(String msg) {
    _mockChatMessages.add(ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: 'citizen-uuid-001',
      recipientId: 'authority-uuid',
      message: msg,
      isFromAuthority: false,
      sentAt: DateTime.now().toIso8601String(),
    ));

    // Simulated quick response from authority bot
    Future.delayed(const Duration(seconds: 1), () {
      _mockChatMessages.add(ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        senderId: 'authority-uuid',
        recipientId: 'citizen-uuid-001',
        message: "Thank you for reaching Sikkim SLSA Support. Your query has been logged. Our helpdesk officer will respond shortly.",
        isFromAuthority: true,
        sentAt: DateTime.now().toIso8601String(),
      ));
    });
  }
}
