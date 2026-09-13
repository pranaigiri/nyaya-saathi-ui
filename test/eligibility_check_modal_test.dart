import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nyaya_saathi/data/repositories/local_apply_repository.dart';
import 'package:nyaya_saathi/providers/apply_data_provider.dart';
import 'package:nyaya_saathi/providers/auth_provider.dart';
import 'package:nyaya_saathi/providers/draft_provider.dart';
import 'package:nyaya_saathi/widgets/eligibility_check_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableModal() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApplyDataProvider(LocalApplyRepository())),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DraftProvider()),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: EligibilityCheckModal(),
        ),
      ),
    );
  }

  group('EligibilityCheckModal Tests', () {
    testWidgets('renders initial question (Question 1) correctly', (tester) async {
      await tester.pumpWidget(buildTestableModal());
      await tester.pumpAndSettle();

      expect(find.text('One Tap Eligibility Check'), findsOneWidget);
      expect(find.text('1 of 9'), findsOneWidget);
      expect(find.text('Are you a woman?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);

      // On Question 1, "Previous Question" should not be visible/present
      expect(find.text('Previous Question'), findsNothing);
    });

    testWidgets('advancing to Question 2 shows Previous Question button', (tester) async {
      await tester.pumpWidget(buildTestableModal());
      await tester.pumpAndSettle();

      // Tap "No" to move from Question 1 to Question 2
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(find.text('2 of 9'), findsOneWidget);
      expect(find.text('Is the applicant a child (below 18 years)?'), findsOneWidget);
      expect(find.text('Previous Question'), findsOneWidget);

      // Tap "Previous Question" to return to Question 1
      await tester.tap(find.text('Previous Question'));
      await tester.pumpAndSettle();

      expect(find.text('1 of 9'), findsOneWidget);
      expect(find.text('Are you a woman?'), findsOneWidget);
      expect(find.text('Previous Question'), findsNothing);
    });

    testWidgets('tapping Yes navigates smoothly to Eligible result', (tester) async {
      await tester.pumpWidget(buildTestableModal());
      await tester.pumpAndSettle();

      // Tap Yes on Question 1 ("Are you a woman?")
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.text("You're Eligible"), findsOneWidget);
      expect(find.text('Woman'), findsOneWidget);
      expect(find.text('Apply for Legal Aid'), findsOneWidget);
      expect(find.text('Start Check Again'), findsOneWidget);

      // Tap "Start Check Again" to restart
      await tester.tap(find.text('Start Check Again'));
      await tester.pumpAndSettle();

      expect(find.text('1 of 9'), findsOneWidget);
      expect(find.text('Are you a woman?'), findsOneWidget);
    });

    testWidgets('answering No to all questions navigates to Not Eligible result', (tester) async {
      await tester.pumpWidget(buildTestableModal());
      await tester.pumpAndSettle();

      // Answer "No" to all 9 questions
      for (int i = 0; i < 9; i++) {
        await tester.tap(find.text('No'));
        await tester.pumpAndSettle();
      }

      expect(find.text('You may not be eligible'), findsOneWidget);
      expect(find.text('Start Check Again'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Tap "Start Check Again"
      await tester.tap(find.text('Start Check Again'));
      await tester.pumpAndSettle();

      expect(find.text('1 of 9'), findsOneWidget);
      expect(find.text('Are you a woman?'), findsOneWidget);
    });

    testWidgets('handles long question (Question 6) and multi-step back-and-forth navigation', (tester) async {
      await tester.pumpWidget(buildTestableModal());
      await tester.pumpAndSettle();

      // Navigate Q1 -> Q2 -> Q3 -> Q2 -> Q1
      await tester.tap(find.text('No')); // Q2
      await tester.pumpAndSettle();
      expect(find.text('2 of 9'), findsOneWidget);

      await tester.tap(find.text('No')); // Q3
      await tester.pumpAndSettle();
      expect(find.text('3 of 9'), findsOneWidget);

      await tester.tap(find.text('Previous Question')); // Back to Q2
      await tester.pumpAndSettle();
      expect(find.text('2 of 9'), findsOneWidget);

      await tester.tap(find.text('Previous Question')); // Back to Q1
      await tester.pumpAndSettle();
      expect(find.text('1 of 9'), findsOneWidget);

      // Advance through to Question 6 (the longest question)
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('No'));
        await tester.pumpAndSettle();
      }

      expect(find.text('6 of 9'), findsOneWidget);
      expect(
        find.text(
          'Are you a victim of a mass disaster, ethnic violence, caste atrocity, flood or earthquake?',
        ),
        findsOneWidget,
      );
      expect(find.text('Previous Question'), findsOneWidget);

      // Verify tapping Yes on Question 6 identifies DISASTER_VICTIM
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.text("You're Eligible"), findsOneWidget);
      expect(find.text('Victim of Disaster or Atrocity'), findsOneWidget);
    });

    testWidgets('renders cleanly on small screens and in dark mode without overflow', (tester) async {
      // Simulate small Android phone screen (360x640)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ApplyDataProvider(LocalApplyRepository())),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => DraftProvider()),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: EligibilityCheckModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('One Tap Eligibility Check'), findsOneWidget);
      expect(find.text('1 of 9'), findsOneWidget);

      // Navigate to long question on small screen
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('No'));
        await tester.pumpAndSettle();
      }

      expect(find.text('6 of 9'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

