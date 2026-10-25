import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyaya_saathi/data/repositories/local_apply_repository.dart';
import 'package:nyaya_saathi/providers/apply_data_provider.dart';
import 'package:nyaya_saathi/providers/draft_provider.dart';
import 'package:nyaya_saathi/screens/apply_flow/apply_wizard_screen.dart';
import 'package:nyaya_saathi/widgets/draft_resumption_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DraftResumptionCard Discard & Delete Tests', () {
    late DraftProvider draftProvider;
    late ApplyDataProvider applyDataProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      draftProvider = DraftProvider();
      applyDataProvider = ApplyDataProvider(LocalApplyRepository());
      draftProvider.setApplyDataProvider(applyDataProvider);

      await draftProvider.startNewDraft();
      // Add meaningful data so the card displays
      await draftProvider.updateApplicantDetails(
        fullName: 'Ram Bahadur',
        email: 'ram@example.com',
        phone: '9841234567',
        gender: 'Male',
        dob: '1990-01-01',
        villageTown: 'Kathmandu',
        districtId: 1,
        districtName: 'Kathmandu',
      );
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<DraftProvider>.value(value: draftProvider),
          ChangeNotifierProvider<ApplyDataProvider>.value(value: applyDataProvider),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: DraftResumptionCard(showDiscardButton: true),
          ),
        ),
      );
    }

    testWidgets('renders resume and discard buttons when draft has meaningful data', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('draft_found_title'), findsOneWidget);
      expect(find.text('resume'), findsOneWidget);
      expect(find.text('discard'), findsOneWidget);
    });

    testWidgets('cancelling discard dialog keeps draft intact', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Discard button
      await tester.tap(find.text('discard'));
      await tester.pumpAndSettle();

      // Dialog should appear with delete_draft_title, cancel, and delete
      expect(find.text('delete_draft_title'), findsOneWidget);
      expect(find.text('cancel'), findsOneWidget);
      expect(find.text('delete'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('cancel'));
      await tester.pumpAndSettle();

      // Dialog dismissed, draft remains intact, card still present
      expect(find.text('delete_draft_title'), findsNothing);
      expect(find.text('draft_found_title'), findsOneWidget);
      expect(draftProvider.draft, isNotNull);
    });

    testWidgets('confirming delete discards draft, does NOT navigate to apply wizard, and shows snackbar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Discard button
      await tester.tap(find.text('discard'));
      await tester.pumpAndSettle();

      // Tap Delete in dialog
      await tester.tap(find.text('delete'));
      await tester.pumpAndSettle();

      // Draft should be completely cleared
      expect(draftProvider.draft, isNull);

      // Should NOT have navigated to ApplyWizardScreen
      expect(find.byType(ApplyWizardScreen), findsNothing);

      // Confirmation SnackBar should be displayed with friendly message
      expect(find.text('Draft application deleted successfully.'), findsOneWidget);

      // Draft resumption card should have disappeared
      expect(find.text('draft_found_title'), findsNothing);
    });
  });
}
