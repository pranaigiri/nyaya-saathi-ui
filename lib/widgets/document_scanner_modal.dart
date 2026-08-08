import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class DocumentScannerModal extends StatefulWidget {
  final String documentTitle;
  final Function(String fileName, List<int> bytes) onScanned;

  const DocumentScannerModal({
    super.key,
    required this.documentTitle,
    required this.onScanned,
  });

  @override
  State<DocumentScannerModal> createState() => _DocumentScannerModalState();
}

class _DocumentScannerModalState extends State<DocumentScannerModal> with SingleTickerProviderStateMixin {
  bool _isCapturing = false;
  bool _flashOn = false;
  bool _isLandscape = true; // Default 16:9 ratio (Aadhaar Card)
  late AnimationController _animController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _captureDocument() async {
    setState(() => _isCapturing = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    // Generate simulated high-resolution scanned document JPEG bytes (dummy valid image header/bytes)
    final Random random = Random();
    final List<int> simulatedJpgBytes = List<int>.generate(
      2048,
      (i) => (i % 256 + random.nextInt(50)) % 256,
    );

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = "scanned_${widget.documentTitle.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase()}_$timestamp.jpg";

    if (mounted) {
      widget.onScanned(filename, simulatedJpgBytes);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully scanned and uploaded '$filename'"),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text(
            "Scan: ${widget.documentTitle}",
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(_isLandscape ? Icons.crop_landscape : Icons.crop_portrait, color: AppColors.accentGold),
              tooltip: "Rotate Box Size (16:9 / 9:16)",
              onPressed: () => setState(() => _isLandscape = !_isLandscape),
            ),
            IconButton(
              icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off, color: _flashOn ? Colors.amber : Colors.white),
              onPressed: () => setState(() => _flashOn = !_flashOn),
            ),
          ],
        ),
        body: Column(
          children: [
            // Simulated Camera Viewfinder dynamically sized for 16:9 or 9:16 aspect ratio
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final targetRatio = _isLandscape ? (16 / 9) : (9 / 16);
                    double boxWidth = constraints.maxWidth;
                    double boxHeight = boxWidth / targetRatio;

                    if (boxHeight > constraints.maxHeight) {
                      boxHeight = constraints.maxHeight;
                      boxWidth = boxHeight * targetRatio;
                    }

                    return Center(
                      child: SizedBox(
                        width: boxWidth,
                        height: boxHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.accentGold, width: 2.5),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey.shade900.withValues(alpha: 0.6),
                          ),
                          child: Stack(
                            children: [
                              // Grid Alignment Corners
                              Positioned(top: 10, left: 10, child: _cornerWidget(0)),
                              Positioned(top: 10, right: 10, child: _cornerWidget(1)),
                              Positioned(bottom: 10, left: 10, child: _cornerWidget(2)),
                              Positioned(bottom: 10, right: 10, child: _cornerWidget(3)),

                              // Scanning Laser Animation Line
                              AnimatedBuilder(
                                animation: _scanLineAnimation,
                                builder: (context, child) {
                                  return Align(
                                    alignment: FractionalOffset(0.5, _scanLineAnimation.value),
                                    child: Container(
                                      height: 3,
                                      margin: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGold,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.accentGold.withValues(alpha: 0.8),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Instruction overlay (fitted box prevents text overflow)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.center_focus_strong, color: Colors.white, size: 16),
                                          SizedBox(width: 6),
                                          Text(
                                            "Position document inside frame",
                                            style: TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Shutter Button & Controls at Bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isCapturing) ...[
                    const CircularProgressIndicator(color: AppColors.accentGold),
                    const SizedBox(height: 12),
                    const Text("Processing High-Res Scan...", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ] else ...[
                    GestureDetector(
                      onTap: _captureDocument,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: AppColors.primaryBlue,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Tap to Capture Scan", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerWidget(int index) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: (index == 0 || index == 1) ? const BorderSide(color: AppColors.accentGold, width: 4) : BorderSide.none,
          bottom: (index == 2 || index == 3) ? const BorderSide(color: AppColors.accentGold, width: 4) : BorderSide.none,
          left: (index == 0 || index == 2) ? const BorderSide(color: AppColors.accentGold, width: 4) : BorderSide.none,
          right: (index == 1 || index == 3) ? const BorderSide(color: AppColors.accentGold, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}
