import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyaya_saathi/models/case_type_master.dart';
import 'package:nyaya_saathi/data/repositories/local_apply_repository.dart';
import 'package:nyaya_saathi/providers/apply_data_provider.dart';
import 'package:nyaya_saathi/providers/draft_provider.dart';
import 'package:nyaya_saathi/screens/apply_flow/step3_casetype_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CaseTypeMaster Model Tests', () {
    test('parses case_type_description correctly from JSON', () {
      final json = {
        'id': 'test-id-1',
        'case_type_code': 'DOMESTIC_VIOLENCE',
        'case_type_name': 'Domestic Violence',
        'case_type_description': 'Legal help for persons facing abuse within the family.',
        'icon_url': 'gavel',
        'display_order': 2,
        'is_active': true,
      };

      final model = CaseTypeMaster.fromJson(json);

      expect(model.id, equals('test-id-1'));
      expect(model.caseTypeCode, equals('DOMESTIC_VIOLENCE'));
      expect(model.caseTypeName, equals('Domestic Violence'));
      expect(model.caseTypeDescription, equals('Legal help for persons facing abuse within the family.'));
      expect(model.iconUrl, equals('gavel'));
      expect(model.displayOrder, equals(2));
      expect(model.isActive, isTrue);
    });

    test('handles null and missing case_type_description gracefully', () {
      final jsonWithoutDesc = {
        'id': 'test-id-2',
        'case_type_code': 'CIVIL_MATTER',
        'case_type_name': 'Civil Matter',
        'display_order': 1,
        'is_active': true,
      };

      final model = CaseTypeMaster.fromJson(jsonWithoutDesc);
      expect(model.caseTypeDescription, isNull);

      final jsonWithNull = {
        'id': 'test-id-3',
        'case_type_code': 'CIVIL_MATTER',
        'case_type_name': 'Civil Matter',
        'case_type_description': null,
      };

      final modelNull = CaseTypeMaster.fromJson(jsonWithNull);
      expect(modelNull.caseTypeDescription, isNull);
    });

    test('toJson serializes case_type_description when present', () {
      const model = CaseTypeMaster(
        id: 'test-id-1',
        caseTypeCode: 'DOMESTIC_VIOLENCE',
        caseTypeName: 'Domestic Violence',
        caseTypeDescription: 'Short citizen description',
        displayOrder: 2,
      );

      final json = model.toJson();
      expect(json['case_type_description'], equals('Short citizen description'));
      expect(json['case_type_code'], equals('DOMESTIC_VIOLENCE'));
    });

    test('toJson omits case_type_description when null', () {
      const model = CaseTypeMaster(
        id: 'test-id-2',
        caseTypeCode: 'CIVIL_MATTER',
        caseTypeName: 'Civil Matter',
      );

      final json = model.toJson();
      expect(json.containsKey('case_type_description'), isFalse);
    });

    test('LocalApplyRepository returns case types with descriptions populated', () async {
      final repo = LocalApplyRepository();
      final caseTypes = await repo.getCaseTypes();

      expect(caseTypes, isNotEmpty);
      for (final ct in caseTypes) {
        expect(ct.caseTypeDescription, isNotNull);
        expect(ct.caseTypeDescription, isNotEmpty);
      }
    });
  });

  group('Step3CaseTypeScreen Widget Tests', () {
    late ApplyDataProvider applyDataProvider;
    late DraftProvider draftProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      applyDataProvider = ApplyDataProvider(LocalApplyRepository());
      draftProvider = DraftProvider();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ApplyDataProvider>.value(value: applyDataProvider),
          ChangeNotifierProvider<DraftProvider>.value(value: draftProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Step3CaseTypeScreen(
              onNext: () {},
              onBack: () {},
            ),
          ),
        ),
      );
    }

    testWidgets('displays case type names without displaying case type codes or collapsed descriptions', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Case type names should be visible
      expect(find.text('Domestic Violence'), findsOneWidget);
      expect(find.text('Succession Certificate'), findsOneWidget);

      // Description should NOT be visible when collapsed (uniform list item heights)
      expect(
        find.textContaining('Legal help for persons facing physical, emotional, verbal'),
        findsNothing,
      );

      // Crucial: case_type_code MUST NOT be displayed to citizens
      expect(find.text('DOMESTIC_VIOLENCE'), findsNothing);
      expect(find.text('SUCCESSION_CERTIFICATE'), findsNothing);
      expect(find.text('PROPERTY_DISPUTE'), findsNothing);
    });

    testWidgets('only shows description when clicking Tap to learn more, not when selecting cases', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final dvDescFinder = find.textContaining('Legal help for persons facing physical, emotional, verbal');
      expect(dvDescFinder, findsNothing);

      // Tap on Domestic Violence card to select it
      await tester.tap(find.text('Domestic Violence'));
      await tester.pumpAndSettle();

      // Should be selected in DraftProvider
      expect(draftProvider.draft?.caseTypeName, equals('Domestic Violence'));
      expect(draftProvider.draft?.caseTypeCode, equals('DOMESTIC_VIOLENCE'));

      // BUT description must still NOT be shown just from selecting!
      expect(dvDescFinder, findsNothing);

      // Find "Tap to learn more" for the card and click it
      await tester.tap(find.text('Tap to learn more').at(1)); // 0 is Succession Certificate, 1 is Domestic Violence
      await tester.pumpAndSettle();

      // NOW description should be shown
      expect(dvDescFinder, findsOneWidget);
      expect(find.text('Show less'), findsOneWidget);

      // Click "Show less"
      await tester.tap(find.text('Show less'));
      await tester.pumpAndSettle();

      // Description should be hidden again
      expect(dvDescFinder, findsNothing);
      expect(find.text('Show less'), findsNothing);
    });

    testWidgets('searching by description term filters case types correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter a term that is present in the description of Domestic Violence: "abuse"
      await tester.enterText(find.byType(TextFormField).first, 'abuse');
      await tester.pumpAndSettle();

      // Domestic Violence should match because description contains "abuse"
      expect(find.text('Domestic Violence'), findsOneWidget);
      // Succession Certificate should NOT match
      expect(find.text('Succession Certificate'), findsNothing);
    });

    testWidgets('case types are ordered strictly by display_order ascending', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // In LocalApplyRepository:
      // displayOrder 1: Succession Certificate
      // displayOrder 2: Domestic Violence
      // displayOrder 3: Property Dispute
      final titles = ['Succession Certificate', 'Domestic Violence', 'Property Dispute'];
      double lastY = -1;
      for (final title in titles) {
        final currentY = tester.getTopLeft(find.text(title)).dy;
        expect(currentY > lastY, isTrue, reason: '$title should appear below the previous item');
        lastY = currentY;
      }
    });
  });
}
