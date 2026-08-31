import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/tracking_number_formatter.dart';
import '../../data/repositories/application_repository.dart';
import '../../widgets/captcha_box.dart';
import 'application_detail_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _captchaInputController = TextEditingController();
  final _captchaController = CaptchaController();
  final _appRepo = ApplicationRepository();

  bool _isLoading = false;
  List<Map<String, String>> _recentSearches = [];
  String? _selectedDistrictCode;

  static const Color _violet = Color(0xFF6750C8);

  static const String _prefKeyRecent = 'recent_case_tracking_list';

  static const List<Map<String, String>> _sikkimDistricts = [
    {'name': 'Gangtok', 'code': 'GTK'},
    {'name': 'Namchi', 'code': 'NCH'},
    {'name': 'Pakyong', 'code': 'PKY'},
    {'name': 'Mangan', 'code': 'MGN'},
    {'name': 'Gyalshing', 'code': 'GYL'},
    {'name': 'Soreng', 'code': 'SRG'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _appNumberController.dispose();
    _phoneController.dispose();
    _captchaInputController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefKeyRecent) ?? [];
      setState(() {
        _recentSearches = list.map((item) {
          try {
            final decoded = jsonDecode(item) as Map<String, dynamic>;
            return decoded.map((k, v) => MapEntry(k, v.toString()));
          } catch (_) {
            return <String, String>{};
          }
        }).where((m) => m.isNotEmpty).toList();
      });
    } catch (_) {}
  }

  Future<void> _saveRecentSearch(String trackingNumber, String phone, String applicantName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = _recentSearches.where((s) => s['trackingNumber'] != trackingNumber).toList();
      final updated = [
        {
          'trackingNumber': trackingNumber,
          'phone': phone,
          'applicantName': applicantName,
          'date': DateTime.now().toIso8601String().split('T')[0],
        },
        ...existing,
      ].take(4).toList();

      final encodedList = updated.map((m) => jsonEncode(m)).toList();
      await prefs.setStringList(_prefKeyRecent, encodedList);

      if (mounted) {
        setState(() {
          _recentSearches = updated;
        });
      }
    } catch (_) {}
  }

  Future<void> _clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeyRecent);
      if (mounted) {
        setState(() {
          _recentSearches.clear();
        });
      }
    } catch (_) {}
  }

  void _applyQuickDistrictPrefix(String districtCode) {
    setState(() {
      _selectedDistrictCode = districtCode;
    });

    final year = (DateTime.now().year % 100).toString().padLeft(2, '0');
    final prefix = "SK-$districtCode-$year-";

    _appNumberController.text = prefix;
    _appNumberController.selection = TextSelection.fromPosition(
      TextPosition(offset: prefix.length),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      final text = data.text!.trim().toUpperCase();
      _appNumberController.text = text;
      _appNumberController.selection = TextSelection.fromPosition(
        TextPosition(offset: _appNumberController.text.length),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pasted "$text" from clipboard'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showNotFoundDialog(String trackingNum, String phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.search_off_rounded, color: AppColors.dangerRed, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Application Not Found",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "No matching legal aid application was found with the provided credentials:",
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).brightness == Brightness.dark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(ctx).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tracking ID: $trackingNum",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Phone: $phone",
                    style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "• Please double-check your tracking ID or registered mobile number.\n• If you recently submitted, allow a few moments for indexing.\n• Dial Sikkim SLSA Helpline at 15100 for live support.",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _captchaController.refresh();
              _captchaInputController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: AppColors.dangerRed, size: 26),
            SizedBox(width: 10),
            Text("Connection Error", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _captchaController.refresh();
              _captchaInputController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _performTrack() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate CAPTCHA
    final captchaInput = _captchaInputController.text.trim();
    if (!_captchaController.validate(captchaInput)) {
      _showCaptchaError();
      _captchaController.refresh();
      _captchaInputController.clear();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final trackingNum = _appNumberController.text.trim();
    final phone = _phoneController.text.trim();

    try {
      final result = await _appRepo.trackApplication(
        trackingNumber: trackingNum,
        phoneNumber: phone,
      );

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        // Save to recent searches
        _saveRecentSearch(trackingNum, phone, result.applicantFullName);

        // Reset captcha for next time
        _captchaController.refresh();
        _captchaInputController.clear();

        // Directly open Application Details page
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ApplicationDetailScreen(application: result),
            ),
          );
        }
      } else {
        if (mounted) {
          _showNotFoundDialog(trackingNum, phone);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showErrorDialog("Unable to reach server. Please check your network connection and try again.");
      }
    }
  }

  void _showCaptchaError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text("Security CAPTCHA failed. Please enter the correct code."),
            ),
          ],
        ),
        backgroundColor: AppColors.dangerRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr("track_application")),
        backgroundColor: _violet,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 48 + bottomInset),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Balanced District Prefix Selector (Uniform 3x2 Grid) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select District Prefix:",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  if (_selectedDistrictCode != null)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDistrictCode = null;
                          _appNumberController.clear();
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          "Reset",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _violet,
                        ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // 3-Column x 2-Row Balanced Grid for all 6 Sikkim Districts
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sikkimDistricts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.75,
                ),
                itemBuilder: (context, index) {
                  final dist = _sikkimDistricts[index];
                  final name = dist['name']!;
                  final code = dist['code']!;
                  final isSelected = _selectedDistrictCode == code;

                  return InkWell(
                    onTap: () => _applyQuickDistrictPrefix(code),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _violet.withValues(alpha: isDark ? 0.25 : 0.12)
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : (isDark ? Colors.white : AppColors.primaryDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                code,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
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
              const SizedBox(height: 20),

              // ── Field 1: Tracking ID (Smart Auto-formatted) ────────
              TextFormField(
                controller: _appNumberController,
                inputFormatters: [
                  TrackingNumberFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: "Tracking ID / Application Number *",
                  hintText: "e.g. SK-GTK-26-00013",
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  suffixIcon: IconButton(
                    tooltip: "Paste from Clipboard",
                    icon: const Icon(Icons.content_paste_rounded, size: 20, color: AppColors.primaryBlue),
                    onPressed: _pasteFromClipboard,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? "Please enter Tracking ID" : null,
              ),
              const SizedBox(height: 16),

              // ── Field 2: Registered Phone Number ───────────────────
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Registered Applicant Phone Number *",
                  hintText: "e.g. 9876543210",
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Please enter phone number";
                  if (val.trim().length < 10) return "Phone number must be at least 10 digits";
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // ── Field 3: Visual Security Captcha (Full-Width Input Below Canvas) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.security_rounded, size: 16, color: AppColors.primaryBlue),
                            SizedBox(width: 6),
                            Text(
                              "Security Verification *",
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          "Case Sensitive",
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Centered / Full Captcha Visual Canvas with refresh button
                    Center(
                      child: CaptchaBox(
                        controller: _captchaController,
                        length: 5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Full-width Captcha Text Input placed directly below
                    TextFormField(
                      controller: _captchaInputController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: "Enter 5-Character Security Code *",
                        hintText: "Type the code shown above",
                        prefixIcon: Icon(Icons.password_rounded),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? "Please enter security code" : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Submit Button ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _performTrack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _violet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              context.tr("track_now"),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Recent Searches Section ────────────────────────────
              if (_recentSearches.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.history_rounded, size: 18, color: AppColors.textSecondaryLight),
                        SizedBox(width: 6),
                        Text(
                          "Recently Tracked Inquiries",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _clearRecentSearches,
                      child: const Text("Clear", style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._recentSearches.map((item) => _buildRecentSearchTile(item, isDark)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearchTile(Map<String, String> item, bool isDark) {
    final tracking = item['trackingNumber'] ?? '';
    final phone = item['phone'] ?? '';
    final name = item['applicantName'] ?? 'Applicant';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.saved_search_rounded, color: AppColors.primaryBlue),
          title: Text(
            tracking,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          subtitle: Text(
            "$name • $phone",
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          onTap: () {
            _appNumberController.text = tracking;
            _phoneController.text = phone;
            _performTrack();
          },
        ),
      ),
    );
  }
}
