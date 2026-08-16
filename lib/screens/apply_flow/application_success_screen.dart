import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../citizen/citizen_dashboard_shell.dart';

class ApplicationSuccessScreen extends StatelessWidget {
  final String applicationNumber;

  const ApplicationSuccessScreen({super.key, required this.applicationNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 64),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Application Submitted!",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your application has been received by Sikkim State Legal Services Authority (SLSA).",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 28),

                // Tracking ID Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryBlue, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Text("YOUR TRACKING ID", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          applicationNumber,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.primaryDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Save this number to track status without logging in.",
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Share.share("My Nyaya Saathi Legal Aid Tracking ID is $applicationNumber");
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: const FittedBox(fit: BoxFit.scaleDown, child: Text("Share ID")),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const CitizenDashboardShell()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.dashboard, size: 18),
                        label: const FittedBox(fit: BoxFit.scaleDown, child: Text("Dashboard")),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
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

