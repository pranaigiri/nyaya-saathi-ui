import 'advocate.dart';

class ApplicantDetailsAdapter {
  final LegalAidApplication _app;

  ApplicantDetailsAdapter(this._app);

  String get fullName => _app.applicantFullName;
  String get gender => _app.applicantGender;
  String? get dateOfBirth => _app.applicantDob;
  String get villageOrTown => _app.villageOrTown ?? '';
  String get districtId => _app.applicantDistrictId;
  String get phoneNumber => _app.applicantPhoneNumber;
  String? get email => null;
}

class LegalAidApplication {
  final String id;
  final String trackingNumber;
  final String? applicantId;
  final String categoryId;
  final String applicantFullName;
  final String applicantPhoneNumber;
  final String applicantDob;
  final String applicantGender;
  final String? villageOrTown;
  final String applicantDistrictId;
  final String caseTypeId;
  final String currentDistrictId;
  final String? currentTalukaId;
  final String caseDetails;
  final String? preferredAdvocateId;
  final String? assignedAdvocateId;
  final String advocateAcceptanceStatus;
  final String status;
  final bool isWithdrawnByCitizen;
  final String? withdrawalReason;
  final String? withdrawnAt;
  final String createdAt;
  final String updatedAt;

  // Joined/resolved display names (populated from joined queries)
  final String? categoryName;
  final String? caseTypeName;
  final String? districtName;
  final String? assignedAdvocateName;
  final Advocate? assignedAdvocate;

  LegalAidApplication({
    required this.id,
    required this.trackingNumber,
    this.applicantId,
    required this.categoryId,
    required this.applicantFullName,
    required this.applicantPhoneNumber,
    required this.applicantDob,
    required this.applicantGender,
    this.villageOrTown,
    required this.applicantDistrictId,
    required this.caseTypeId,
    required this.currentDistrictId,
    this.currentTalukaId,
    required this.caseDetails,
    this.preferredAdvocateId,
    this.assignedAdvocateId,
    this.advocateAcceptanceStatus = 'NONE',
    required this.status,
    this.isWithdrawnByCitizen = false,
    this.withdrawalReason,
    this.withdrawnAt,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.caseTypeName,
    this.districtName,
    this.assignedAdvocateName,
    this.assignedAdvocate,
  });

  // Backward-compatibility getters
  String get applicationId => id;
  String get applicationNumber => trackingNumber;
  String get currentStatus => status;
  String get submittedAt => createdAt;
  String get summaryOfGrievance => caseDetails;
  String? get reliefSought => null;
  String get fullName => applicantFullName;
  ApplicantDetailsAdapter get applicantDetails => ApplicantDetailsAdapter(this);

  factory LegalAidApplication.fromJson(Map<String, dynamic> json) {
    Advocate? advocate;
    if (json['advocate_master'] is Map<String, dynamic>) {
      advocate = Advocate.fromJson(json['advocate_master'] as Map<String, dynamic>);
    } else if (json['assigned_advocate'] is Map<String, dynamic>) {
      advocate = Advocate.fromJson(json['assigned_advocate'] as Map<String, dynamic>);
    }

    return LegalAidApplication(
      id: json['id']?.toString() ?? '',
      trackingNumber: json['tracking_number']?.toString() ?? json['application_number']?.toString() ?? '',
      applicantId: json['applicant_id']?.toString(),
      categoryId: json['category_id']?.toString() ?? json['legal_aid_category_id']?.toString() ?? '',
      applicantFullName: json['applicant_full_name']?.toString() ?? json['applicant_details']?['full_name']?.toString() ?? json['full_name']?.toString() ?? '',
      applicantPhoneNumber: json['applicant_phone_number']?.toString() ?? json['applicant_details']?['phone_number']?.toString() ?? json['phone_number']?.toString() ?? '',
      applicantDob: json['applicant_dob']?.toString() ?? json['applicant_details']?['date_of_birth']?.toString() ?? json['dob']?.toString() ?? '',
      applicantGender: json['applicant_gender']?.toString() ?? json['applicant_details']?['gender']?.toString() ?? json['gender']?.toString() ?? 'Male',
      villageOrTown: json['village_or_town']?.toString() ?? json['applicant_details']?['village_or_town']?.toString(),
      applicantDistrictId: json['applicant_district_id']?.toString() ?? json['district_id']?.toString() ?? '',
      caseTypeId: json['case_type_id']?.toString() ?? '',
      currentDistrictId: json['current_district_id']?.toString() ?? json['district_id']?.toString() ?? '',
      currentTalukaId: json['current_taluka_id']?.toString(),
      caseDetails: json['case_details']?.toString() ?? json['summary_of_grievance']?.toString() ?? '',
      preferredAdvocateId: json['preferred_advocate_id']?.toString(),
      assignedAdvocateId: json['assigned_advocate_id']?.toString(),
      advocateAcceptanceStatus: json['advocate_acceptance_status']?.toString() ?? 'NONE',
      status: json['status']?.toString() ?? json['current_status']?.toString() ?? 'SUBMITTED',
      isWithdrawnByCitizen: json['is_withdrawn_by_citizen'] == true,
      withdrawalReason: json['withdrawal_reason']?.toString(),
      withdrawnAt: json['withdrawn_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['submitted_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      // Joined relations
      categoryName: json['legal_aid_category'] is Map
          ? json['legal_aid_category']['category_name']?.toString()
          : json['category_name']?.toString(),
      caseTypeName: json['case_type_master'] is Map
          ? json['case_type_master']['case_type_name']?.toString()
          : json['case_type_name']?.toString(),
      districtName: json['district_master'] is Map
          ? json['district_master']['district_name']?.toString()
          : (json['applicant_district'] is Map
              ? json['applicant_district']['district_name']?.toString()
              : json['district_name']?.toString()),
      assignedAdvocateName: advocate?.fullName ??
          (json['advocate_master'] is Map
              ? json['advocate_master']['full_name']?.toString()
              : json['assigned_advocate_name']?.toString()),
      assignedAdvocate: advocate,
    );
  }

  LegalAidApplication copyWith({
    String? id,
    String? trackingNumber,
    String? applicantId,
    String? categoryId,
    String? applicantFullName,
    String? applicantPhoneNumber,
    String? applicantDob,
    String? applicantGender,
    String? villageOrTown,
    String? applicantDistrictId,
    String? caseTypeId,
    String? currentDistrictId,
    String? currentTalukaId,
    String? caseDetails,
    String? preferredAdvocateId,
    String? assignedAdvocateId,
    String? advocateAcceptanceStatus,
    String? status,
    bool? isWithdrawnByCitizen,
    String? withdrawalReason,
    String? withdrawnAt,
    String? createdAt,
    String? updatedAt,
    String? categoryName,
    String? caseTypeName,
    String? districtName,
    String? assignedAdvocateName,
    Advocate? assignedAdvocate,
  }) {
    return LegalAidApplication(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      applicantId: applicantId ?? this.applicantId,
      categoryId: categoryId ?? this.categoryId,
      applicantFullName: applicantFullName ?? this.applicantFullName,
      applicantPhoneNumber: applicantPhoneNumber ?? this.applicantPhoneNumber,
      applicantDob: applicantDob ?? this.applicantDob,
      applicantGender: applicantGender ?? this.applicantGender,
      villageOrTown: villageOrTown ?? this.villageOrTown,
      applicantDistrictId: applicantDistrictId ?? this.applicantDistrictId,
      caseTypeId: caseTypeId ?? this.caseTypeId,
      currentDistrictId: currentDistrictId ?? this.currentDistrictId,
      currentTalukaId: currentTalukaId ?? this.currentTalukaId,
      caseDetails: caseDetails ?? this.caseDetails,
      preferredAdvocateId: preferredAdvocateId ?? this.preferredAdvocateId,
      assignedAdvocateId: assignedAdvocateId ?? this.assignedAdvocateId,
      advocateAcceptanceStatus: advocateAcceptanceStatus ?? this.advocateAcceptanceStatus,
      status: status ?? this.status,
      isWithdrawnByCitizen: isWithdrawnByCitizen ?? this.isWithdrawnByCitizen,
      withdrawalReason: withdrawalReason ?? this.withdrawalReason,
      withdrawnAt: withdrawnAt ?? this.withdrawnAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      caseTypeName: caseTypeName ?? this.caseTypeName,
      districtName: districtName ?? this.districtName,
      assignedAdvocateName: assignedAdvocateName ?? this.assignedAdvocateName,
      assignedAdvocate: assignedAdvocate ?? this.assignedAdvocate,
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'applicant_id': applicantId,
    'category_id': categoryId,
    'applicant_full_name': applicantFullName,
    'applicant_phone_number': applicantPhoneNumber,
    'applicant_dob': applicantDob,
    'applicant_gender': applicantGender,
    'village_or_town': villageOrTown,
    'applicant_district_id': applicantDistrictId,
    'case_type_id': caseTypeId,
    'current_district_id': currentDistrictId,
    'current_taluka_id': currentTalukaId,
    'case_details': caseDetails,
    'preferred_advocate_id': preferredAdvocateId,
    'tracking_number': '', // Trigger will generate
  };

  String get displayStatus {
    switch (status) {
      case 'SUBMITTED':
        return 'Submitted';
      case 'UNDER_REVIEW':
        return 'Under Review';
      case 'ADVOCATE_ASSIGNED':
        return 'Advocate Assigned';
      case 'RESOLVED':
        return 'Resolved';
      case 'REJECTED':
        return 'Rejected';
      case 'WITHDRAWN':
        return 'Withdrawn';
      default:
        return status;
    }
  }
}
