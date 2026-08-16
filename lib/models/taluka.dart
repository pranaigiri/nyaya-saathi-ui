class Taluka {
  final String id;
  final String talukaName;
  final String talukaCode;
  final String districtId;

  const Taluka({
    required this.id,
    required this.talukaName,
    required this.talukaCode,
    required this.districtId,
  });

  factory Taluka.fromJson(Map<String, dynamic> json) {
    return Taluka(
      id: json['id'] ?? '',
      talukaName: json['taluka_name'] ?? '',
      talukaCode: json['taluka_code'] ?? '',
      districtId: json['district_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'taluka_name': talukaName,
    'taluka_code': talukaCode,
    'district_id': districtId,
  };
}
