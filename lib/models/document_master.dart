class DocumentMaster {
  final String id;
  final String documentCode;
  final String documentName;
  final String? description;
  final bool isActive;

  const DocumentMaster({
    required this.id,
    required this.documentCode,
    required this.documentName,
    this.description,
    this.isActive = true,
  });

  bool get isMandatoryDefault => true;
  int get displayOrder => 0;

  factory DocumentMaster.fromJson(Map<String, dynamic> json) {
    return DocumentMaster(
      id: json['id'] ?? '',
      documentCode: json['document_code'] ?? '',
      documentName: json['document_name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'document_code': documentCode,
    'document_name': documentName,
    'description': description,
    'is_active': isActive,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentMaster && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
