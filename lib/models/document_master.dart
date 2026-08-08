class DocumentMaster {
  final int documentId;
  final String documentCode;
  final String documentName;
  final String description;
  final bool isMandatoryDefault;

  DocumentMaster({
    required this.documentId,
    required this.documentCode,
    required this.documentName,
    required this.description,
    this.isMandatoryDefault = false,
  });

  factory DocumentMaster.fromJson(Map<String, dynamic> json) {
    return DocumentMaster(
      documentId: json['document_id'] ?? json['documentId'] ?? 0,
      documentCode: json['document_code'] ?? json['documentCode'] ?? '',
      documentName: json['document_name'] ?? json['documentName'] ?? '',
      description: json['description'] ?? '',
      isMandatoryDefault: json['is_mandatory_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'document_id': documentId,
    'document_code': documentCode,
    'document_name': documentName,
    'description': description,
    'is_mandatory_default': isMandatoryDefault,
  };
}
