import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/apply_data_provider.dart';
import '../../providers/draft_provider.dart';
import '../../widgets/document_picker_tile.dart';

class Step4DocumentUploadScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step4DocumentUploadScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final applyDataProvider = Provider.of<ApplyDataProvider>(context);
    final draft = draftProvider.draft;
    final docs = draftProvider.requiredDocuments;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final caseTypeName = draft?.caseTypeName;
    final categoryName = draft?.categoryName ?? '';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Step 4: Document Upload & Scanning",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (caseTypeName != null && caseTypeName.isNotEmpty)
                    ? "Documents required for category '$categoryName' and case type '$caseTypeName'. Upload or scan each document."
                    : "Documents required for category '$categoryName'. Upload or scan each document, or skip to provide them later.",
                style: const TextStyle(
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
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: "You may skip document uploads for now. ",
                            ),
                            TextSpan(
                              text:
                                  "An officer will collect and verify the documents via a confirmation call",
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

              if (applyDataProvider.isLoadingDocuments)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (docs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.successGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "No specific documents are required upfront for your selected category. You can proceed directly or skip.",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...docs.map((d) {
                  final existingPath =
                      draft?.documentStoragePaths[d.documentCode];

                  // Which selection asked for this document (badge labels)
                  final badgeLabels = <String>[];
                  if (d.sources.contains('category') &&
                      categoryName.isNotEmpty) {
                    badgeLabels.add(categoryName);
                  }
                  if (d.sources.contains('case_type') &&
                      (caseTypeName ?? '').isNotEmpty) {
                    badgeLabels.add(caseTypeName!);
                  }

                  return DocumentPickerTile(
                    doc: d,
                    uploadedPath: existingPath,
                    requiredByLabels: badgeLabels,
                    onFilePicked: (docCode, fileName, bytes) async {
                      await draftProvider.attachDocument(
                        docCode,
                        fileName,
                        bytes,
                      );
                    },
                    onFileRemoved: (docCode) async {
                      await draftProvider.removeDocument(docCode);
                    },
                  );
                }),
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
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
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
                      onPressed: onNext,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white
                            : AppColors.primaryBlue,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.primaryBlue.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          context.tr("skip", fallback: "Skip"),
                          style: const TextStyle(
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
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          context.tr('next_review_submit', fallback: "Next: Review & Submit →"),
                          style: const TextStyle(
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
    );
  }
}
