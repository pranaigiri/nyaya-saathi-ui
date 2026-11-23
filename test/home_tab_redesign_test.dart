import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyaya_saathi/screens/citizen/tabs/home_tab.dart';
import 'package:nyaya_saathi/providers/language_provider.dart';
import 'package:nyaya_saathi/providers/draft_provider.dart';
import 'package:nyaya_saathi/providers/auth_provider.dart';
import 'package:nyaya_saathi/providers/application_provider.dart';
import 'package:nyaya_saathi/data/repositories/application_repository.dart';
import 'package:nyaya_saathi/models/legal_aid_application.dart';

class FakeApplicationRepository extends ApplicationRepository {
  @override
  Future<List<LegalAidApplication>> getMyApplications({String? applicantId}) async => [];
}

Widget createTestHomeTab({
  LanguageProvider? langProvider,
  DraftProvider? draftProvider,
  AuthProvider? authProvider,
  ApplicationProvider? appProvider,
}) {
  final lProvider =
      langProvider ?? (LanguageProvider()..completeFirstLaunch('en'));

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LanguageProvider>.value(value: lProvider),
      ChangeNotifierProvider<DraftProvider>(
        create: (_) => draftProvider ?? DraftProvider(),
      ),
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => authProvider ?? AuthProvider(),
      ),
      ChangeNotifierProvider<ApplicationProvider>(
        create: (_) =>
            appProvider ?? ApplicationProvider(FakeApplicationRepository()),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(body: HomeTab()),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Logged-in HomeTab Redesign Tests', () {
    testWidgets('renders all matching sections as per unauth screen', (
      tester,
    ) async {
      await tester.pumpWidget(createTestHomeTab());
      await tester.pumpAndSettle();

      // Citizen Header & Audio Guidance
      expect(find.text('Listen'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsWidgets);

      // Section 1: Fill the form yourself
      expect(find.text('Fill the form yourself'), findsOneWidget);
      expect(find.text('Apply online yourself'), findsOneWidget);

      // Section 2: Talk to an officer
      expect(find.text('Talk to an officer'), findsOneWidget);
      expect(find.text('Call for free legal help'), findsOneWidget);
      expect(find.text('15100'), findsOneWidget);
      expect(find.text('Ask us to call you'), findsOneWidget);

      // Section 3: Not sure?
      expect(find.text('Not sure?'), findsOneWidget);
      expect(find.text('Do I qualify?'), findsOneWidget);

      // Section 4: Already applied?
      expect(find.text('Already applied?'), findsOneWidget);
      expect(find.text('Check my application'), findsOneWidget);

      // Institutional footer
      expect(
        find.text('Sikkim State Legal Services Authority'),
        findsWidgets,
      );
    });

    testWidgets('verifies section hierarchy: 1 then 2 then 3 then 4', (
      tester,
    ) async {
      await tester.pumpWidget(createTestHomeTab());
      await tester.pumpAndSettle();

      final fillFormY =
          tester.getTopLeft(find.text('Fill the form yourself')).dy;
      final talkOfficerY =
          tester.getTopLeft(find.text('Talk to an officer')).dy;
      final notSureY = tester.getTopLeft(find.text('Not sure?')).dy;
      final alreadyAppliedY =
          tester.getTopLeft(find.text('Already applied?')).dy;

      expect(fillFormY, lessThan(talkOfficerY));
      expect(talkOfficerY, lessThan(notSureY));
      expect(notSureY, lessThan(alreadyAppliedY));
    });
  });
}
