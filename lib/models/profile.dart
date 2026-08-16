class Profile {
  final String id;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? dob;
  final String? gender;
  final String? villageOrTown;
  final String? districtId;
  final String userType;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.dob,
    this.gender,
    this.villageOrTown,
    this.districtId,
    required this.userType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCitizen => userType == 'CITIZEN';
  bool get isActive => status == 'ACTIVE';

  /// 7 fields required for 100% profile completion (profile picture not required)
  static const int totalRequiredFields = 7;

  bool get hasFullName => fullName.trim().isNotEmpty;
  bool get hasEmail => email != null && email!.trim().isNotEmpty;
  bool get hasPhone => phoneNumber != null && phoneNumber!.trim().isNotEmpty;
  bool get hasGender => gender != null && gender!.trim().isNotEmpty;
  bool get hasDob => dob != null && dob!.trim().isNotEmpty;
  bool get hasVillageTown => villageOrTown != null && villageOrTown!.trim().isNotEmpty;
  bool get hasDistrict => districtId != null && districtId!.trim().isNotEmpty;

  int get completedFieldsCount {
    int count = 0;
    if (hasFullName) count++;
    if (hasEmail) count++;
    if (hasPhone) count++;
    if (hasGender) count++;
    if (hasDob) count++;
    if (hasVillageTown) count++;
    if (hasDistrict) count++;
    return count;
  }

  int get completionPercentage => ((completedFieldsCount / totalRequiredFields) * 100).round();
  bool get isProfileComplete => completedFieldsCount == totalRequiredFields;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'],
      email: json['email'],
      dob: json['dob'],
      gender: json['gender'],
      villageOrTown: json['village_or_town'],
      districtId: json['district_id'],
      userType: json['user_type'] ?? 'CITIZEN',
      status: json['status'] ?? 'ACTIVE',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'phone_number': phoneNumber,
    'email': email,
    'dob': dob,
    'gender': gender,
    'village_or_town': villageOrTown,
    'district_id': districtId,
  };
}
