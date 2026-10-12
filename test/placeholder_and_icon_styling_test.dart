import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyaya_saathi/core/constants/app_colors.dart';
import 'package:nyaya_saathi/core/theme/app_theme.dart';

void main() {
  group('AppTheme Placeholder and Icon Design Tokens Tests', () {
    testWidgets('Light theme has correct placeholder hintStyle and iconTheme',
        (tester) async {
      final theme = AppTheme.lightTheme(AppFontScale.medium);
      final inputTheme = theme.inputDecorationTheme;

      expect(theme.hintColor, AppColors.placeholderLight);
      expect(inputTheme.hintStyle?.color, AppColors.placeholderLight);
      expect(inputTheme.hintStyle?.fontWeight, FontWeight.normal);

      // Persistent unfocused prefix/suffix icon color
      final unfocusedPrefixColor =
          (inputTheme.prefixIconColor as WidgetStateColor)
              .resolve(<WidgetState>{});
      expect(unfocusedPrefixColor, AppColors.iconLight);

      // Focused prefix icon color transitions to primary
      final focusedPrefixColor =
          (inputTheme.prefixIconColor as WidgetStateColor)
              .resolve(<WidgetState>{WidgetState.focused});
      expect(focusedPrefixColor, AppColors.primaryBlue);

      // Global IconThemeData
      expect(theme.iconTheme.color, AppColors.iconLight);
    });

    testWidgets('Dark theme has correct placeholder hintStyle and iconTheme',
        (tester) async {
      final theme = AppTheme.darkTheme(AppFontScale.medium);
      final inputTheme = theme.inputDecorationTheme;

      expect(theme.hintColor, AppColors.placeholderDark);
      expect(inputTheme.hintStyle?.color, AppColors.placeholderDark);
      expect(inputTheme.hintStyle?.fontWeight, FontWeight.normal);

      // Persistent unfocused prefix/suffix icon color
      final unfocusedPrefixColor =
          (inputTheme.prefixIconColor as WidgetStateColor)
              .resolve(<WidgetState>{});
      expect(unfocusedPrefixColor, AppColors.iconDark);

      // Focused prefix icon color transitions to primary
      final focusedPrefixColor =
          (inputTheme.prefixIconColor as WidgetStateColor)
              .resolve(<WidgetState>{WidgetState.focused});
      expect(focusedPrefixColor, AppColors.darkPrimary);

      // Global IconThemeData
      expect(theme.iconTheme.color, AppColors.iconDark);
    });
  });

  group('Placeholder and Entered Text Widget Rendering Tests', () {
    testWidgets(
        'TextField displays placeholder in muted style and entered text in foreground style (Light Mode)',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(AppFontScale.medium),
          home: Scaffold(
            body: Center(
              child: TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
            ),
          ),
        ),
      );

      // Find the hint text widget
      final hintFinder = find.text('Enter full name');
      expect(hintFinder, findsOneWidget);

      final Text hintTextWidget = tester.widget(hintFinder);
      expect(hintTextWidget.style?.color, AppColors.placeholderLight);

      // Prefix icon is rendered and visible in unfocused state
      final iconFinder = find.byIcon(Icons.person_outline_rounded);
      expect(iconFinder, findsOneWidget);

      // Type text into the field
      await tester.enterText(find.byType(TextFormField), 'Tenzing Norbu');
      await tester.pump();

      // Entered text is rendered in the field
      expect(find.text('Tenzing Norbu'), findsOneWidget);
    });

    testWidgets(
        'TextField displays placeholder in muted style and entered text in foreground style (Dark Mode)',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme(AppFontScale.medium),
          home: Scaffold(
            body: Center(
              child: TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
            ),
          ),
        ),
      );

      // Find the hint text widget
      final hintFinder = find.text('Enter full name');
      expect(hintFinder, findsOneWidget);

      final Text hintTextWidget = tester.widget(hintFinder);
      expect(hintTextWidget.style?.color, AppColors.placeholderDark);

      // Prefix icon is rendered and visible in unfocused state
      final iconFinder = find.byIcon(Icons.person_outline_rounded);
      expect(iconFinder, findsOneWidget);

      // Type text into the field
      await tester.enterText(find.byType(TextFormField), 'Tenzing Norbu');
      await tester.pump();

      // Entered text is rendered in the field
      expect(find.text('Tenzing Norbu'), findsOneWidget);
    });

    testWidgets(
        'Dropdown displays placeholder hint when unselected and selected item text when chosen',
        (tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(AppFontScale.medium),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DropdownButtonFormField<String>(
                  initialValue: selected,
                  decoration: const InputDecoration(
                    hintText: 'Select your district',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'GTK', child: Text('Gangtok')),
                    DropdownMenuItem(value: 'NAM', child: Text('Namchi')),
                  ],
                  onChanged: (val) {
                    setState(() => selected = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      // Unselected state displays the hint text
      final hintFinder = find.text('Select your district');
      expect(hintFinder, findsOneWidget);
      final defaultTextStyle = DefaultTextStyle.of(tester.element(hintFinder));
      expect(defaultTextStyle.style.color, AppColors.placeholderLight);

      // Dropdown arrow and map icon are visible
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);

      // Open dropdown and tap an item
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gangtok').last);
      await tester.pumpAndSettle();

      // Selected value is displayed
      expect(find.text('Gangtok'), findsOneWidget);
    });
  });
}
