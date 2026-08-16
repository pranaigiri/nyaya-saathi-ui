class District {
  final int districtId;
  final String districtName;

  const District({
    required this.districtId,
    required this.districtName,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      districtId: json['district_id'] ?? json['districtId'] ?? 0,
      districtName: json['district_name'] ?? json['districtName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'district_id': districtId,
    'district_name': districtName,
  };
}
