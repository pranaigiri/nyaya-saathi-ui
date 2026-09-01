import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/apply_data_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/draft_provider.dart';
import '../models/legal_aid_category.dart';
import '../screens/apply_flow/apply_wizard_screen.dart';
import 'apply_choice_modal.dart';

class _EligibilityQuestion {
  final String question;
  final String hint;
  final String categoryCode;
  final String categoryLabel;
  const _EligibilityQuestion({
    required this.question,
    required this.hint,
    required this.categoryCode,
    required this.categoryLabel,
  });
}

/// One-tap eligibility check: a quick yes/no questionnaire that determines
/// whether the person qualifies for free legal aid under the Legal Services
/// Authorities Act, 1987, and maps the result to the matching category.
class EligibilityCheckModal extends StatefulWidget {
  const EligibilityCheckModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const EligibilityCheckModal(),
    );
  }

  @override
  State<EligibilityCheckModal> createState() => _EligibilityCheckModalState();
}

class _EligibilityCheckModalState extends State<EligibilityCheckModal> {
  static const List<_EligibilityQuestion> _questions = [
    _EligibilityQuestion(
      question: 'Are you a woman?',
      hint: 'All women are eligible regardless of income under Sec 12(c)',
      categoryCode: 'WOMAN',
      categoryLabel: 'Woman',
    ),
    _EligibilityQuestion(
      question: 'Is the applicant a child (below 18 years)?',
      hint: 'All children are eligible under Sec 12(c)',
      categoryCode: 'CHILDREN',
      categoryLabel: 'Children',
    ),
    _EligibilityQuestion(
      question: 'Do you belong to a Scheduled Caste or Scheduled Tribe?',
      hint: 'SC/ST members under Sec 12(a)',
      categoryCode: 'SC_ST',
      categoryLabel: 'Scheduled Caste or Scheduled Tribe',
    ),
    _EligibilityQuestion(
      question: 'Is your annual household income below ₹3,00,000?',
      hint: 'As per Sec 12(h) of the Legal Services Authorities Act, 1987',
      categoryCode: 'GENERAL',
      categoryLabel: 'General – Annual income below ₹3 Lakh',
    ),
    _EligibilityQuestion(
      question: 'Do you have a mental illness or a physical disability?',
      hint: 'Under Sec 12(d)',
      categoryCode: 'DISABLED_PERSON',
      categoryLabel: 'Mentally Ill or Disabled Person',
    ),
    _EligibilityQuestion(
      question:
          'Are you a victim of a mass disaster, ethnic violence, caste atrocity, flood or earthquake?',
      hint: 'Under Sec 12(e)',
      categoryCode: 'DISASTER_VICTIM',
      categoryLabel: 'Victim of Disaster or Atrocity',
    ),
    _EligibilityQuestion(
      question: 'Are you a victim of human trafficking?',
      hint: 'Victims of trafficking or forced labor under Article 23',
      categoryCode: 'TRAFFICKING_VICTIM',
      categoryLabel: 'Victim of Trafficking',
    ),
    _EligibilityQuestion(
      question: 'Are you a victim of forced beggary?',
      hint: 'Victims of forced begging under Article 23',
      categoryCode: 'BEGGARY_VICTIM',
      categoryLabel: 'Victim of Beggary',
    ),
    _EligibilityQuestion(
      question: 'Are you an industrial workman?',
      hint: 'Industrial workers under Sec 12(f)',
      categoryCode: 'INDUSTRIAL_WORKMAN',
      categoryLabel: 'Industrial Workman',
    ),
  ];

  int _currentIndex = 0;
  bool? _isEligible;
  _EligibilityQuestion? _matchedQuestion;
  List<LegalAidCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await Provider.of<ApplyDataProvider>(
        context,
        listen: false,
      ).getLegalAidCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  LegalAidCategory? _resolveCategory(_EligibilityQuestion q) {
    try {
      return _categories.firstWhere((c) => c.categoryCode == q.categoryCode);
    } catch (_) {
      return null;
    }
  }

  void _answer(bool yes) {
    final q = _questions[_currentIndex];
    if (yes) {
      setState(() {
        _isEligible = true;
        _matchedQuestion = q;
      });
      return;
    }
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _isEligible = false);
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _isEligible = null;
      _matchedQuestion = null;
    });
  }

  void _proceedToApply() {
    final q = _matchedQuestion;
    if (q == null) return;
    final cat = _resolveCategory(q);
    // Capture the NavigatorState before popping: after the pop this sheet's
    // context becomes deactivated and can no longer be used to open the next
    // modal (otherwise the "Apply for Legal Aid" sheet would silently fail).
    final navigator = Navigator.of(context);

    // Logged-out users never see the Self/Others chooser — the "Self" option
    // auto-fills from a profile they don't have. Instead, go straight to
    // Step 2 (Applicant Details) with a blank form and the eligibility
    // result preselected as the Step 1 category.
    final isAuthenticated = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isAuthenticated;
    if (!isAuthenticated) {
      _startGuestApplication(
        navigator,
        categoryId: cat?.id,
        categoryCode: cat?.categoryCode ?? q.categoryCode,
        categoryName: cat?.categoryName ?? q.categoryLabel,
      );
      return;
    }

    ApplyChoiceModal.show(
      navigator.context,
      preselectedCategoryId: cat?.id,
      preselectedCategoryCode: cat?.categoryCode ?? q.categoryCode,
      preselectedCategoryName: cat?.categoryName ?? q.categoryLabel,
      initialStep: 1, // Skip Step 1 — category is preselected from the check
    );
  }

  /// Guest flow: closes this sheet, prepares a blank draft with the
  /// eligibility-derived category preselected, and opens the wizard
  /// directly on Step 2 (Applicant Details).
  Future<void> _startGuestApplication(
    NavigatorState navigator, {
    dynamic categoryId,
    String? categoryCode,
    String? categoryName,
  }) async {
    final draftProvider = Provider.of<DraftProvider>(context, listen: false);
    try {
      // Blank form — no profile is available for guests.
      await draftProvider.startNewDraft();

      // Automatically "select" the eligibility result in Step 1 and persist
      // the wizard's starting step so it opens on Step 2.
      if (categoryId != null && categoryCode != null) {
        await draftProvider.updateCategory(
          categoryId,
          categoryCode,
          categoryName ?? categoryCode,
        );
      }
      await draftProvider.setStepIndex(1);
    } catch (_) {
      // Draft preparation failed — still open the wizard at Step 2; the
      // user can pick the category manually there.
    }

    if (!mounted) return;
    navigator.pop(); // Close the eligibility sheet after async work
    navigator.push(
      MaterialPageRoute(
        builder: (_) => const ApplyWizardScreen(initialStep: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  color: Color(0xFF0D9488),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One Tap Eligibility Check',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Answer a few quick questions to check if you qualify for free legal aid',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          Flexible(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isEligible == null
                    ? _buildQuestionFlow(isDark, textPrimary, textSecondary)
                    : _isEligible!
                    ? _buildEligibleResult(isDark, textPrimary, textSecondary)
                    : _buildNotEligibleResult(
                        isDark,
                        textPrimary,
                        textSecondary,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ---------- Question flow ----------

  Widget _buildQuestionFlow(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final q = _questions[_currentIndex];
    return Column(
      key: ValueKey('q_$_currentIndex'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex) / _questions.length,
                  minHeight: 5,
                  backgroundColor: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0D9488),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_currentIndex + 1} / ${_questions.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text(
          q.question,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(q.hint, style: TextStyle(fontSize: 12, color: textSecondary)),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: _buildAnswerButton(
                label: 'Yes',
                icon: Icons.check_rounded,
                color: const Color(0xFF0D9488),
                isDark: isDark,
                onPressed: () => _answer(true),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildAnswerButton(
                label: 'No',
                icon: Icons.close_rounded,
                color: AppColors.primaryBlue,
                isDark: isDark,
                onPressed: () => _answer(false),
              ),
            ),
          ],
        ),

        if (_currentIndex > 0) ...[
          const SizedBox(height: 14),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _currentIndex--),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Previous Question'),
              style: TextButton.styleFrom(
                foregroundColor: textSecondary,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnswerButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
  // ---------- Eligible result ----------

  Widget _buildEligibleResult(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final q = _matchedQuestion!;
    final cat = _resolveCategory(q);
    return Column(
      key: const ValueKey('eligible'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(
              alpha: isDark ? 0.15 : 0.1,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.successGreen.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: AppColors.successGreen,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'You are Eligible!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Based on your answers, you qualify for free legal aid under the category:',
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cat?.categoryName ?? q.categoryLabel,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _proceedToApply,
            icon: const Icon(Icons.post_add_rounded, size: 20),
            label: const Text(
              'Apply for Legal Aid',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: _restart,
            child: const Text(
              'Start Check Again',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
  // ---------- Not eligible result ----------

  Widget _buildNotEligibleResult(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      key: const ValueKey('not_eligible'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(
              0xFFF97316,
            ).withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF97316).withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFF97316),
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You may not be eligible',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'You did not select any of the qualifying criteria under the Legal Services Authorities Act, 1987. You may still contact Sikkim SLSA for guidance — a legal aid authority can review special circumstances.',
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _restart,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text(
              'Start Check Again',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
