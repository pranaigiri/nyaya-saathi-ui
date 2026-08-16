class Advocate {
  final String id;
  final String fullName;
  final String? gender;
  final String enrollmentNumber;
  final String primaryPhoneNumber;
  final String? secondaryPhoneNumber;
  final String? primaryEmail;
  final String? secondaryEmail;
  final String? officeAddress;
  final int experienceYears;
  final bool isActive;
  final bool isAvailableForAssignment;

  const Advocate({
    required this.id,
    required this.fullName,
    this.gender,
    required this.enrollmentNumber,
    required this.primaryPhoneNumber,
    this.secondaryPhoneNumber,
    this.primaryEmail,
    this.secondaryEmail,
    this.officeAddress,
    this.experienceYears = 0,
    this.isActive = true,
    this.isAvailableForAssignment = true,
  });

  factory Advocate.fromJson(Map<String, dynamic> json) {
    return Advocate(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      gender: json['gender']?.toString(),
      enrollmentNumber: json['enrollment_number']?.toString() ?? '',
      primaryPhoneNumber: json['primary_phone_number']?.toString() ?? '',
      secondaryPhoneNumber: json['secondary_phone_number']?.toString(),
      primaryEmail: json['primary_email']?.toString(),
      secondaryEmail: json['secondary_email']?.toString(),
      officeAddress: json['office_address']?.toString(),
      experienceYears: json['experience_years'] is int
          ? json['experience_years']
          : int.tryParse(json['experience_years']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] ?? true,
      isAvailableForAssignment: json['is_available_for_assignment'] ?? true,
    );
  }

  String get displayLabel => '$fullName ($enrollmentNumber)';
}
