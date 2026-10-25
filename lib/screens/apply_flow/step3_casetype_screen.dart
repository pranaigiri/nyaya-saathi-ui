import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/apply_data_provider.dart';
import '../../models/case_type_master.dart';
import '../../providers/draft_provider.dart';

class Step3CaseTypeScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3CaseTypeScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step3CaseTypeScreen> createState() => _Step3CaseTypeScreenState();
}

class _Step3CaseTypeScreenState extends State<Step3CaseTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<CaseTypeMaster>> _caseTypesFuture;
  final _grievanceController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final Set<String> _expandedCaseTypeIds = <String>{};

  @override
  void initState() {
    super.initState();
    _caseTypesFuture = Provider.of<ApplyDataProvider>(
      context,
      listen: false,
    ).getCaseTypes();
    final draft = Provider.of<DraftProvider>(context, listen: false);
    _grievanceController.text = draft.draft?.summaryOfGrievance ?? '';
  }

  @override
  void dispose() {
    _grievanceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedCaseTypeIds.contains(id)) {
        _expandedCaseTypeIds.remove(id);
      } else {
        _expandedCaseTypeIds.add(id);
      }
    });
  }

  void _skipStep() {
    // Preserve any optional text the user might have entered
    Provider.of<DraftProvider>(
      context,
      listen: false,
    ).updateGrievanceDetails(_grievanceController.text.trim());
    widget.onNext();
  }

  void _saveAndNext() {
    Provider.of<DraftProvider>(
      context,
      listen: false,
    ).updateGrievanceDetails(_grievanceController.text.trim());
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final selectedCaseTypeId = draftProvider.draft?.caseTypeId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<CaseTypeMaster>>(
      future: _caseTypesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final rawList = snapshot.data ?? [];
        final sortedList = List<CaseTypeMaster>.from(rawList)
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        final filteredList = sortedList.where((ct) {
          if (_searchQuery.trim().isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return ct.caseTypeName.toLowerCase().contains(q) ||
              ct.caseTypeCode.toLowerCase().contains(q) ||
              (ct.caseTypeDescription?.toLowerCase().contains(q) ?? false);
        }).toList();

        return Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  children: [
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Step 3: Case Type & Summary",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Provide grievance details and select your case type, or skip to fill them later.",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Officer Call Confirmation Notice Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFBFDBFE),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.phone_in_talk_outlined,
                            color: isDark
                                ? const Color(0xFF60A5FA)
                                : AppColors.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Note: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: "You may skip these fields for now. ",
                                  ),
                                  TextSpan(
                                    text:
                                        "An officer will collect the details via a confirmation call",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFF93C5FD)
                                          : AppColors.primaryBlue,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        " as they are required to process your legal aid application.",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Summary of Grievance Text Input (kept on top as the only text input)
                    const Text(
                      "Summary of Grievance (Optional)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Explain what happened, dates, opposing parties, or key issues (can be left blank).",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _grievanceController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText:
                            "Summary of Grievance / Case Details (Optional)",
                        hintText:
                            "Explain facts of the case, dates, opposing parties, and key issues...",
                        alignLabelWithHint: true,
                      ),
                      validator: (v) =>
                          null, // Optional - can be submitted blank
                    ),
                    const SizedBox(height: 22),

                    // Case Selection Below Summary of Grievance
                    const Text(
                      "Select Case Type (Optional)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Select the category that best matches your dispute, or leave unselected.",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Search Bar for Case Types
                    TextFormField(
                      key: const Key('case_type_search_field'),
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: "Search Case Type...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (filteredList.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            "No case types matching '$_searchQuery'",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      ...filteredList.map((ct) {
                        final isSelected = selectedCaseTypeId == ct.id;
                        final iconData = Provider.of<ApplyDataProvider>(
                          context,
                          listen: false,
                        ).resolveIcon(ct.iconUrl ?? ct.iconName);
                        final hasDescription =
                            ct.caseTypeDescription != null &&
                            ct.caseTypeDescription!.trim().isNotEmpty;
                        final description =
                            ct.caseTypeDescription?.trim() ?? '';
                        final isExpanded = _expandedCaseTypeIds.contains(ct.id);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                      ? AppColors.primaryBlue.withValues(
                                          alpha: 0.2,
                                        )
                                      : const Color(0xFFEFF6FF))
                                : (isDark
                                      ? AppColors.darkSurface
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : (isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              if (isSelected) {
                                // Allow deselecting to leave blank
                                draftProvider.updateCaseType(null, null, null);
                              } else {
                                draftProvider.updateCaseType(
                                  ct.id,
                                  ct.caseTypeCode,
                                  ct.caseTypeName,
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryBlue
                                              : (isDark
                                                    ? Colors.grey.shade800
                                                    : Colors.grey.shade100),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          iconData,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark
                                                    ? AppColors
                                                          .textSecondaryDark
                                                    : AppColors
                                                          .textSecondaryLight),
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ct.caseTypeName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: isSelected
                                                    ? AppColors.primaryBlue
                                                    : null,
                                              ),
                                            ),
                                            if (hasDescription) ...[
                                              const SizedBox(height: 3),
                                              InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                onTap: () =>
                                                    _toggleExpanded(ct.id),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      isExpanded
                                                          ? "Show less"
                                                          : "Tap to learn more",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? AppColors
                                                                  .primaryBlue
                                                            : (isDark
                                                                  ? const Color(
                                                                      0xFF93C5FD,
                                                                    )
                                                                  : AppColors
                                                                        .primaryBlue),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    AnimatedRotation(
                                                      turns: isExpanded
                                                          ? 0.5
                                                          : 0.0,
                                                      duration: const Duration(
                                                        milliseconds: 260,
                                                      ),
                                                      curve:
                                                          Curves.easeInOutCubic,
                                                      child: Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        size: 15,
                                                        color: isSelected
                                                            ? AppColors
                                                                  .primaryBlue
                                                            : (isDark
                                                                  ? const Color(
                                                                      0xFF93C5FD,
                                                                    )
                                                                  : AppColors
                                                                        .primaryBlue),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Icon(
                                            Icons.check_circle,
                                            color: AppColors.primaryBlue,
                                            size: 20,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (hasDescription)
                                    ClipRect(
                                      child: AnimatedSize(
                                        duration: const Duration(
                                          milliseconds: 260,
                                        ),
                                        curve: Curves.easeInOutCubic,
                                        alignment: Alignment.topCenter,
                                        child: isExpanded
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: AnimatedOpacity(
                                                  opacity: isExpanded
                                                      ? 1.0
                                                      : 0.0,
                                                  duration: const Duration(
                                                    milliseconds: 220,
                                                  ),
                                                  curve: Curves.easeIn,
                                                  child: Text(
                                                    description,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      height: 1.45,
                                                      color: isDark
                                                          ? AppColors
                                                                .textSecondaryDark
                                                          : AppColors
                                                                .textSecondaryLight,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              // Fixed bottom button bar with Skip & Next buttons
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBg : AppColors.lightBg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.08,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: _skipStep,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.white
                                  : AppColors.primaryBlue,
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.primaryBlue.withValues(
                                        alpha: 0.5,
                                      ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Skip",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _saveAndNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Next: Upload Docs →",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
