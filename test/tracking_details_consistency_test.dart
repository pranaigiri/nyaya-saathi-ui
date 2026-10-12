import 'package:flutter_test/flutter_test.dart';
import 'package:nyaya_saathi/models/legal_aid_application.dart';

void main() {
  group('Tracking Details Consistency Tests', () {
    test('Correctly parses assigned advocate, case details, and clears pending status when advocate assigned', () {
      final json = {
        "id": "aac974bf-4734-43d4-a3a8-9ecdd6dd0d38",
        "status": "ADVOCATE_ASSIGNED",
        "created_at": "2026-10-12T06:23:52.397086+00:00",
        "updated_at": "2026-10-12T08:47:03.841698+00:00",
        "assigned_at": "2026-10-12T08:10:15.602+00:00",
        "category_id": "37dbfb26-af99-4ea8-a756-c668bf7abe2a",
        "case_details": "Need legal aid for succession",
        "case_type_id": "ff25398e-f2f5-4968-86d1-7720a5bd88f2",
        "category_name": "Children",
        "district_name": "Gangtok",
        "case_type_name": "Domestic Violence",
        "advocate_master": {
          "id": "eb0b7646-2cf2-485a-b2b5-a5787b1a792c",
          "full_name": "Mr. Abhinav Kant Jha",
          "primary_email": "abhinavlegals@gmail.com",
          "office_address": null,
          "experience_years": 4,
          "enrollment_number": "BR/1362/2021",
          "primary_phone_number": "8078653189",
          "secondary_phone_number": null,
        },
        "callback_status": "CALLBACK_COMPLETED",
        "tracking_number": "SK-GTK-26-00048",
        "application_mode": "QUICK_CALLBACK",
        "applicant_full_name": "T********",
        "current_district_id": "162e0db6-feb9-44ea-9476-483c844f4956",
        "assigned_advocate_id": "eb0b7646-2cf2-485a-b2b5-a5787b1a792c",
        "details_completed_at": "2026-10-12T08:03:42.83+00:00",
        "applicant_district_id": "162e0db6-feb9-44ea-9476-483c844f4956",
        "applicant_phone_number": "9898989898",
        "assigned_advocate_name": "Mr. Abhinav Kant Jha",
        "is_withdrawn_by_citizen": false,
        "advocate_acceptance_status": "ACCEPTED",
      };

      final app = LegalAidApplication.fromJson(json);

      expect(app.id, "aac974bf-4734-43d4-a3a8-9ecdd6dd0d38");
      expect(app.trackingNumber, "SK-GTK-26-00048");
      expect(app.status, "ADVOCATE_ASSIGNED");
      expect(app.isDetailsPending, false, reason: "Details are completed and advocate is assigned");
      expect(app.caseDetails, "Need legal aid for succession");
      expect(app.summaryOfGrievance, "Need legal aid for succession");
      expect(app.assignedAdvocateId, "eb0b7646-2cf2-485a-b2b5-a5787b1a792c");
      expect(app.assignedAdvocate, isNotNull);
      expect(app.assignedAdvocate!.fullName, "Mr. Abhinav Kant Jha");
      expect(app.assignedAdvocate!.primaryPhoneNumber, "8078653189");
      expect(app.assignedAdvocate!.enrollmentNumber, "BR/1362/2021");
      expect(app.assignedAdvocateName, "Mr. Abhinav Kant Jha");
      expect(app.advocateAcceptanceStatus, "ACCEPTED");
    });

    test('isDetailsPending returns false when callback status is DETAILS_COLLECTED or CALLBACK_COMPLETED', () {
      final json = {
        "id": "123",
        "tracking_number": "SK-GTK-26-00001",
        "status": "SUBMITTED",
        "application_mode": "QUICK_CALLBACK",
        "callback_status": "DETAILS_COLLECTED",
        "case_details": "Inheritance property dispute",
      };

      final app = LegalAidApplication.fromJson(json);
      expect(app.isDetailsPending, false);
    });

    test('isDetailsPending returns false when case details already filled or status is ADVOCATE_ASSIGNED', () {
      final json = {
        "id": "124",
        "tracking_number": "SK-GTK-26-00002",
        "status": "ADVOCATE_ASSIGNED",
        "application_mode": "QUICK_CALLBACK",
        "callback_status": "PENDING_CALL",
      };

      final app = LegalAidApplication.fromJson(json);
      expect(app.isDetailsPending, false);
    });

    test('isDetailsPending returns true only when quick mode is genuinely pending details', () {
      final json = {
        "id": "125",
        "tracking_number": "SK-GTK-26-00003",
        "status": "SUBMITTED",
        "application_mode": "QUICK_CALLBACK",
        "callback_status": "PENDING_CALL",
        "case_details": "",
        "details_completed_at": null,
      };

      final app = LegalAidApplication.fromJson(json);
      expect(app.isDetailsPending, true);
    });
  });
}
