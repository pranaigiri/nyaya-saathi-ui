class CaseTypeMaster {
  final int caseTypeId;
  final String caseTypeCode;
  final String caseTypeName;
  final String categoryGroup;
  final String iconName;

  CaseTypeMaster({
    required this.caseTypeId,
    required this.caseTypeCode,
    required this.caseTypeName,
    required this.categoryGroup,
    this.iconName = 'gavel',
  });

  factory CaseTypeMaster.fromJson(Map<String, dynamic> json) {
    return CaseTypeMaster(
      caseTypeId: json['case_type_id'] ?? json['caseTypeId'] ?? 0,
      caseTypeCode: json['case_type_code'] ?? json['caseTypeCode'] ?? '',
      caseTypeName: json['case_type_name'] ?? json['caseTypeName'] ?? '',
      categoryGroup: json['category_group'] ?? json['categoryGroup'] ?? 'General',
      iconName: json['icon_name'] ?? json['iconName'] ?? 'gavel',
    );
  }

  Map<String, dynamic> toJson() => {
    'case_type_id': caseTypeId,
    'case_type_code': caseTypeCode,
    'case_type_name': caseTypeName,
    'category_group': categoryGroup,
    'icon_name': iconName,
  };
}
