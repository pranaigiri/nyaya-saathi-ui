import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyaya_saathi/core/utils/app_icon_resolver.dart';

void main() {
  group('AppIconResolver', () {
    test('resolves tabler icons correctly', () {
      expect(AppIconResolver.resolve('tabler:gavel'), Icons.gavel_rounded);
      expect(AppIconResolver.resolve('tabler:shield'), Icons.shield_rounded);
      expect(AppIconResolver.resolve('tabler:users'), Icons.groups_rounded);
      expect(AppIconResolver.resolve('tabler:heart'), Icons.favorite_rounded);
      expect(AppIconResolver.resolve('tabler:home'), Icons.home_rounded);
      expect(AppIconResolver.resolve('tabler:building'), Icons.apartment_rounded);
      expect(AppIconResolver.resolve('tabler:briefcase'), Icons.work_rounded);
      expect(AppIconResolver.resolve('tabler:file'), Icons.description_rounded);
      expect(AppIconResolver.resolve('tabler:calendar'), Icons.calendar_today_rounded);
      expect(AppIconResolver.resolve('tabler:clock'), Icons.schedule_rounded);
      expect(AppIconResolver.resolve('tabler:bell'), Icons.notifications_rounded);
    });

    test('resolves material: and lucide: prefixes', () {
      expect(AppIconResolver.resolve('material:gavel'), Icons.gavel_rounded);
      expect(AppIconResolver.resolve('material:school'), Icons.school_rounded);
      expect(AppIconResolver.resolve('lucide:shield'), Icons.shield_rounded);
      expect(AppIconResolver.resolve('lucide:car'), Icons.directions_car_rounded);
    });

    test('resolves legacy PrimeIcons (pi pi-*) format', () {
      expect(AppIconResolver.resolve('pi pi-gavel'), Icons.gavel_rounded);
      expect(AppIconResolver.resolve('pi pi-shield'), Icons.shield_rounded);
      expect(AppIconResolver.resolve('pi pi-users'), Icons.groups_rounded);
      expect(AppIconResolver.resolve('pi pi-briefcase'), Icons.work_rounded);
    });

    test('resolves keyword fallbacks', () {
      expect(AppIconResolver.resolve('legal_gavel_action'), Icons.gavel_rounded);
      expect(AppIconResolver.resolve('child_protection_service'), Icons.child_care_rounded);
      expect(AppIconResolver.resolve('medical_disability_record'), Icons.accessible_rounded);
    });

    test('handles null, empty, and unknown icon gracefully without crashing', () {
      expect(AppIconResolver.resolve(null), Icons.gavel_rounded);
      expect(AppIconResolver.resolve(''), Icons.gavel_rounded);
      expect(AppIconResolver.resolve('   '), Icons.gavel_rounded);
      expect(AppIconResolver.resolve('completely_unknown_identifier_xyz'), Icons.gavel_rounded);
      expect(
        AppIconResolver.resolve('completely_unknown_identifier_xyz', fallback: Icons.help_outline),
        Icons.help_outline,
      );
    });
  });
}
