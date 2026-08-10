class DraftApplicationModel {
  final String draftUuid;
  int stepIndex;
  int? categoryId;
  String? categoryCode;
  String? categoryName;
  
  // Applicant details
  String fullName;
  String gender;
  String? dob;
  String villageTown;
  int districtId;
  String districtName;
  String email;
  String phone;

  // Case details
  int? caseTypeId;
  String? caseTypeCode;
  String? caseTypeName;
  String summaryOfGrievance;
  String reliefSought;

  // Storage path map for picked documents: docCode -> Supabase Storage Path
  Map<String, String> documentStoragePaths;

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
    this.districtId = 1,
    this.districtName = 'Gangtok (East Sikkim)',
    this.email = '',
    this.phone = '',
    this.caseTypeId,
    this.caseTypeCode,
    this.caseTypeName,
    this.summaryOfGrievance = '',
    this.reliefSought = '',
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
    'email': email,
    'phone': phone,
    'caseTypeId': caseTypeId,
    'caseTypeCode': caseTypeCode,
    'caseTypeName': caseTypeName,
    'summaryOfGrievance': summaryOfGrievance,
    'reliefSought': reliefSought,
    'documentStoragePaths': documentStoragePaths,
  };

  factory DraftApplicationModel.fromJson(Map<String, dynamic> json) {
    return DraftApplicationModel(
      draftUuid: json['draftUuid'] ?? '',
      stepIndex: json['stepIndex'] ?? 0,
      categoryId: json['categoryId'],
      categoryCode: json['categoryCode'],
      categoryName: json['categoryName'],
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? 'Male',
      dob: json['dob'],
      villageTown: json['villageTown'] ?? '',
      districtId: json['districtId'] ?? 1,
      districtName: json['districtName'] ?? 'Gangtok (East Sikkim)',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      caseTypeId: json['caseTypeId'],
      caseTypeCode: json['caseTypeCode'],
      caseTypeName: json['caseTypeName'],
      summaryOfGrievance: json['summaryOfGrievance'] ?? '',
      reliefSought: json['reliefSought'] ?? '',
      documentStoragePaths: Map<String, String>.from(json['documentStoragePaths'] ?? {}),
    );
  }
}
