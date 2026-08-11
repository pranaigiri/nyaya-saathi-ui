class DocumentMapping {
  final int mappingId;
  final int documentTypeId;
  final int? legalAidCategoryId;
  final int? casteTypeId;
  final int? caseTypeId;
  final bool isRequired;
  final int displayOrder;

  const DocumentMapping({
    required this.mappingId,
    required this.documentTypeId,
    this.legalAidCategoryId,
    this.casteTypeId,
    this.caseTypeId,
    this.isRequired = true,
    this.displayOrder = 0,
  });

  factory DocumentMapping.fromJson(Map<String, dynamic> json) {
    return DocumentMapping(
      mappingId: json['mapping_id'] ?? json['mappingId'] ?? 0,
      documentTypeId: json['document_type_id'] ?? json['documentTypeId'] ?? 0,
      legalAidCategoryId: json['legal_aid_category_id'] ?? json['legalAidCategoryId'],
      casteTypeId: json['caste_type_id'] ?? json['casteTypeId'],
      caseTypeId: json['case_type_id'] ?? json['caseTypeId'],
      isRequired: json['is_required'] ?? true,
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'mapping_id': mappingId,
    'document_type_id': documentTypeId,
    if (legalAidCategoryId != null) 'legal_aid_category_id': legalAidCategoryId,
    if (casteTypeId != null) 'caste_type_id': casteTypeId,
    if (caseTypeId != null) 'case_type_id': caseTypeId,
    'is_required': isRequired,
    'display_order': displayOrder,
  };
}
