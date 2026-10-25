import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/phone_utils.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../citizen/unauth_home_screen.dart';
import '../citizen/citizen_dashboard_shell.dart';
import '../citizen/tracking_screen.dart';

class ApplicationSuccessScreen extends StatelessWidget {
  final String applicationNumber;
  final bool isQuickMode;
  final String? phoneNumber;

  const ApplicationSuccessScreen({
    super.key,
    required this.applicationNumber,
    this.isQuickMode = false,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final isAuth = Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maskedPhone = PhoneUtils.maskPhone(phoneNumber);

    final callNotice = context
        .tr("quick_apply_success_call_notice")
        .replaceAll('{phone}', maskedPhone);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated-style check icon circle
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.successGreen.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 64),
                ),
                const SizedBox(height: 24),

                Text(
                  isQuickMode
                      ? context.tr("callback_request_received")
                      : context.tr("application_submitted"),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  isQuickMode
                      ? context.tr("callback_request_desc")
                      : context.tr("application_submitted_desc"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Mode Call Notice Banner
                if (isQuickMode && phoneNumber != null && phoneNumber!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F9D78).withValues(alpha: isDark ? 0.2 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF0F9D78).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.phone_callback_rounded,
                          color: Color(0xFF0F9D78),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                callNotice,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  color: isDark ? Colors.white : AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Registered Mobile: $maskedPhone",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0F9D78),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Tracking ID Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryBlue, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.tr("your_tracking_id"),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              applicationNumber,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: isDark ? Colors.white : AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: applicationNumber));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.tr("tracking_id_copied")),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.primaryBlue),
                              tooltip: context.tr("copy_tracking_id"),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr("save_tracking_id_notice"),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Primary Action Button: "Track My Applications" in quick mode
                if (isQuickMode && phoneNumber != null && phoneNumber!.isNotEmpty) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrackingScreen(initialPhone: phoneNumber),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search_rounded, size: 20),
                      label: Text(
                        context.tr("track_my_applications"),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6750C8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Secondary Action Buttons: Share & Home/Dashboard
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Share.share("My Nyaya Saathi Legal Aid Tracking ID is $applicationNumber");
                        },
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(context.tr("share_id")),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => isAuth
                                  ? const CitizenDashboardShell()
                                  : const UnauthHomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: Icon(isAuth ? Icons.dashboard_rounded : Icons.home_rounded, size: 18),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(isAuth ? context.tr("dashboard") : context.tr("nav_home")),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
