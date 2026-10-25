import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyaya_saathi/data/repositories/local_apply_repository.dart';
import 'package:nyaya_saathi/providers/apply_data_provider.dart';
import 'package:nyaya_saathi/providers/draft_provider.dart';
import 'package:nyaya_saathi/screens/apply_flow/step4_document_upload_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Step4DocumentUploadScreen Widget Tests', () {
    late ApplyDataProvider applyDataProvider;
    late DraftProvider draftProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      applyDataProvider = ApplyDataProvider(LocalApplyRepository());
      draftProvider = DraftProvider();
      draftProvider.setApplyDataProvider(applyDataProvider);
      await draftProvider.startNewDraft();
    });

    Widget createTestWidget({VoidCallback? onNext, VoidCallback? onBack}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ApplyDataProvider>.value(value: applyDataProvider),
          ChangeNotifierProvider<DraftProvider>.value(value: draftProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Step4DocumentUploadScreen(
              onNext: onNext ?? () {},
              onBack: onBack ?? () {},
            ),
          ),
        ),
      );
    }

    testWidgets('shows officer call confirmation notice banner', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('You may skip document uploads for now'), findsOneWidget);
      expect(find.textContaining('An officer will collect and verify the documents via a confirmation call'), findsOneWidget);
      expect(find.textContaining('required to process your legal aid application'), findsOneWidget);
    });

    testWidgets('provides Skip button that proceeds to next step', (tester) async {
      bool nextCalled = false;
      await tester.pumpWidget(createTestWidget(onNext: () => nextCalled = true));
      await tester.pumpAndSettle();

      final skipBtn = find.widgetWithText(OutlinedButton, 'Skip');
      expect(skipBtn, findsOneWidget);

      await tester.tap(skipBtn);
      await tester.pumpAndSettle();

      expect(nextCalled, isTrue);
    });

    testWidgets('allows proceeding via Next button without uploading any documents', (tester) async {
      bool nextCalled = false;
      await tester.pumpWidget(createTestWidget(onNext: () => nextCalled = true));
      await tester.pumpAndSettle();

      final nextBtn = find.widgetWithText(ElevatedButton, 'Next: Review & Submit →');
      expect(nextBtn, findsOneWidget);

      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      expect(nextCalled, isTrue);
    });
  });
}
