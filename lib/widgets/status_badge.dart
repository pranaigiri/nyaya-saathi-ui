import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getStatusColor() {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
      case 'DRAFT':
        return AppColors.infoCyan;
      case 'UNDER_SCRUTINY':
        return AppColors.warningOrange;
      case 'APPROVED_SLSA':
      case 'ASSIGNED_TO_ADVOCATE':
      case 'ADVOCATE_ACCEPTED':
      case 'CASE_IN_PROGRESS':
        return AppColors.successGreen;
      case 'REJECTED':
        return AppColors.dangerRed;
      case 'CLOSED':
      case 'WITHDRAWN':
        return Colors.grey;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _getReadableText() {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
        return 'Submitted';
      case 'UNDER_SCRUTINY':
        return 'Under Scrutiny';
      case 'APPROVED_SLSA':
        return 'Approved by SLSA';
      case 'ASSIGNED_TO_ADVOCATE':
        return 'Advocate Assigned';
      case 'CASE_IN_PROGRESS':
        return 'Case In Progress';
      case 'REJECTED':
        return 'Rejected';
      case 'CLOSED':
        return 'Closed';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _getReadableText(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
