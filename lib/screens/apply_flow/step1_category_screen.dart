import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../models/legal_aid_category.dart';
import '../../providers/draft_provider.dart';

class Step1CategoryScreen extends StatefulWidget {
  final VoidCallback onNext;

  const Step1CategoryScreen({super.key, required this.onNext});

  @override
  State<Step1CategoryScreen> createState() => _Step1CategoryScreenState();
}

class _Step1CategoryScreenState extends State<Step1CategoryScreen> {
  late Future<List<LegalAidCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = SupabaseService().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final selectedCatId = draftProvider.draft?.categoryId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<LegalAidCategory>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];

        final mq = MediaQuery.of(context);
        final bottomInset = mq.viewInsets.bottom > 0 ? mq.viewInsets.bottom : mq.padding.bottom;

        return ListView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
          children: [

            const FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "Step 1: Choose Eligibility Category",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Select the category under which you or the applicant qualify for free legal services.",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 20),

            ...list.map((cat) {
              final isSelected = selectedCatId == cat.categoryId;
              final catIcon = SupabaseService.getIconData(cat.iconName);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.primaryBlue.withValues(alpha: 0.2) : const Color(0xFFEFF6FF))
                      : (isDark ? AppColors.darkSurface : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    draftProvider.updateCategory(cat.categoryId, cat.categoryCode, cat.categoryName);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            catIcon,
                            color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.categoryName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isSelected ? AppColors.primaryBlue : null,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                cat.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: selectedCatId == null ? null : widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Next: Applicant Details →",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
