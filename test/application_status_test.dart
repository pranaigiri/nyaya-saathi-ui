import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyaya_saathi/models/application_status.dart';

void main() {
  group('ApplicationStatus', () {
    test('parses official database statuses correctly', () {
      expect(ApplicationStatus.fromString('SUBMITTED'), ApplicationStatus.submitted);
      expect(ApplicationStatus.fromString('UNDER_REVIEW'), ApplicationStatus.underReview);
      expect(ApplicationStatus.fromString('ADVOCATE_ASSIGNED'), ApplicationStatus.advocateAssigned);
      expect(ApplicationStatus.fromString('RESOLVED'), ApplicationStatus.resolved);
      expect(ApplicationStatus.fromString('REJECTED'), ApplicationStatus.rejected);
      expect(ApplicationStatus.fromString('WITHDRAWN'), ApplicationStatus.withdrawn);
    });

    test('parses legacy and alternate statuses gracefully', () {
      expect(ApplicationStatus.fromString('DRAFT'), ApplicationStatus.submitted);
      expect(ApplicationStatus.fromString('UNDER_SCRUTINY'), ApplicationStatus.underReview);
      expect(ApplicationStatus.fromString('APPROVED_SLSA'), ApplicationStatus.resolved);
      expect(ApplicationStatus.fromString('ASSIGNED_TO_ADVOCATE'), ApplicationStatus.advocateAssigned);
      expect(ApplicationStatus.fromString('ADVOCATE_ACCEPTED'), ApplicationStatus.advocateAssigned);
      expect(ApplicationStatus.fromString('CASE_IN_PROGRESS'), ApplicationStatus.advocateAssigned);
      expect(ApplicationStatus.fromString('DISPOSED'), ApplicationStatus.resolved);
      expect(ApplicationStatus.fromString('CLOSED'), ApplicationStatus.withdrawn);
    });

    test('handles case-insensitivity and whitespace', () {
      expect(ApplicationStatus.fromString('  submitted  '), ApplicationStatus.submitted);
      expect(ApplicationStatus.fromString('under_review'), ApplicationStatus.underReview);
      expect(ApplicationStatus.fromString(null), ApplicationStatus.submitted);
      expect(ApplicationStatus.fromString(''), ApplicationStatus.submitted);
    });

    test('checks terminal statuses correctly', () {
      expect(ApplicationStatus.submitted.isTerminal, isFalse);
      expect(ApplicationStatus.underReview.isTerminal, isFalse);
      expect(ApplicationStatus.advocateAssigned.isTerminal, isFalse);
      expect(ApplicationStatus.resolved.isTerminal, isTrue);
      expect(ApplicationStatus.rejected.isTerminal, isTrue);
      expect(ApplicationStatus.withdrawn.isTerminal, isTrue);
    });

    test('provides human-readable display labels', () {
      expect(ApplicationStatus.submitted.displayLabel, 'Submitted');
      expect(ApplicationStatus.underReview.displayLabel, 'Under Review');
      expect(ApplicationStatus.advocateAssigned.displayLabel, 'Advocate Assigned');
      expect(ApplicationStatus.resolved.displayLabel, 'Resolved');
      expect(ApplicationStatus.rejected.displayLabel, 'Rejected');
      expect(ApplicationStatus.withdrawn.displayLabel, 'Withdrawn');
    });

    test('returns valid color for dark and light modes', () {
      for (final status in ApplicationStatus.values) {
        expect(status.getColor(false), isA<Color>());
        expect(status.getColor(true), isA<Color>());
      }
    });
  });

  group('AdvocateAcceptanceStatus', () {
    test('parses advocate acceptance states correctly', () {
      expect(AdvocateAcceptanceStatus.fromString('NONE'), AdvocateAcceptanceStatus.none);
      expect(AdvocateAcceptanceStatus.fromString('PENDING'), AdvocateAcceptanceStatus.pending);
      expect(AdvocateAcceptanceStatus.fromString('ACCEPTED'), AdvocateAcceptanceStatus.accepted);
      expect(AdvocateAcceptanceStatus.fromString('REJECTED'), AdvocateAcceptanceStatus.rejected);
      expect(AdvocateAcceptanceStatus.fromString(null), AdvocateAcceptanceStatus.none);
      expect(AdvocateAcceptanceStatus.fromString('UNKNOWN'), AdvocateAcceptanceStatus.none);
    });

    test('provides valid icon, label and color', () {
      for (final status in AdvocateAcceptanceStatus.values) {
        expect(status.icon, isA<IconData>());
        expect(status.displayLabel, isNotEmpty);
        expect(status.getColor(false), isA<Color>());
        expect(status.getColor(true), isA<Color>());
      }
    });
  });
}
