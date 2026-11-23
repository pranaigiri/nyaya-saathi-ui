import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyaya_saathi/data/repositories/local_apply_repository.dart';
import 'package:nyaya_saathi/models/profile.dart';
import 'package:nyaya_saathi/providers/apply_data_provider.dart';
import 'package:nyaya_saathi/providers/auth_provider.dart';
import 'package:nyaya_saathi/providers/language_provider.dart';
import 'package:nyaya_saathi/providers/theme_provider.dart';
import 'package:nyaya_saathi/screens/citizen/profile_screen.dart';

class MockAuthProvider extends AuthProvider {
  bool signOutCalled = false;
  final Profile? _mockProfile;

  MockAuthProvider({Profile? profile}) : _mockProfile = profile;

  @override
  Profile? get profile => _mockProfile;

  @override
  String get userName => _mockProfile?.fullName ?? 'Test Citizen';

  @override
  String get userEmail => _mockProfile?.email ?? 'test@example.com';

  @override
  Future<void> signOut({bool silent = false}) async {
    signOutCalled = true;
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthProvider mockAuthProvider;
  late ApplyDataProvider applyDataProvider;
  late LanguageProvider languageProvider;
  late ThemeProvider themeProvider;

  final testProfile = Profile(
    id: 'user-123',
    fullName: 'Aarav Sharma',
    email: 'aarav@example.com',
    phoneNumber: '9876543210',
    gender: 'Male',
    dob: '1995-05-15',
    villageOrTown: 'Gangtok',
    districtId: '1',
    userType: 'CITIZEN',
    status: 'ACTIVE',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAuthProvider = MockAuthProvider(profile: testProfile);
    applyDataProvider = ApplyDataProvider(LocalApplyRepository());
    languageProvider = LanguageProvider()..completeFirstLaunch('en');
    themeProvider = ThemeProvider();
  });

  Widget createProfileScreen({VoidCallback? onLoggedOut}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ApplyDataProvider>.value(value: applyDataProvider),
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: MaterialApp(
        home: ProfileScreen(onLoggedOut: onLoggedOut),
      ),
    );
  }

  group('ProfileScreen Logout Confirmation Dialog Tests', () {
    testWidgets('tapping logout button displays confirmation dialog with title, body, cancel and confirm buttons', (tester) async {
      await tester.pumpWidget(createProfileScreen());
      await tester.pumpAndSettle();

      // Find logout button by key and scroll to it
      final logoutBtnFinder = find.byKey(const Key('profile_logout_button'));
      expect(logoutBtnFinder, findsOneWidget);

      await tester.ensureVisible(logoutBtnFinder);
      await tester.pumpAndSettle();

      // Tap logout button
      await tester.tap(logoutBtnFinder);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('logout_confirm_title'), findsOneWidget);
      expect(find.text('logout_confirm_body'), findsOneWidget);
      expect(find.byKey(const Key('logout_cancel_button')), findsOneWidget);
      expect(find.byKey(const Key('logout_confirm_button')), findsOneWidget);
    });

    testWidgets('cancelling logout confirmation dialog closes dialog and does NOT call signOut', (tester) async {
      await tester.pumpWidget(createProfileScreen());
      await tester.pumpAndSettle();

      final logoutBtnFinder = find.byKey(const Key('profile_logout_button'));
      await tester.ensureVisible(logoutBtnFinder);
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(logoutBtnFinder);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap Cancel button
      final cancelBtnFinder = find.byKey(const Key('logout_cancel_button'));
      await tester.tap(cancelBtnFinder);
      await tester.pumpAndSettle();

      // Dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing);

      // Sign out was NOT called
      expect(mockAuthProvider.signOutCalled, isFalse);

      // User is still on ProfileScreen
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('confirming logout in confirmation dialog calls signOut and triggers onLoggedOut', (tester) async {
      bool onLoggedOutCalled = false;
      await tester.pumpWidget(createProfileScreen(
        onLoggedOut: () {
          onLoggedOutCalled = true;
        },
      ));
      await tester.pumpAndSettle();

      final logoutBtnFinder = find.byKey(const Key('profile_logout_button'));
      await tester.ensureVisible(logoutBtnFinder);
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(logoutBtnFinder);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap Confirm Logout button
      final confirmBtnFinder = find.byKey(const Key('logout_confirm_button'));
      await tester.tap(confirmBtnFinder);
      await tester.pumpAndSettle();

      // Sign out was called
      expect(mockAuthProvider.signOutCalled, isTrue);

      // onLoggedOut callback was invoked
      expect(onLoggedOutCalled, isTrue);
    });
  });
}
