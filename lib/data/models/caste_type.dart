class CasteType {
  final int casteTypeId;
  final String casteTypeCode;
  final String casteTypeName;
  final String description;
  final bool isActive;
  final int displayOrder;

  const CasteType({
    required this.casteTypeId,
    required this.casteTypeCode,
    required this.casteTypeName,
    this.description = '',
    this.isActive = true,
    this.displayOrder = 0,
  });

  factory CasteType.fromJson(Map<String, dynamic> json) {
    return CasteType(
      casteTypeId: json['caste_type_id'] ?? json['casteTypeId'] ?? 0,
      casteTypeCode: json['caste_type_code'] ?? json['casteTypeCode'] ?? '',
      casteTypeName: json['caste_type_name'] ?? json['casteTypeName'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'caste_type_id': casteTypeId,
    'caste_type_code': casteTypeCode,
    'caste_type_name': casteTypeName,
    'description': description,
    'is_active': isActive,
    'display_order': displayOrder,
  };
}
