class DocumentMapping {
  final String categoryId;
  final String documentId;
  final bool isRequired;

  const DocumentMapping({
    required this.categoryId,
    required this.documentId,
    this.isRequired = true,
  });

  factory DocumentMapping.fromCategoryJson(Map<String, dynamic> json) {
    return DocumentMapping(
      categoryId: json['category_id'] ?? '',
      documentId: json['document_id'] ?? '',
      isRequired: json['is_required'] ?? true,
    );
  }
}

class CaseTypeDocumentMapping {
  final String caseTypeId;
  final String documentId;
  final bool isRequired;

  const CaseTypeDocumentMapping({
    required this.caseTypeId,
    required this.documentId,
    this.isRequired = true,
  });

  factory CaseTypeDocumentMapping.fromJson(Map<String, dynamic> json) {
    return CaseTypeDocumentMapping(
      caseTypeId: json['case_type_id'] ?? '',
      documentId: json['document_id'] ?? '',
      isRequired: json['is_required'] ?? true,
    );
  }
}
