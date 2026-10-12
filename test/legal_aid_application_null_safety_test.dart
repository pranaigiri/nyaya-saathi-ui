import 'package:flutter_test/flutter_test.dart';
import 'package:nyaya_saathi/models/legal_aid_application.dart';

void main() {
  group('LegalAidApplication Null-Safety & Quick Mode Deserialization', () {
    test('safely parses quick callback application with nullable fields', () {
      final json = {
        'id': 'app-uuid-1234',
        'tracking_number': 'SK-GTK-26-00042',
        'status': 'SUBMITTED',
        'applicant_phone_number': '9876543219',
        'application_mode': 'QUICK',
        'callback_status': 'PENDING',
        'callback_attempts': 0,
        'details_completed_at': null,
        'category_id': null,
        'case_type_id': null,
        'case_details': null,
        'applicant_full_name': null,
        'applicant_dob': null,
        'applicant_gender': null,
        'applicant_district_id': 'dist-gtk',
        'created_at': '2026-10-10T12:00:00Z',
        'updated_at': '2026-10-10T12:00:00Z',
      };

      final app = LegalAidApplication.fromJson(json);

      expect(app.id, equals('app-uuid-1234'));
      expect(app.trackingNumber, equals('SK-GTK-26-00042'));
      expect(app.status, equals('SUBMITTED'));
      expect(app.applicantPhoneNumber, equals('9876543219'));
      expect(app.applicationMode, equals('QUICK'));
      expect(app.isQuickMode, isTrue);
      expect(app.isDetailsPending, isTrue);
      expect(app.callbackStatus, equals('PENDING'));
      expect(app.callbackAttempts, equals(0));
      expect(app.categoryId, isNull);
      expect(app.caseTypeId, isNull);
      expect(app.caseDetails, isNull);
      expect(app.summaryOfGrievance, equals(''));
      expect(app.applicantFullName, isNull);
      expect(app.fullName, equals(''));
      expect(app.applicantDob, isNull);
      expect(app.applicantGender, isNull);
    });

    test('correctly identifies completed quick application after SLSA callback', () {
      final json = {
        'id': 'app-uuid-5678',
        'tracking_number': 'SK-GTK-26-00043',
        'status': 'UNDER_REVIEW',
        'applicant_phone_number': '9876543219',
        'application_mode': 'QUICK',
        'callback_status': 'REACHED',
        'callback_attempts': 1,
        'details_completed_at': '2026-10-11T10:30:00Z',
        'category_id': 'cat-1',
        'category_name': 'Women and Children',
        'case_details': 'Maintenance matter',
        'applicant_full_name': 'Sita Sharma',
        'applicant_dob': '1985-05-15',
        'applicant_gender': 'Female',
        'created_at': '2026-10-10T12:00:00Z',
        'updated_at': '2026-10-11T10:30:00Z',
      };

      final app = LegalAidApplication.fromJson(json);

      expect(app.isQuickMode, isTrue);
      expect(app.isDetailsPending, isFalse);
      expect(app.callbackStatus, equals('REACHED'));
      expect(app.callbackAttempts, equals(1));
      expect(app.applicantFullName, equals('Sita Sharma'));
      expect(app.categoryName, equals('Women and Children'));
    });

    test('full mode application defaults isDetailsPending to false', () {
      final json = {
        'id': 'app-full-999',
        'tracking_number': 'SK-GTK-26-00001',
        'status': 'SUBMITTED',
        'applicant_phone_number': '9876543219',
        'application_mode': 'FULL',
        'category_id': 'cat-1',
        'case_details': 'Property boundary issue',
        'applicant_full_name': 'Ram Bahadur',
        'created_at': '2026-10-10T12:00:00Z',
        'updated_at': '2026-10-10T12:00:00Z',
      };

      final app = LegalAidApplication.fromJson(json);

      expect(app.isQuickMode, isFalse);
      expect(app.isDetailsPending, isFalse);
      expect(app.callbackStatus, equals('NOT_REQUIRED'));
    });
  });
}
