import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants/app_colors.dart';
import '../models/document_master.dart';
import 'document_scanner_modal.dart';

class DocumentPickerTile extends StatefulWidget {
  final DocumentMaster doc;
  final String? uploadedPath;
  final Function(String docCode, String fileName, List<int> bytes) onFilePicked;
  final Function(String docCode)? onFileRemoved;

  const DocumentPickerTile({
    super.key,
    required this.doc,
    this.uploadedPath,
    required this.onFilePicked,
    this.onFileRemoved,
  });

  @override
  State<DocumentPickerTile> createState() => _DocumentPickerTileState();
}

class _DocumentPickerTileState extends State<DocumentPickerTile> {
  bool _isUploading = false;
  String? _activeUploadingCode;

  // Local cache for in-memory bytes and file names for instant preview
  final Map<String, List<int>> _localByteCache = {};
  final Map<String, String> _localFileNameCache = {};

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
          _localByteCache[docCode] = file.bytes!;
          _localFileNameCache[docCode] = file.name;
        });
        await widget.onFilePicked(docCode, file.name, file.bytes!);
        setState(() {
          _isUploading = false;
          _activeUploadingCode = null;
        });
      }
    }
  }

  void _openScanner(String docCode) {
    showDialog(
      context: context,
      builder: (context) => DocumentScannerModal(
        documentTitle: widget.doc.documentName,
        onScanned: (fileName, bytes) async {
          setState(() {
            _isUploading = true;
            _activeUploadingCode = docCode;
            _localByteCache[docCode] = bytes;
            _localFileNameCache[docCode] = fileName;
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

  void _removeFile(String docCode, String titleLabel) {
    setState(() {
      _localByteCache.remove(docCode);
      _localFileNameCache.remove(docCode);
    });
    widget.onFileRemoved?.call(docCode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Removed '$titleLabel'"),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewFile(String docCode, String titleLabel, String? storagePath) {
    final bytes = _localByteCache[docCode];
    final fileName = _localFileNameCache[docCode] ?? storagePath ?? "Document";

    showDialog(
      context: context,
      builder: (context) => _DocumentPreviewDialog(
        title: titleLabel,
        fileName: fileName,
        imageBytes: bytes != null ? Uint8List.fromList(bytes) : null,
        storagePath: storagePath,
        onRemove: () {
          Navigator.of(context).pop();
          _removeFile(docCode, titleLabel);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUploaded = widget.uploadedPath != null && widget.uploadedPath!.isNotEmpty;
    final cachedName = _localFileNameCache[widget.doc.documentCode];

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
                    if (widget.doc.description != null && widget.doc.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.doc.description!,
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
                    color: (isUploaded ? AppColors.successGreen : AppColors.dangerRed).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isUploaded ? "Uploaded ✓" : "Required",
                    style: TextStyle(
                      color: isUploaded ? AppColors.successGreen : AppColors.dangerRed,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Attached file name indicator when uploaded
          if (isUploaded && cachedName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, size: 14, color: AppColors.successGreen),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      cachedName,
                      style: const TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isUploaded ? "File Attached" : "Status: Pending",
                style: TextStyle(
                  fontSize: 11,
                  color: isUploaded ? AppColors.successGreen : AppColors.textSecondaryLight,
                  fontWeight: isUploaded ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (_isUploading && _activeUploadingCode == widget.doc.documentCode)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else if (isUploaded)
                // Action row for Uploaded State: View, Replace, Remove
                Row(
                  children: [
                    // View Button
                    ElevatedButton.icon(
                      onPressed: () => _viewFile(widget.doc.documentCode, widget.doc.documentName, widget.uploadedPath),
                      icon: const Icon(Icons.visibility_outlined, size: 14, color: Colors.white),
                      label: const Text("View", style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Replace Popup Menu
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'scan') {
                          _openScanner(widget.doc.documentCode);
                        } else if (value == 'upload') {
                          _pickFile(widget.doc.documentCode);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'scan',
                          child: Row(
                            children: [
                              Icon(Icons.camera_alt, size: 16, color: AppColors.primaryBlue),
                              SizedBox(width: 8),
                              Text("Scan Camera", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'upload',
                          child: Row(
                            children: [
                              Icon(Icons.folder_open, size: 16, color: AppColors.primaryBlue),
                              SizedBox(width: 8),
                              Text("Choose File", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 14, color: AppColors.primaryBlue),
                            SizedBox(width: 4),
                            Text("Replace", style: TextStyle(fontSize: 11, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Remove Button
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.dangerRed, size: 20),
                      tooltip: "Remove Document",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _removeFile(widget.doc.documentCode, widget.doc.documentName),
                    ),
                  ],
                )
              else
                // Action row for Pending State: Scan & Upload
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openScanner(widget.doc.documentCode),
                      icon: const Icon(Icons.camera_alt, size: 14),
                      label: const Text("Scan", style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _pickFile(widget.doc.documentCode),
                      icon: const Icon(Icons.folder_open, size: 14, color: Colors.white),
                      label: const Text("Upload", style: TextStyle(fontSize: 12, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
}

class _DocumentPreviewDialog extends StatelessWidget {
  final String title;
  final String fileName;
  final Uint8List? imageBytes;
  final String? storagePath;
  final VoidCallback onRemove;

  const _DocumentPreviewDialog({
    required this.title,
    required this.fileName,
    this.imageBytes,
    this.storagePath,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D0E15),
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Preview Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFF161925),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: AppColors.accentGold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          fileName,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Preview Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: imageBytes != null
                      ? InteractiveViewer(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              imageBytes!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Text(
                                "Unable to render image preview",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_done_outlined, size: 64, color: AppColors.successGreen),
                            const SizedBox(height: 12),
                            Text(
                              "File stored at: $fileName",
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // Preview Footer Actions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF161925),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline, color: AppColors.dangerRed, size: 18),
                      label: const Text("Remove File", style: TextStyle(color: AppColors.dangerRed)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.dangerRed),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check, color: Colors.white, size: 18),
                      label: const Text("Close Preview", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
