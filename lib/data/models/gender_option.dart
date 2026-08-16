class GenderOption {
  final String value;
  final String label;
  final String iconName;

  const GenderOption({
    required this.value,
    required this.label,
    this.iconName = '',
  });

  factory GenderOption.fromJson(Map<String, dynamic> json) {
    return GenderOption(
      value: json['value'] ?? json['code'] ?? '',
      label: json['label'] ?? json['name'] ?? '',
      iconName: json['icon_name'] ?? json['iconName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'label': label,
    'icon_name': iconName,
  };
}
