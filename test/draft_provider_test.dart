import 'package:flutter_test/flutter_test.dart';
import 'package:nyaya_saathi/data/repositories/local_apply_repository.dart';
import 'package:nyaya_saathi/models/draft_application_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Nyaya Saathi Business Logic Tests', () {
    test('Local apply repository returns categories and case types', () async {
      final repo = LocalApplyRepository();
      final categories = await repo.getLegalAidCategories();
      final caseTypes = await repo.getCaseTypes();

      expect(categories, isNotEmpty);
      expect(caseTypes, isNotEmpty);
    });

    test('Draft Application model serialization', () {
      final draft = DraftApplicationModel(
        draftUuid: 'test-uuid-123',
        fullName: 'Passang Lhamu',
        villageTown: 'Namchi',
        districtId: '7c7faa9f-4cbb-450d-9046-15ef51430cd9',
        districtName: 'Namchi',
        phone: '9876543210',
      );

      final json = draft.toJson();
      final restored = DraftApplicationModel.fromJson(json);

      expect(restored.draftUuid, equals('test-uuid-123'));
      expect(restored.fullName, equals('Passang Lhamu'));
      expect(
        restored.districtId,
        equals('7c7faa9f-4cbb-450d-9046-15ef51430cd9'),
      );
    });
  });
}
