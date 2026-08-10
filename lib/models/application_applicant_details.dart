class ApplicationApplicantDetails {
  final int? applicationId;
  final String fullName;
  final String gender;
  final String? dateOfBirth;
  final String villageOrTown;
  final int districtId;
  final String? email;
  final String phoneNumber;

  ApplicationApplicantDetails({
    this.applicationId,
    required this.fullName,
    required this.gender,
    this.dateOfBirth,
    required this.villageOrTown,
    required this.districtId,
    this.email,
    required this.phoneNumber,
  });

  factory ApplicationApplicantDetails.fromJson(Map<String, dynamic> json) {
    return ApplicationApplicantDetails(
      applicationId: json['application_id'],
      fullName: json['full_name'] ?? '',
      gender: json['gender'] ?? 'Male',
      dateOfBirth: json['date_of_birth'],
      villageOrTown: json['village_or_town'] ?? '',
      districtId: json['district_id'] ?? 1,
      email: json['email'],
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (applicationId != null) 'application_id': applicationId,
    'full_name': fullName,
    'gender': gender,
    'date_of_birth': dateOfBirth,
    'village_or_town': villageOrTown,
    'district_id': districtId,
    'email': email,
    'phone_number': phoneNumber,
  };
}
