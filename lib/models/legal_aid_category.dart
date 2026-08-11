class LegalAidCategory {
  final int categoryId;
  final String categoryCode;
  final String categoryName;
  final String description;
  final double? incomeLimit;
  final String iconName;
  final bool isActive;
  final int displayOrder;

  const LegalAidCategory({
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
    required this.description,
    this.incomeLimit,
    this.iconName = 'payments',
    this.isActive = true,
    this.displayOrder = 0,
  });

  factory LegalAidCategory.fromJson(Map<String, dynamic> json) {
    return LegalAidCategory(
      categoryId: json['legal_aid_category_id'] ?? json['categoryId'] ?? 0,
      categoryCode: json['category_code'] ?? json['categoryCode'] ?? '',
      categoryName: json['category_name'] ?? json['categoryName'] ?? '',
      description: json['description'] ?? '',
      incomeLimit: json['income_limit'] != null ? (json['income_limit'] as num).toDouble() : null,
      iconName: json['icon_name'] ?? json['iconName'] ?? 'payments',
      isActive: json['is_active'] ?? true,
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'legal_aid_category_id': categoryId,
    'category_code': categoryCode,
    'category_name': categoryName,
    'description': description,
    'income_limit': incomeLimit,
    'icon_name': iconName,
    'is_active': isActive,
    'display_order': displayOrder,
  };
}
