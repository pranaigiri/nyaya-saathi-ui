import 'application_applicant_details.dart';

class LegalAidApplication {
  final int applicationId;
  final String applicationNumber;
  final String? citizenId;
  final int categoryId;
  final String categoryName;
  final int caseTypeId;
  final String caseTypeName;
  final int districtId;
  final String districtName;
  final String summaryOfGrievance;
  final String? reliefSought;
  final String currentStatus;
  final String submittedAt;
  final ApplicationApplicantDetails? applicantDetails;
  final List<ApplicationWitness>? witnesses;
  final List<String>? documentUrls;
  final String? assignedAdvocateName;

  LegalAidApplication({
    required this.applicationId,
    required this.applicationNumber,
    this.citizenId,
    required this.categoryId,
    required this.categoryName,
    required this.caseTypeId,
    required this.caseTypeName,
    required this.districtId,
    required this.districtName,
    required this.summaryOfGrievance,
    this.reliefSought,
    required this.currentStatus,
    required this.submittedAt,
    this.applicantDetails,
    this.witnesses,
    this.documentUrls,
    this.assignedAdvocateName,
  });

  factory LegalAidApplication.fromJson(Map<String, dynamic> json) {
    return LegalAidApplication(
      applicationId: json['application_id'] ?? 0,
      applicationNumber: json['application_number'] ?? '',
      citizenId: json['citizen_id'],
      categoryId: json['legal_aid_category_id'] ?? 0,
      categoryName: json['legal_aid_category']?['category_name'] ?? json['category_name'] ?? 'General',
      caseTypeId: json['case_type_id'] ?? 0,
      caseTypeName: json['case_type_master']?['case_type_name'] ?? json['case_type_name'] ?? 'Civil Dispute',
      districtId: json['district_id'] ?? 1,
      districtName: json['district_master']?['district_name'] ?? json['district_name'] ?? 'Gangtok',
      summaryOfGrievance: json['summary_of_grievance'] ?? '',
      reliefSought: json['relief_sought'],
      currentStatus: json['current_status'] ?? 'SUBMITTED',
      submittedAt: json['submitted_at'] ?? DateTime.now().toIso8601String(),
      applicantDetails: json['applicant_details'] != null
          ? ApplicationApplicantDetails.fromJson(json['applicant_details'])
          : null,
      assignedAdvocateName: json['assigned_advocate_name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'application_id': applicationId,
    'application_number': applicationNumber,
    'citizen_id': citizenId,
    'legal_aid_category_id': categoryId,
    'case_type_id': caseTypeId,
    'district_id': districtId,
    'summary_of_grievance': summaryOfGrievance,
    'relief_sought': reliefSought,
    'current_status': currentStatus,
    'submitted_at': submittedAt,
  };
}
