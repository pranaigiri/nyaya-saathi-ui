import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants/app_colors.dart';
import '../models/document_master.dart';
import 'document_scanner_modal.dart';

class DocumentPickerTile extends StatefulWidget {
  final DocumentMaster doc;
  final String? uploadedPath;
  final String? frontPath;
  final String? backPath;
  final Function(String docCode, String fileName, List<int> bytes) onFilePicked;

  const DocumentPickerTile({
    super.key,
    required this.doc,
    this.uploadedPath,
    this.frontPath,
    this.backPath,
    required this.onFilePicked,
  });

  @override
  State<DocumentPickerTile> createState() => _DocumentPickerTileState();
}

class _DocumentPickerTileState extends State<DocumentPickerTile> {
  bool _isUploading = false;
  String? _activeUploadingCode;

  Future<void> _pickFile(String docCode) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        setState(() {
          _isUploading = true;
          _activeUploadingCode = docCode;
        });
        await widget.onFilePicked(docCode, file.name, file.bytes!);
        setState(() {
          _isUploading = false;
          _activeUploadingCode = null;
        });
      }
    }
  }

  void _openScanner(String docCode, String sideLabel) {
    showDialog(
      context: context,
      builder: (context) => DocumentScannerModal(
        documentTitle: "${widget.doc.documentName} ($sideLabel)",
        onScanned: (fileName, bytes) async {
          setState(() {
            _isUploading = true;
            _activeUploadingCode = docCode;
          });
          await widget.onFilePicked(docCode, fileName, bytes);
          setState(() {
            _isUploading = false;
            _activeUploadingCode = null;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIdentityProof = widget.doc.documentCode == 'DOC_ID';

    if (isIdentityProof) {
      final isFrontUploaded = widget.frontPath != null && widget.frontPath!.isNotEmpty;
      final isBackUploaded = widget.backPath != null && widget.backPath!.isNotEmpty;
      final isBothUploaded = isFrontUploaded && isBackUploaded;

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isBothUploaded ? AppColors.successGreen : AppColors.accentGold,
            width: 1.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isBothUploaded ? Icons.verified_user : Icons.badge_outlined,
                  color: isBothUploaded ? AppColors.successGreen : AppColors.accentGold,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.doc.documentName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Required Front & Back",
                    style: TextStyle(color: AppColors.dangerRed, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Please upload or scan both Front (Photo) and Back (Address) sides of your ID card.",
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 14),

            // Sub-tile 1: Front Side
            _buildIdentitySideTile(
              context: context,
              sideTitle: "Front Side (Photo & Identity Details)",
              docCode: "DOC_ID_FRONT",
              isUploaded: isFrontUploaded,
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            // Sub-tile 2: Back Side
            _buildIdentitySideTile(
              context: context,
              sideTitle: "Back Side (Address & Authority Seal)",
              docCode: "DOC_ID_BACK",
              isUploaded: isBackUploaded,
              isDark: isDark,
            ),
          ],
        ),
      );
    }

    // Standard Document Tile
    final isUploaded = widget.uploadedPath != null && widget.uploadedPath!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUploaded ? AppColors.successGreen : (widget.doc.isMandatoryDefault ? AppColors.accentGold : AppColors.borderLight),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUploaded ? AppColors.successGreen.withValues(alpha: 0.1) : AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle : Icons.upload_file,
                  color: isUploaded ? AppColors.successGreen : AppColors.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.doc.documentName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    if (widget.doc.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.doc.description,
                        style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.doc.isMandatoryDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Required",
                    style: TextStyle(color: AppColors.dangerRed, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isUploaded ? "Uploaded to Cloud" : "Not uploaded yet",
                style: TextStyle(
                  fontSize: 11,
                  color: isUploaded ? AppColors.successGreen : AppColors.textSecondaryLight,
                  fontWeight: isUploaded ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (_isUploading && _activeUploadingCode == widget.doc.documentCode)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openScanner(widget.doc.documentCode, "Full Document"),
                      icon: const Icon(Icons.camera_alt, size: 14),
                      label: const Text("Scan", style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _pickFile(widget.doc.documentCode),
                      icon: const Icon(Icons.folder_open, size: 14),
                      label: Text(isUploaded ? "Replace" : "Upload", style: const TextStyle(fontSize: 12, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUploaded ? AppColors.successGreen : AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySideTile({
    required BuildContext context,
    required String sideTitle,
    required String docCode,
    required bool isUploaded,
    required bool isDark,
  }) {
    final isThisUploading = _isUploading && _activeUploadingCode == docCode;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? AppColors.successGreen.withValues(alpha: 0.5) : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.crop_original_outlined,
            color: isUploaded ? AppColors.successGreen : AppColors.textSecondaryLight,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sideTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  isUploaded ? "Uploaded" : "Pending",
                  style: TextStyle(fontSize: 10, color: isUploaded ? AppColors.successGreen : AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          if (isThisUploading)
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          else
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _openScanner(docCode, sideTitle),
                  icon: const Icon(Icons.camera_alt, size: 14),
                  label: const Text("Scan", style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: () => _pickFile(docCode),
                  icon: const Icon(Icons.upload_file, size: 14),
                  label: Text(isUploaded ? "Replace" : "File", style: const TextStyle(fontSize: 11, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUploaded ? AppColors.successGreen : AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
