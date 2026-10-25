import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/draft_provider.dart';

class RateLimitDialog extends StatelessWidget {
  final int retryAfterMinutes;
  final String? phoneNumber;

  const RateLimitDialog({
    super.key,
    this.retryAfterMinutes = 10,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Icon
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.35) : const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFFB45309).withValues(alpha: 0.5) : const Color(0xFFFDE68A),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: Color(0xFFD97706),
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              "Submission Limit Reached",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Explanation
            Text(
              phoneNumber != null && phoneNumber!.isNotEmpty
                  ? "To prevent duplicate applications and ensure fair access, only 1 application can be submitted every $retryAfterMinutes minutes for $phoneNumber."
                  : "To prevent duplicate applications and ensure fair access, only 1 application can be submitted every $retryAfterMinutes minutes from this phone number.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),

            // Retry Window Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_filled,
                    color: isDark ? const Color(0xFF93C5FD) : AppColors.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Please wait approx. $retryAfterMinutes minutes before resubmitting.",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF93C5FD) : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Draft Preservation Reassurance
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF047857).withValues(alpha: 0.4) : const Color(0xFFA7F3D0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.successGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "All your form details and uploaded documents are safely saved in your draft. No information has been lost.",
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Primary Action: Save Draft & Return Home
            ElevatedButton.icon(
              icon: const Icon(Icons.bookmark_added_outlined, color: Colors.white, size: 20),
              label: const Text(
                "Save Draft & Return Home",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                final draftProvider = Provider.of<DraftProvider>(context, listen: false);
                await draftProvider.saveDraft();
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).popUntil((route) => route.isFirst); // Go to Home
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Draft saved! Tap 'Resume' on the Home screen anytime to submit."),
                      backgroundColor: AppColors.successGreen,
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),

            // Secondary Action: Stay on Review Screen
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text(
                "Stay on this Screen",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showRateLimitDialog({
  required BuildContext context,
  int retryAfterMinutes = 10,
  String? phoneNumber,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => RateLimitDialog(
      retryAfterMinutes: retryAfterMinutes,
      phoneNumber: phoneNumber,
    ),
  );
}
