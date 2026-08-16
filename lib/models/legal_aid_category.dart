class LegalAidCategory {
  final String id;
  final String categoryCode;
  final String categoryName;
  final String? description;
  final int displayOrder;
  final String? iconUrl;

  const LegalAidCategory({
    required this.id,
    required this.categoryCode,
    required this.categoryName,
    this.description,
    this.displayOrder = 0,
    this.iconUrl,
  });

  String get categoryId => id;
  String get iconName => iconUrl ?? 'payments';
  String get desc => description ?? '';
  double? get incomeLimit => null;

  factory LegalAidCategory.fromJson(Map<String, dynamic> json) {
    return LegalAidCategory(
      id: json['id'] ?? '',
      categoryCode: json['category_code'] ?? '',
      categoryName: json['category_name'] ?? '',
      description: json['description'],
      displayOrder: json['display_order'] ?? 0,
      iconUrl: json['icon_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_code': categoryCode,
    'category_name': categoryName,
    'description': description,
    'display_order': displayOrder,
    'icon_url': iconUrl,
  };
}
