import 'package:flutter_test/flutter_test.dart';
import 'package:nyaya_saathi_ui/core/services/supabase_service.dart';
import 'package:nyaya_saathi_ui/models/draft_application_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await SupabaseService().init();
  });

  group('Nyaya Saathi Business Logic Tests', () {
    test('Dynamic document requirement union calculation for Women + Succession', () async {
      final docs = await SupabaseService().getRequiredDocuments(
        categoryId: 2, // Women & Children
        caseTypeId: 3,  // Succession & Heirship Certificate
      );

      final docCodes = docs.map((d) => d.documentCode).toList();

      expect(docCodes, contains('DOC_ID'));           // Mandatory Default Identity Proof
      expect(docCodes, contains('DOC_GENDER_PROOF')); // Women category requirement
      expect(docCodes, contains('DOC_DEATH_CERT'));   // Succession case type requirement
    });

    test('Draft Application model serialization', () {
      final draft = DraftApplicationModel(
        draftUuid: 'test-uuid-123',
        fullName: 'Passang Lhamu',
        villageTown: 'Namchi',
        districtId: 2,
        districtName: 'Namchi (South Sikkim)',
        phone: '9876543210',
      );

      final json = draft.toJson();
      final restored = DraftApplicationModel.fromJson(json);

      expect(restored.draftUuid, equals('test-uuid-123'));
      expect(restored.fullName, equals('Passang Lhamu'));
    });

    test('Tracking lookup without OTP using Application Number and DOB/phone', () async {
      final app = await SupabaseService().trackApplication(
        appNumber: 'SK-LA-2026-1001',
        secondaryIdentifier: '1988-05-14',
      );

      expect(app, isNotNull);
      expect(app!.applicationNumber, equals('SK-LA-2026-1001'));
      expect(app.applicantDetails?.fullName, equals('Pema Lepcha'));
    });
  });
}
