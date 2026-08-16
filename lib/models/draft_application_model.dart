class DraftApplicationModel {
  final String draftUuid;
  int stepIndex;
  String? categoryId;
  String? categoryCode;
  String? categoryName;

  // Applicant details
  String fullName;
  String gender;
  String? dob;
  String villageTown;
  String? districtId;
  String districtName;
  String? talukaId;
  String? talukaName;
  String email;
  String phone;

  // Case details
  String? caseTypeId;
  String? caseTypeCode;
  String? caseTypeName;
  String caseDetails;
  String reliefSought;
  String? preferredAdvocateId;

  // Storage path map for picked documents: docCode -> Supabase Storage Path
  Map<String, String> documentStoragePaths;

  String get summaryOfGrievance => caseDetails;
  set summaryOfGrievance(String value) => caseDetails = value;

  DraftApplicationModel({
    required this.draftUuid,
    this.stepIndex = 0,
    this.categoryId,
    this.categoryCode,
    this.categoryName,
    this.fullName = '',
    this.gender = 'Male',
    this.dob,
    this.villageTown = '',
    this.districtId,
    this.districtName = '',
    this.talukaId,
    this.talukaName,
    this.email = '',
    this.phone = '',
    this.caseTypeId,
    this.caseTypeCode,
    this.caseTypeName,
    this.caseDetails = '',
    this.reliefSought = '',
    this.preferredAdvocateId,
    Map<String, String>? documentStoragePaths,
  }) : documentStoragePaths = documentStoragePaths ?? {};

  Map<String, dynamic> toJson() => {
    'draftUuid': draftUuid,
    'stepIndex': stepIndex,
    'categoryId': categoryId,
    'categoryCode': categoryCode,
    'categoryName': categoryName,
    'fullName': fullName,
    'gender': gender,
    'dob': dob,
    'villageTown': villageTown,
    'districtId': districtId,
    'districtName': districtName,
    'talukaId': talukaId,
    'talukaName': talukaName,
    'email': email,
    'phone': phone,
    'caseTypeId': caseTypeId,
    'caseTypeCode': caseTypeCode,
    'caseTypeName': caseTypeName,
    'caseDetails': caseDetails,
    'reliefSought': reliefSought,
    'preferredAdvocateId': preferredAdvocateId,
    'documentStoragePaths': documentStoragePaths,
  };

  factory DraftApplicationModel.fromJson(Map<String, dynamic> json) {
    return DraftApplicationModel(
      draftUuid: json['draftUuid'] ?? '',
      stepIndex: json['stepIndex'] ?? 0,
      categoryId: json['categoryId']?.toString(),
      categoryCode: json['categoryCode'],
      categoryName: json['categoryName'],
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? 'Male',
      dob: json['dob'],
      villageTown: json['villageTown'] ?? '',
      districtId: json['districtId']?.toString(),
      districtName: json['districtName'] ?? '',
      talukaId: json['talukaId']?.toString(),
      talukaName: json['talukaName'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      caseTypeId: json['caseTypeId']?.toString(),
      caseTypeCode: json['caseTypeCode'],
      caseTypeName: json['caseTypeName'],
      caseDetails: json['caseDetails'] ?? json['summaryOfGrievance'] ?? '',
      reliefSought: json['reliefSought'] ?? '',
      preferredAdvocateId: json['preferredAdvocateId']?.toString(),
      documentStoragePaths: Map<String, String>.from(json['documentStoragePaths'] ?? {}),
    );
  }
}
