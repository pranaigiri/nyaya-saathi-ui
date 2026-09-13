import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Centralized application status enum aligned with the Supabase database
/// check constraint: `status IN ('SUBMITTED', 'UNDER_REVIEW', 'ADVOCATE_ASSIGNED', 'RESOLVED', 'REJECTED', 'WITHDRAWN')`.
enum ApplicationStatus {
  submitted('SUBMITTED', 'Submitted'),
  underReview('UNDER_REVIEW', 'Under Review'),
  advocateAssigned('ADVOCATE_ASSIGNED', 'Advocate Assigned'),
  resolved('RESOLVED', 'Resolved'),
  rejected('REJECTED', 'Rejected'),
  withdrawn('WITHDRAWN', 'Withdrawn');

  final String dbValue;
  final String displayLabel;

  const ApplicationStatus(this.dbValue, this.displayLabel);

  /// Safe parser that handles current database values, case variations,
  /// and gracefully tolerates legacy historical values without crashing.
  static ApplicationStatus fromString(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return ApplicationStatus.submitted;
    }

    final upper = raw.trim().toUpperCase();
    switch (upper) {
      case 'SUBMITTED':
      case 'DRAFT':
        return ApplicationStatus.submitted;

      case 'UNDER_REVIEW':
      case 'UNDER_SCRUTINY':
      case 'IN_REVIEW':
        return ApplicationStatus.underReview;

      case 'ADVOCATE_ASSIGNED':
      case 'ASSIGNED_TO_ADVOCATE':
      case 'ADVOCATE_ACCEPTED':
      case 'HEARING_SCHEDULED':
      case 'ACTION_TAKEN':
      case 'IN_PROGRESS':
      case 'CASE_IN_PROGRESS':
        return ApplicationStatus.advocateAssigned;

      case 'RESOLVED':
      case 'DISPOSED':
      case 'APPROVED_SLSA':
      case 'COMPLETED':
        return ApplicationStatus.resolved;

      case 'REJECTED':
        return ApplicationStatus.rejected;

      case 'WITHDRAWN':
      case 'CLOSED':
        return ApplicationStatus.withdrawn;

      default:
        return ApplicationStatus.submitted;
    }
  }

  /// True if the application is in a terminal/completed state.
  bool get isTerminal =>
      this == ApplicationStatus.resolved ||
      this == ApplicationStatus.rejected ||
      this == ApplicationStatus.withdrawn;

  /// True if the application is currently active/open.
  bool get isActive => !isTerminal;

  /// Returns canonical theme color for status badge/display.
  Color getColor(bool isDark) {
    switch (this) {
      case ApplicationStatus.submitted:
        return isDark ? AppColors.skyBlue : AppColors.infoCyan;
      case ApplicationStatus.underReview:
        return isDark ? AppColors.amberGold : AppColors.warningOrange;
      case ApplicationStatus.advocateAssigned:
        return isDark ? AppColors.mintGreen : AppColors.successGreen;
      case ApplicationStatus.resolved:
        return isDark ? AppColors.mintGreen : AppColors.successGreen;
      case ApplicationStatus.rejected:
        return isDark ? AppColors.roseRed : AppColors.dangerRed;
      case ApplicationStatus.withdrawn:
        return isDark ? const Color(0xFF94A3B8) : Colors.grey;
    }
  }

  /// Icon representation for timeline / badges.
  IconData get icon {
    switch (this) {
      case ApplicationStatus.submitted:
        return Icons.assignment_turned_in_rounded;
      case ApplicationStatus.underReview:
        return Icons.fact_check_rounded;
      case ApplicationStatus.advocateAssigned:
        return Icons.shield_rounded;
      case ApplicationStatus.resolved:
        return Icons.verified_rounded;
      case ApplicationStatus.rejected:
        return Icons.cancel_rounded;
      case ApplicationStatus.withdrawn:
        return Icons.remove_circle_outline_rounded;
    }
  }
}

/// Centralized advocate acceptance status enum aligned with the Supabase database
/// check constraint: `advocate_acceptance_status IN ('NONE', 'PENDING', 'ACCEPTED', 'REJECTED')`.
enum AdvocateAcceptanceStatus {
  none('NONE', 'Not Assigned'),
  pending('PENDING', 'Pending Acceptance'),
  accepted('ACCEPTED', 'Accepted'),
  rejected('REJECTED', 'Declined');

  final String dbValue;
  final String displayLabel;

  const AdvocateAcceptanceStatus(this.dbValue, this.displayLabel);

  static AdvocateAcceptanceStatus fromString(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return AdvocateAcceptanceStatus.none;
    }

    final upper = raw.trim().toUpperCase();
    switch (upper) {
      case 'PENDING':
        return AdvocateAcceptanceStatus.pending;
      case 'ACCEPTED':
        return AdvocateAcceptanceStatus.accepted;
      case 'REJECTED':
        return AdvocateAcceptanceStatus.rejected;
      case 'NONE':
      default:
        return AdvocateAcceptanceStatus.none;
    }
  }

  Color getColor(bool isDark) {
    switch (this) {
      case AdvocateAcceptanceStatus.none:
        return isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
      case AdvocateAcceptanceStatus.pending:
        return isDark ? AppColors.amberGold : AppColors.warningOrange;
      case AdvocateAcceptanceStatus.accepted:
        return isDark ? AppColors.mintGreen : AppColors.successGreen;
      case AdvocateAcceptanceStatus.rejected:
        return isDark ? AppColors.roseRed : AppColors.dangerRed;
    }
  }

  IconData get icon {
    switch (this) {
      case AdvocateAcceptanceStatus.none:
        return Icons.hourglass_empty_rounded;
      case AdvocateAcceptanceStatus.pending:
        return Icons.pending_actions_rounded;
      case AdvocateAcceptanceStatus.accepted:
        return Icons.check_circle_rounded;
      case AdvocateAcceptanceStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}
