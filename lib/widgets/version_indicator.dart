import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionIndicator extends StatefulWidget {
  const VersionIndicator({super.key});

  @override
  State<VersionIndicator> createState() => _VersionIndicatorState();
}

class _VersionIndicatorState extends State<VersionIndicator> {
  String? _label;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _label = '${info.appName} v${info.version} (${info.buildNumber})';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _label = 'Nyaya Saathi v1.0.0 (1)');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_label == null) return const SizedBox.shrink();
    return Center(
      child: Text(
        _label!,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
