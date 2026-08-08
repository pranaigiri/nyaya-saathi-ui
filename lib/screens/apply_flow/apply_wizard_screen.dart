import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/draft_provider.dart';
import 'step1_category_screen.dart';
import 'step2_applicant_details_screen.dart';
import 'step3_casetype_screen.dart';
import 'step4_document_upload_screen.dart';
import 'step5_review_submit_screen.dart';

class ApplyWizardScreen extends StatefulWidget {
  const ApplyWizardScreen({super.key});

  @override
  State<ApplyWizardScreen> createState() => _ApplyWizardScreenState();
}

class _ApplyWizardScreenState extends State<ApplyWizardScreen> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    final draft = Provider.of<DraftProvider>(context, listen: false).draft;
    if (draft != null) {
      _currentStep = draft.stepIndex;
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      Provider.of<DraftProvider>(context, listen: false).setStepIndex(_currentStep);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      Provider.of<DraftProvider>(context, listen: false).setStepIndex(_currentStep);
    }
  }

  static const List<String> _stepTitles = [
    "Eligibility Criteria",
    "Applicant Details",
    "Case & Grievance",
    "Document Upload",
    "Review & Submit",
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _stepTitles[_currentStep],
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              "Step ${_currentStep + 1} of 5",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _prevStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Step progress bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: AppColors.borderLight,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
            minHeight: 6,
          ),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                Step1CategoryScreen(onNext: _nextStep),
                Step2ApplicantDetailsScreen(onNext: _nextStep, onBack: _prevStep),
                Step3CaseTypeScreen(onNext: _nextStep, onBack: _prevStep),
                Step4DocumentUploadScreen(onNext: _nextStep, onBack: _prevStep),
                Step5ReviewSubmitScreen(onBack: _prevStep),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
