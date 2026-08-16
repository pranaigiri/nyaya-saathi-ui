class District {
  final String id;
  final String districtName;
  final String districtCode;
  final String stateId;

  const District({
    required this.id,
    required this.districtName,
    required this.districtCode,
    required this.stateId,
  });

  String get districtId => id;

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] ?? json['district_id'] ?? '',
      districtName: json['district_name'] ?? json['districtName'] ?? '',
      districtCode: json['district_code'] ?? json['districtCode'] ?? '',
      stateId: json['state_id'] ?? json['stateId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'district_name': districtName,
    'district_code': districtCode,
    'state_id': stateId,
  };
}
