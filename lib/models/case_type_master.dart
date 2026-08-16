class CaseTypeMaster {
  final String id;
  final String caseTypeCode;
  final String caseTypeName;
  final String? iconUrl;
  final int displayOrder;
  final bool isActive;

  const CaseTypeMaster({
    required this.id,
    required this.caseTypeCode,
    required this.caseTypeName,
    this.iconUrl,
    this.displayOrder = 0,
    this.isActive = true,
  });

  String get caseTypeId => id;
  String get iconName => iconUrl ?? 'gavel';
  String get categoryGroup => 'General';

  factory CaseTypeMaster.fromJson(Map<String, dynamic> json) {
    return CaseTypeMaster(
      id: json['id'] ?? '',
      caseTypeCode: json['case_type_code'] ?? '',
      caseTypeName: json['case_type_name'] ?? '',
      iconUrl: json['icon_url'],
      displayOrder: json['display_order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'case_type_code': caseTypeCode,
    'case_type_name': caseTypeName,
    'icon_url': iconUrl,
    'display_order': displayOrder,
    'is_active': isActive,
  };
}
