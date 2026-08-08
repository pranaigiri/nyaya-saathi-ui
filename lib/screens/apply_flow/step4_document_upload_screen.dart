import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/draft_provider.dart';
import '../../widgets/document_picker_tile.dart';

class Step4DocumentUploadScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step4DocumentUploadScreen({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final draft = draftProvider.draft;
    final docs = draftProvider.requiredDocuments;

    final hasIdFront = draft?.documentStoragePaths.containsKey('DOC_ID_FRONT') ?? false;
    final hasIdBack = draft?.documentStoragePaths.containsKey('DOC_ID_BACK') ?? false;
    final hasSingleId = draft?.documentStoragePaths.containsKey('DOC_ID') ?? false;
    final isIdentityComplete = (hasIdFront && hasIdBack) || hasSingleId;

    final nonIdMandatoryDocs = docs.where((d) => d.isMandatoryDefault && d.documentCode != 'DOC_ID');
    final nonIdMandatoryUploaded = nonIdMandatoryDocs.where((d) => draft?.documentStoragePaths.containsKey(d.documentCode) ?? false).length;

    final canProceed = isIdentityComplete && (nonIdMandatoryUploaded >= nonIdMandatoryDocs.length);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text("Step 4: Document Upload & Scanning", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(
          "Documents required for category '${draft?.categoryName ?? ''}' and case type '${draft?.caseTypeName ?? ''}'. Use File Upload or Document Scanner.",
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 20),

        if (docs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          ...docs.map((d) {
            final existingPath = draft?.documentStoragePaths[d.documentCode];
            final frontPath = draft?.documentStoragePaths['DOC_ID_FRONT'];
            final backPath = draft?.documentStoragePaths['DOC_ID_BACK'];

            return DocumentPickerTile(
              doc: d,
              uploadedPath: existingPath,
              frontPath: frontPath,
              backPath: backPath,
              onFilePicked: (docCode, fileName, bytes) async {
                await draftProvider.attachDocument(docCode, fileName, bytes);
              },
            );
          }),

        const SizedBox(height: 28),

        SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canProceed ? onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text("Next: Review & Submit →", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
