import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../models/legal_aid_application.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/status_badge.dart';
import '../citizen/unauth_home_screen.dart';
import 'advocate_case_detail_screen.dart';

class AdvocateDashboardScreen extends StatefulWidget {
  const AdvocateDashboardScreen({super.key});

  @override
  State<AdvocateDashboardScreen> createState() => _AdvocateDashboardScreenState();
}

class _AdvocateDashboardScreenState extends State<AdvocateDashboardScreen> {
  late Future<List<LegalAidApplication>> _casesFuture;

  @override
  void initState() {
    super.initState();
    _casesFuture = SupabaseService().getAdvocateAssignedCases();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shield, color: AppColors.accentGold, size: 22),
            const SizedBox(width: 8),
            Text(authProvider.userName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const UnauthHomeScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: FutureBuilder<List<LegalAidApplication>>(
        future: _casesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cases = snapshot.data ?? [];
          if (cases.isEmpty) {
            return const Center(
              child: Text("No currently assigned cases.", style: TextStyle(color: AppColors.textSecondaryLight)),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gavel, color: AppColors.accentGold, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ADVOCATE PORTAL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGold)),
                        const SizedBox(height: 2),
                        Text("${cases.length} Active Assigned Cases (is_current = true)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              ...cases.map((c) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdvocateCaseDetailScreen(application: c)),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(c.applicationNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              StatusBadge(status: c.currentStatus),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("${c.categoryName} • ${c.caseTypeName}", style: const TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text("Client: ${c.applicantDetails?.fullName ?? 'N/A'} (${c.applicantDetails?.phoneNumber ?? ''})", style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text("View Case Details", style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 13)),
                              SizedBox(width: 4),
                              Icon(Icons.chevron_right, size: 16, color: AppColors.accentGold),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
