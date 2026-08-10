import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../core/constants/app_colors.dart';

enum CropAspectRatio {
  free,
  ratio16x9,
  ratio3x4,
  ratio1x1,
  original,
}

class ImageCropEditor extends StatefulWidget {
  final Uint8List imageBytes;
  final String title;

  const ImageCropEditor({
    super.key,
    required this.imageBytes,
    required this.title,
  });

  @override
  State<ImageCropEditor> createState() => _ImageCropEditorState();
}

class _ImageCropEditorState extends State<ImageCropEditor> {
  late Uint8List _currentBytes;
  int _rotationDegrees = 0; // 0, 90, 180, 270
  bool _isProcessing = false;
  CropAspectRatio _selectedRatio = CropAspectRatio.original;

  // Normalized crop rectangle in relative coordinates [0.0 to 1.0]
  // Default to full 100% of the captured framed photo
  Rect _normalizedCropRect = const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0);

  int? _imageWidth;
  int? _imageHeight;

  // Active dragging handle tracker
  _HandleType? _activeHandle;
  Offset? _dragStartOffset;
  Rect? _cropStartRect;

  @override
  void initState() {
    super.initState();
    _currentBytes = widget.imageBytes;
    _loadImageDimensions();
  }

  void _loadImageDimensions() {
    final decoded = img.decodeImage(_currentBytes);
    if (decoded != null) {
      setState(() {
        _imageWidth = decoded.width;
        _imageHeight = decoded.height;
      });
    }
  }

  void _rotateClockwise() {
    setState(() {
      _rotationDegrees = (_rotationDegrees + 90) % 360;
      _resetCropRect();
    });
  }

  void _resetCropRect() {
    setState(() {
      _normalizedCropRect = const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0);
      _selectedRatio = CropAspectRatio.original;
    });
  }

  void _applyAspectRatio(CropAspectRatio ratio, Size containerSize) {
    setState(() {
      _selectedRatio = ratio;
      if (ratio == CropAspectRatio.original) {
        _normalizedCropRect = const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0);
        return;
      }
      if (ratio == CropAspectRatio.free) {
        return;
      }

      double targetRatio = 1.0;
      if (ratio == CropAspectRatio.ratio16x9) {
        targetRatio = 16 / 9;
      } else if (ratio == CropAspectRatio.ratio3x4) {
        targetRatio = 3 / 4;
      } else if (ratio == CropAspectRatio.ratio1x1) {
        targetRatio = 1.0;
      }

      // Calculate normalized rect with center alignment
      double width = 0.85;
      double height = width / targetRatio;

      if (height > 0.85) {
        height = 0.85;
        width = height * targetRatio;
      }

      double left = (1.0 - width) / 2;
      double top = (1.0 - height) / 2;
      _normalizedCropRect = Rect.fromLTWH(left, top, width, height);
    });
  }

  Future<void> _exportCroppedImage() async {
    setState(() => _isProcessing = true);

    try {
      final inputBytes = _currentBytes;
      final degrees = _rotationDegrees;
      final cropRect = _normalizedCropRect;

      // Offload heavy image processing to async compute isolate for zero UI stutter
      final resultBytes = await compute(_processImageIsolate, {
        'bytes': inputBytes,
        'rotation': degrees,
        'cropRect': [cropRect.left, cropRect.top, cropRect.width, cropRect.height],
      });

      if (mounted) {
        Navigator.of(context).pop(resultBytes);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error processing image: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161925),
        elevation: 0,
        title: Text(
          "Crop & Adjust: ${widget.title}",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_right, color: Colors.white),
            tooltip: "Rotate 90°",
            onPressed: _rotateClockwise,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt, color: Colors.white70),
            tooltip: "Reset Crop",
            onPressed: _resetCropRect,
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.accentGold),
                  SizedBox(height: 16),
                  Text("Cropping Document...", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            )
          : Column(
              children: [
                // Top Indicator Info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.black.withValues(alpha: 0.4),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.crop, color: AppColors.accentGold, size: 16),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "Drag corners to adjust crop boundaries",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Interactive Crop Workspace
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (_imageWidth == null || _imageHeight == null) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.accentGold));
                        }

                        final bool isRotatedVertical = (_rotationDegrees % 180 != 0);
                        final double rawW = isRotatedVertical ? _imageHeight!.toDouble() : _imageWidth!.toDouble();
                        final double rawH = isRotatedVertical ? _imageWidth!.toDouble() : _imageHeight!.toDouble();

                        final double imgRatio = rawW / rawH;
                        final double containerW = constraints.maxWidth;
                        final double containerH = constraints.maxHeight;

                        double fittedW = containerW;
                        double fittedH = fittedW / imgRatio;

                        if (fittedH > containerH) {
                          fittedH = containerH;
                          fittedW = fittedH * imgRatio;
                        }

                        return Center(
                          child: SizedBox(
                            width: fittedW,
                            height: fittedH,
                            child: Stack(
                              children: [
                                // Rotated Image inside exact fitted bounds
                                Positioned.fill(
                                  child: Transform.rotate(
                                    angle: _rotationDegrees * (math.pi / 180),
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: _imageWidth!.toDouble(),
                                        height: _imageHeight!.toDouble(),
                                        child: Image.memory(
                                          _currentBytes,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Interactive Crop Overlay bound strictly to fitted image box
                                Positioned.fill(
                                  child: _buildInteractiveCropOverlay(fittedW, fittedH),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Aspect Ratio Selector Bar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  color: const Color(0xFF161925),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _aspectChip("Full Image", CropAspectRatio.original, Icons.crop_original, constraints.biggest),
                          const SizedBox(width: 8),
                          _aspectChip("Free", CropAspectRatio.free, Icons.crop_free, constraints.biggest),
                          const SizedBox(width: 8),
                          _aspectChip("Card 16:9", CropAspectRatio.ratio16x9, Icons.badge_outlined, constraints.biggest),
                          const SizedBox(width: 8),
                          _aspectChip("Doc 3:4", CropAspectRatio.ratio3x4, Icons.article_outlined, constraints.biggest),
                          const SizedBox(width: 8),
                          _aspectChip("Square 1:1", CropAspectRatio.ratio1x1, Icons.crop_square, constraints.biggest),
                        ],
                      ),
                    );
                  }),
                ),

                // Action Bar
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.cancel_outlined, color: Colors.white70),
                            label: const Text("Retake", style: TextStyle(color: Colors.white70)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _exportCroppedImage,
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                            label: const Text("Done & Use", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _aspectChip(String label, CropAspectRatio ratio, IconData icon, Size containerSize) {
    final isSelected = _selectedRatio == ratio;
    return ChoiceChip(
      showCheckmark: false,
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white70),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryBlue,
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      onSelected: (selected) {
        if (selected) {
          _applyAspectRatio(ratio, containerSize);
        }
      },
    );
  }

  Widget _buildInteractiveCropOverlay(double width, double height) {
    final rect = Rect.fromLTWH(
      _normalizedCropRect.left * width,
      _normalizedCropRect.top * height,
      _normalizedCropRect.width * width,
      _normalizedCropRect.height * height,
    );

    return GestureDetector(
      onPanStart: (details) {
        final pos = details.localPosition;
        const handleRadius = 24.0;

        // Check handle touch points
        if ((pos - rect.topLeft).distance <= handleRadius) {
          _activeHandle = _HandleType.topLeft;
        } else if ((pos - rect.topRight).distance <= handleRadius) {
          _activeHandle = _HandleType.topRight;
        } else if ((pos - rect.bottomLeft).distance <= handleRadius) {
          _activeHandle = _HandleType.bottomLeft;
        } else if ((pos - rect.bottomRight).distance <= handleRadius) {
          _activeHandle = _HandleType.bottomRight;
        } else if (rect.contains(pos)) {
          _activeHandle = _HandleType.move;
        } else {
          _activeHandle = null;
        }

        _dragStartOffset = pos;
        _cropStartRect = rect;
      },
      onPanUpdate: (details) {
        if (_activeHandle == null || _dragStartOffset == null || _cropStartRect == null) return;

        final currentPos = details.localPosition;
        final delta = currentPos - _dragStartOffset!;

        double l = _cropStartRect!.left;
        double t = _cropStartRect!.top;
        double r = _cropStartRect!.right;
        double b = _cropStartRect!.bottom;

        const minSize = 40.0;

        switch (_activeHandle!) {
          case _HandleType.topLeft:
            l = math.min(math.max(0, l + delta.dx), r - minSize);
            t = math.min(math.max(0, t + delta.dy), b - minSize);
            break;
          case _HandleType.topRight:
            r = math.max(math.min(width, r + delta.dx), l + minSize);
            t = math.min(math.max(0, t + delta.dy), b - minSize);
            break;
          case _HandleType.bottomLeft:
            l = math.min(math.max(0, l + delta.dx), r - minSize);
            b = math.max(math.min(height, b + delta.dy), t + minSize);
            break;
          case _HandleType.bottomRight:
            r = math.max(math.min(width, r + delta.dx), l + minSize);
            b = math.max(math.min(height, b + delta.dy), t + minSize);
            break;
          case _HandleType.move:
            double w = _cropStartRect!.width;
            double h = _cropStartRect!.height;
            l = math.min(math.max(0, l + delta.dx), width - w);
            t = math.min(math.max(0, t + delta.dy), height - h);
            r = l + w;
            b = t + h;
            break;
        }

        setState(() {
          _selectedRatio = CropAspectRatio.free;
          _normalizedCropRect = Rect.fromLTRB(
            l / width,
            t / height,
            r / width,
            b / height,
          );
        });
      },
      onPanEnd: (_) {
        _activeHandle = null;
      },
      child: CustomPaint(
        painter: _CropOverlayPainter(rect: rect),
      ),
    );
  }
}

enum _HandleType { topLeft, topRight, bottomLeft, bottomRight, move }

class _CropOverlayPainter extends CustomPainter {
  final Rect rect;

  _CropOverlayPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(rect);

    // Dimmed background
    canvas.drawPath(
      backgroundPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.65)
        ..style = PaintingStyle.fill,
    );

    // Crop border
    final borderPaint = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(rect, borderPaint);

    // Rule of thirds grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double thirdW = rect.width / 3;
    double thirdH = rect.height / 3;

    canvas.drawLine(Offset(rect.left + thirdW, rect.top), Offset(rect.left + thirdW, rect.bottom), gridPaint);
    canvas.drawLine(Offset(rect.left + 2 * thirdW, rect.top), Offset(rect.left + 2 * thirdW, rect.bottom), gridPaint);
    canvas.drawLine(Offset(rect.left, rect.top + thirdH), Offset(rect.right, rect.top + thirdH), gridPaint);
    canvas.drawLine(Offset(rect.left, rect.top + 2 * thirdH), Offset(rect.right, rect.top + 2 * thirdH), gridPaint);

    // Corner handle circles
    final handleFill = Paint()..color = AppColors.accentGold;
    final handleBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const radius = 10.0;
    for (final corner in [rect.topLeft, rect.topRight, rect.bottomLeft, rect.bottomRight]) {
      canvas.drawCircle(corner, radius, handleFill);
      canvas.drawCircle(corner, radius, handleBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}

// Background Isolate for fast non-blocking image transform & encode
Uint8List _processImageIsolate(Map<String, dynamic> params) {
  final Uint8List rawBytes = params['bytes'];
  final int rotation = params['rotation'];
  final List<double> cropRect = params['cropRect']; // left, top, width, height normalized

  img.Image? decoded = img.decodeImage(rawBytes);
  if (decoded == null) return rawBytes;

  // 1. Rotate if needed
  if (rotation != 0) {
    decoded = img.copyRotate(decoded, angle: rotation);
  }

  // 2. Crop
  final cropX = (cropRect[0] * decoded.width).clamp(0, decoded.width - 1).toInt();
  final cropY = (cropRect[1] * decoded.height).clamp(0, decoded.height - 1).toInt();
  final cropW = (cropRect[2] * decoded.width).clamp(1, decoded.width - cropX).toInt();
  final cropH = (cropRect[3] * decoded.height).clamp(1, decoded.height - cropY).toInt();

  // If crop covers 100% and no rotation, return input bytes directly
  if (cropX == 0 && cropY == 0 && cropW == decoded.width && cropH == decoded.height && rotation == 0) {
    return rawBytes;
  }

  decoded = img.copyCrop(decoded, x: cropX, y: cropY, width: cropW, height: cropH);

  // Fast JPEG Encode with 88% quality optimization
  return Uint8List.fromList(img.encodeJpg(decoded, quality: 88));
}
