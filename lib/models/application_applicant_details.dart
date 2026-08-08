class ApplicationApplicantDetails {
  final int? applicationId;
  final String appliedFor; // 'self' | 'other'
  final String? relationRemark;
  final String fullName;
  final String gender;
  final String? dateOfBirth;
  final String villageOrTown;
  final int districtId;
  final String? email;
  final String phoneNumber;

  ApplicationApplicantDetails({
    this.applicationId,
    required this.appliedFor,
    this.relationRemark,
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
      appliedFor: json['applied_for'] ?? 'self',
      relationRemark: json['relation_remark'],
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
    'applied_for': appliedFor,
    'relation_remark': relationRemark,
    'full_name': fullName,
    'gender': gender,
    'date_of_birth': dateOfBirth,
    'village_or_town': villageOrTown,
    'district_id': districtId,
    'email': email,
    'phone_number': phoneNumber,
  };
}

class ApplicationWitness {
  final int? id;
  final int? applicationId;
  final String witnessName;
  final String relationToApplicant;

  ApplicationWitness({
    this.id,
    this.applicationId,
    required this.witnessName,
    required this.relationToApplicant,
  });

  factory ApplicationWitness.fromJson(Map<String, dynamic> json) {
    return ApplicationWitness(
      id: json['id'],
      applicationId: json['application_id'],
      witnessName: json['witness_name'] ?? '',
      relationToApplicant: json['relation_to_applicant'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (applicationId != null) 'application_id': applicationId,
    'witness_name': witnessName,
    'relation_to_applicant': relationToApplicant,
  };
}
