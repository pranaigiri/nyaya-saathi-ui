import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/apply_data_provider.dart';
import '../../models/case_type_master.dart';
import '../../providers/draft_provider.dart';

class Step3CaseTypeScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3CaseTypeScreen({super.key, required this.onNext, required this.onBack});

  @override
  State<Step3CaseTypeScreen> createState() => _Step3CaseTypeScreenState();
}

class _Step3CaseTypeScreenState extends State<Step3CaseTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<CaseTypeMaster>> _caseTypesFuture;
  final _grievanceController = TextEditingController();
  final _reliefController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _caseTypesFuture = Provider.of<ApplyDataProvider>(context, listen: false).getCaseTypes();
    final draft = Provider.of<DraftProvider>(context, listen: false);
    _grievanceController.text = draft.draft?.summaryOfGrievance ?? '';
    _reliefController.text = draft.draft?.reliefSought ?? '';
  }

  void _saveAndNext() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<DraftProvider>(context, listen: false).updateGrievanceDetails(
      _grievanceController.text,
      _reliefController.text,
    );

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
        final filteredList = rawList.where((ct) {
          if (_searchQuery.trim().isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return ct.caseTypeName.toLowerCase().contains(q) ||
              ct.categoryGroup.toLowerCase().contains(q) ||
              ct.caseTypeCode.toLowerCase().contains(q);
        }).toList();

        final mq = MediaQuery.of(context);
        final bottomInset = mq.viewInsets.bottom > 0 ? mq.viewInsets.bottom : mq.padding.bottom;

        return Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text("Step 3: Case Type & Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              const Text("Select the primary nature of your legal dispute and summarize your grievance.", style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
              const SizedBox(height: 16),

              // Search Bar for Case Types
              TextFormField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  labelText: "Search Case Type...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              const Text("Select Case Type *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),

              if (filteredList.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "No case types matching '$_searchQuery'",
                      style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ),
                ),
              ] else ...[
                 ...filteredList.map((ct) {
                   final isSelected = selectedCaseTypeId == ct.caseTypeId;
                   final iconData = Provider.of<ApplyDataProvider>(context, listen: false).resolveIcon(ct.iconName);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.primaryBlue.withValues(alpha: 0.2) : const Color(0xFFEFF6FF))
                          : (isDark ? AppColors.darkSurface : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBlue : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        draftProvider.updateCaseType(ct.caseTypeId, ct.caseTypeCode, ct.caseTypeName);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                iconData,
                                color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ct.caseTypeName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isSelected ? AppColors.primaryBlue : null,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ct.categoryGroup,
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
              ],

              const SizedBox(height: 16),
              TextFormField(
                controller: _grievanceController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Summary of Grievance / Case Details *",
                  hintText: "Explain facts of the case, dates, opposing parties, and key issues...",
                ),
                validator: (v) => v == null || v.trim().length < 15 ? "Please provide a detailed summary (min 15 chars)" : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _reliefController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Relief Sought (Optional)",
                  hintText: "e.g. Free advocate for bail application / property court suit...",
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedCaseTypeId == null ? null : _saveAndNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("Next: Upload Docs →", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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
