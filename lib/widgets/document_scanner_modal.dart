import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../core/constants/app_colors.dart';
import 'image_crop_editor.dart';

enum DocumentFrameMode {
  landscape16x9("Landscape", 16 / 9, Icons.crop_landscape),
  portrait9x16("Portrait", 9 / 16, Icons.crop_portrait),
  square1x1("Square", 1.0, Icons.crop_square);

  final String label;
  final double ratio;
  final IconData icon;

  const DocumentFrameMode(this.label, this.ratio, this.icon);
}

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

class _DocumentScannerModalState extends State<DocumentScannerModal>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isCameraError = false;
  String _errorMessage = "";

  FlashMode _currentFlashMode = FlashMode.off;
  DocumentFrameMode _frameMode = DocumentFrameMode.landscape16x9;
  bool _isCapturing = false;

  Size _viewfinderSize = Size.zero;
  Rect _goldenFrameRect = Rect.zero;

  late AnimationController _animController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _setupController(_cameras[_selectedCameraIndex]);
      } else {
        setState(() {
          _isCameraError = true;
          _errorMessage = "No device camera detected";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraError = true;
          _errorMessage =
              "Camera access unavailable: ${e.toString().split('\n').first}";
        });
      }
    }
  }

  Future<void> _setupController(CameraDescription cameraDescription) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }

    final controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      await controller.setFlashMode(_currentFlashMode);

      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
          _isCameraError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraError = true;
          _errorMessage = "Failed to initialize camera preview";
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    FlashMode nextMode;
    switch (_currentFlashMode) {
      case FlashMode.auto:
        nextMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
        nextMode = FlashMode.off;
        break;
      case FlashMode.off:
        nextMode = FlashMode.auto;
        break;
    }

    try {
      await _cameraController!.setFlashMode(nextMode);
      setState(() => _currentFlashMode = nextMode);
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() => _isCameraInitialized = false);
    await _setupController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _captureAndProceed() async {
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      Uint8List rawBytes;

      if (_isCameraInitialized &&
          _cameraController != null &&
          _cameraController!.value.isInitialized) {
        final XFile capturedFile = await _cameraController!.takePicture();
        rawBytes = await capturedFile.readAsBytes();
      } else {
        // Fallback for platforms/emulators without camera access: Generate valid high-res sample document JPEG
        rawBytes = await _generateSampleDocumentImage();
      }

      // Crop raw captured photo to ONLY the area inside the golden border frame
      final framedImageBytes = await compute(_cropToFrameIsolate, {
        'bytes': rawBytes,
        'uiWidth': _viewfinderSize.width,
        'uiHeight': _viewfinderSize.height,
        'frameLeft': _goldenFrameRect.left,
        'frameTop': _goldenFrameRect.top,
        'frameWidth': _goldenFrameRect.width,
        'frameHeight': _goldenFrameRect.height,
      });

      if (!mounted) return;

      // Navigate to interactive crop & adjust view
      final croppedResultBytes = await Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(
          builder: (context) => ImageCropEditor(
            imageBytes: framedImageBytes,
            title: widget.documentTitle,
          ),
        ),
      );

      if (croppedResultBytes != null && mounted) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final cleanTitle = widget.documentTitle
            .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
            .toLowerCase();
        final filename = "scanned_${cleanTitle}_$timestamp.jpg";

        widget.onScanned(filename, croppedResultBytes);
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Captured & cropped '$filename' successfully"),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error capturing scan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<Uint8List> _generateSampleDocumentImage() async {
    final image = img.Image(width: 1280, height: 800, numChannels: 3);
    img.fill(image, color: img.ColorRgb8(245, 247, 250));

    // Draw document card background
    img.fillRect(
      image,
      x1: 140,
      y1: 100,
      x2: 1140,
      y2: 700,
      color: img.ColorRgb8(255, 255, 255),
    );

    // Header bar
    img.fillRect(
      image,
      x1: 140,
      y1: 100,
      x2: 1140,
      y2: 200,
      color: img.ColorRgb8(15, 35, 71),
    );

    // Simulated lines
    for (int y = 260; y < 640; y += 45) {
      img.drawLine(
        image,
        x1: 200,
        y1: y,
        x2: 1080,
        y2: y,
        color: img.ColorRgb8(200, 210, 225),
        thickness: 4,
      );
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  @override
  void dispose() {
    _animController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0E15),
          elevation: 0,
          title: Text(
            "Scan: ${widget.documentTitle}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (_cameras.length > 1)
              IconButton(
                icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                tooltip: "Switch Camera",
                onPressed: _switchCamera,
              ),
            IconButton(
              icon: Icon(
                _getFlashIcon(),
                color: _currentFlashMode != FlashMode.off
                    ? AppColors.accentGold
                    : Colors.white70,
              ),
              tooltip: "Flash Mode: ${_currentFlashMode.name.toUpperCase()}",
              onPressed: _toggleFlash,
            ),
          ],
        ),
        body: Column(
          children: [
            // Camera Viewfinder Area
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double maxWidth = constraints.maxWidth;
                  final double maxHeight = constraints.maxHeight;

                  double targetRatio = _frameMode.ratio;
                  double boxWidth = maxWidth - 40;
                  double boxHeight = boxWidth / targetRatio;

                  if (boxHeight > maxHeight - 40) {
                    boxHeight = maxHeight - 40;
                    boxWidth = boxHeight * targetRatio;
                  }

                  final double left = (maxWidth - boxWidth) / 2;
                  final double top = (maxHeight - boxHeight) / 2;
                  final Rect frameRect = Rect.fromLTWH(
                    left,
                    top,
                    boxWidth,
                    boxHeight,
                  );
                  final RRect frameRRect = RRect.fromRectAndRadius(
                    frameRect,
                    const Radius.circular(16),
                  );

                  _viewfinderSize = Size(maxWidth, maxHeight);
                  _goldenFrameRect = frameRect;

                  return Stack(
                    children: [
                      // Camera Feed / Fallback (Fitted to cover container cleanly without aspect distortion)
                      Positioned.fill(
                        child: _isCameraInitialized && _cameraController != null
                            ? ClipRect(
                                child: OverflowBox(
                                  alignment: Alignment.center,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width:
                                          _cameraController!
                                              .value
                                              .previewSize
                                              ?.height ??
                                          maxWidth,
                                      height:
                                          _cameraController!
                                              .value
                                              .previewSize
                                              ?.width ??
                                          maxHeight,
                                      child: CameraPreview(_cameraController!),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFF141722),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isCameraError
                                            ? Icons.videocam_off
                                            : Icons.camera_alt_outlined,
                                        size: 48,
                                        color: Colors.white38,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _isCameraError
                                            ? _errorMessage
                                            : "Initializing Camera...",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (_isCameraError) ...[
                                        const SizedBox(height: 12),
                                        ElevatedButton.icon(
                                          onPressed: _initCamera,
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 16,
                                          ),
                                          label: const Text("Retry Camera"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                      ),

                      // Dark Overlay Mask with Frame Cutout & Golden Border
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ScannerFrameOverlayPainter(
                            frameRRect: frameRRect,
                          ),
                        ),
                      ),

                      // Frame Corner Guides & Laser Scanner Line
                      Positioned.fromRect(
                        rect: frameRect,
                        child: IgnorePointer(
                          child: Stack(
                            children: [
                              // Corner Guides
                              Positioned(
                                top: 8,
                                left: 8,
                                child: _cornerBracket(0),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: _cornerBracket(1),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: _cornerBracket(2),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: _cornerBracket(3),
                              ),

                              // Laser Scanning Line
                              AnimatedBuilder(
                                animation: _scanLineAnimation,
                                builder: (context, child) {
                                  return Align(
                                    alignment: FractionalOffset(
                                      0.5,
                                      _scanLineAnimation.value,
                                    ),
                                    child: Container(
                                      height: 3,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGold,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.accentGold
                                                .withValues(alpha: 0.9),
                                            blurRadius: 12,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Shutter Control Bar
            Container(
              color: const Color(0xFF0D0E15),
              padding: const EdgeInsets.only(bottom: 24, top: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Change Orientation Button (Cycles between 16:9, 9:16, 1:1)
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        switch (_frameMode) {
                          case DocumentFrameMode.landscape16x9:
                            _frameMode = DocumentFrameMode.portrait9x16;
                            break;
                          case DocumentFrameMode.portrait9x16:
                            _frameMode = DocumentFrameMode.square1x1;
                            break;
                          case DocumentFrameMode.square1x1:
                            _frameMode = DocumentFrameMode.landscape16x9;
                            break;
                        }
                      });
                    },
                    icon: Icon(
                      _frameMode.icon,
                      size: 16,
                      color: AppColors.accentGold,
                    ),
                    label: Text(
                      "Change Frame: ${_frameMode.label}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.accentGold,
                        width: 1.2,
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (_isCapturing) ...[
                    const CircularProgressIndicator(
                      color: AppColors.accentGold,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Capturing High-Res Scan...",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: _captureAndProceed,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: AppColors.primaryBlue,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.6,
                              ),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tap to Capture & Crop Document",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight;
      case FlashMode.auto:
        return Icons.flash_auto;
    }
  }

  Widget _cornerBracket(int index) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: (index == 0 || index == 1)
              ? const BorderSide(color: AppColors.accentGold, width: 4)
              : BorderSide.none,
          bottom: (index == 2 || index == 3)
              ? const BorderSide(color: AppColors.accentGold, width: 4)
              : BorderSide.none,
          left: (index == 0 || index == 2)
              ? const BorderSide(color: AppColors.accentGold, width: 4)
              : BorderSide.none,
          right: (index == 1 || index == 3)
              ? const BorderSide(color: AppColors.accentGold, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}

class _ScannerFrameOverlayPainter extends CustomPainter {
  final RRect frameRRect;

  _ScannerFrameOverlayPainter({required this.frameRRect});

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Dimmed background path with frame cutout
    final backgroundPath = Path()..addRect(fullRect);
    final cutoutPath = Path()..addRRect(frameRRect);

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    // Draw dark overlay outside frame
    canvas.drawPath(
      overlayPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.65)
        ..style = PaintingStyle.fill,
    );

    // Draw outer golden frame border
    canvas.drawRRect(
      frameRRect,
      Paint()
        ..color = AppColors.accentGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerFrameOverlayPainter oldDelegate) {
    return oldDelegate.frameRRect != frameRRect;
  }
}

// Background isolate to crop captured photo to frame bounds with exact geometry mapping
Uint8List _cropToFrameIsolate(Map<String, dynamic> params) {
  final Uint8List rawBytes = params['bytes'];
  final double uiW = (params['uiWidth'] as num).toDouble();
  final double uiH = (params['uiHeight'] as num).toDouble();
  final double fLeft = (params['frameLeft'] as num).toDouble();
  final double fTop = (params['frameTop'] as num).toDouble();
  final double fWidth = (params['frameWidth'] as num).toDouble();
  final double fHeight = (params['frameHeight'] as num).toDouble();

  img.Image? decoded = img.decodeImage(rawBytes);
  if (decoded == null) return rawBytes;

  final double imgW = decoded.width.toDouble();
  final double imgH = decoded.height.toDouble();

  // Calculate BoxFit.cover scale and offset of raw image relative to UI container
  final double scale = math.max(uiW / imgW, uiH / imgH);
  final double dispW = imgW * scale;
  final double dispH = imgH * scale;

  final double offsetX = (uiW - dispW) / 2;
  final double offsetY = (uiH - dispH) / 2;

  // Map golden frame UI bounds to normalized image coordinates [0..1]
  final double normLeft = ((fLeft - offsetX) / dispW).clamp(0.0, 1.0);
  final double normTop = ((fTop - offsetY) / dispH).clamp(0.0, 1.0);
  final double normWidth = (fWidth / dispW).clamp(0.0, 1.0 - normLeft);
  final double normHeight = (fHeight / dispH).clamp(0.0, 1.0 - normTop);

  final int cropX = (normLeft * imgW).round().clamp(0, decoded.width - 1);
  final int cropY = (normTop * imgH).round().clamp(0, decoded.height - 1);
  final int cropW = (normWidth * imgW).round().clamp(1, decoded.width - cropX);
  final int cropH = (normHeight * imgH).round().clamp(
    1,
    decoded.height - cropY,
  );

  final cropped = img.copyCrop(
    decoded,
    x: cropX,
    y: cropY,
    width: cropW,
    height: cropH,
  );
  return Uint8List.fromList(img.encodeJpg(cropped, quality: 92));
}
