import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyaya_saathi/data/repositories/local_apply_repository.dart';
import 'package:nyaya_saathi/providers/apply_data_provider.dart';
import 'package:nyaya_saathi/providers/draft_provider.dart';
import 'package:nyaya_saathi/widgets/rate_limit_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RateLimitDialog Widget Tests', () {
    late DraftProvider draftProvider;
    late ApplyDataProvider applyDataProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      draftProvider = DraftProvider();
      applyDataProvider = ApplyDataProvider(LocalApplyRepository());
      draftProvider.setApplyDataProvider(applyDataProvider);
      await draftProvider.startNewDraft();
    });

    Widget createTestWidget({required Widget child}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<DraftProvider>.value(value: draftProvider),
          ChangeNotifierProvider<ApplyDataProvider>.value(value: applyDataProvider),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: child,
          ),
        ),
      );
    }

    testWidgets('renders rate limit details, retry duration, and preservation note', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const RateLimitDialog(
            retryAfterMinutes: 10,
            phoneNumber: '9898989898',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Submission Limit Reached'), findsOneWidget);
      expect(find.textContaining('9898989898'), findsOneWidget);
      expect(find.textContaining('Please wait approx. 10 minutes before resubmitting.'), findsOneWidget);
      expect(find.textContaining('All your form details and uploaded documents are safely saved'), findsOneWidget);
      expect(find.text('Save Draft & Return Home'), findsOneWidget);
      expect(find.text('Stay on this Screen'), findsOneWidget);
    });

    testWidgets('Save Draft & Return Home saves draft and navigates', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showRateLimitDialog(
                    context: context,
                    retryAfterMinutes: 10,
                    phoneNumber: '9898989898',
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap button to open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Submission Limit Reached'), findsOneWidget);

      // Tap Save Draft & Return Home
      await tester.tap(find.text('Save Draft & Return Home'));
      await tester.pumpAndSettle();

      // Dialog is dismissed
      expect(find.text('Submission Limit Reached'), findsNothing);
      // SnackBar shown
      expect(find.textContaining("Draft saved! Tap 'Resume' on the Home screen anytime"), findsOneWidget);
    });

    testWidgets('Stay on this Screen dismisses dialog and keeps user on current view', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showRateLimitDialog(
                    context: context,
                    retryAfterMinutes: 10,
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Submission Limit Reached'), findsOneWidget);

      await tester.tap(find.text('Stay on this Screen'));
      await tester.pumpAndSettle();

      expect(find.text('Submission Limit Reached'), findsNothing);
      expect(find.text('Open Dialog'), findsOneWidget);
    });
  });
}
