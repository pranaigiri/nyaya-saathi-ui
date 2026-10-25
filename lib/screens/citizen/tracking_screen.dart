import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/device_id_service.dart';
import '../../core/utils/date_extensions.dart';
import '../../core/utils/phone_number_formatter.dart';
import '../../core/utils/phone_utils.dart';
import '../../core/utils/tracking_number_formatter.dart';
import '../../data/repositories/application_repository.dart';
import '../../models/legal_aid_application.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/status_badge.dart';
import 'application_detail_screen.dart';

enum TrackingSearchMode { byPhone, byDistrict, direct }

class TrackingScreen extends StatefulWidget {
  final String? initialPhone;

  const TrackingScreen({super.key, this.initialPhone});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _remainingDigitsController = TextEditingController();
  final _directTrackingController = TextEditingController();
  final _phoneController = TextEditingController();

  final _appRepo = ApplicationRepository();

  TrackingSearchMode _searchMode = TrackingSearchMode.byPhone;
  String _selectedDistrictCode = 'GTK';
  bool _useDropdownForDistricts = false;
  bool _isLoading = false;
  List<Map<String, String>> _recentSearches = [];

  // Phone search state
  List<LegalAidApplication> _phoneResults = [];
  bool _hasSearchedPhone = false;
  bool _isLoadingPhone = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  static const Color _violet = Color(0xFF6750C8);
  static const String _prefKeyRecent = 'recent_case_tracking_list';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();

    if (widget.initialPhone != null && widget.initialPhone!.trim().isNotEmpty) {
      final clean = PhoneUtils.normalize(widget.initialPhone);
      _phoneController.text = clean;
      _searchMode = TrackingSearchMode.byPhone;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _performPhoneTrack();
      });
    } else {
      _prefillUserPhone();
    }
  }

  void _prefillUserPhone() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final auth = context.read<AuthProvider?>();
        final phone = auth?.profile?.phoneNumber ?? auth?.currentUser?.phone;
        if (phone != null && phone.trim().isNotEmpty && _phoneController.text.isEmpty) {
          final clean = PhoneUtils.normalize(phone);
          setState(() {
            _phoneController.text = clean;
          });
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _remainingDigitsController.dispose();
    _directTrackingController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownSeconds = 3;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefKeyRecent) ?? [];
      setState(() {
        _recentSearches = list
            .map((item) {
              try {
                final decoded = jsonDecode(item) as Map<String, dynamic>;
                return decoded.map((k, v) => MapEntry(k, v.toString()));
              } catch (_) {
                return <String, String>{};
              }
            })
            .where((m) => m.isNotEmpty)
            .toList();
      });
    } catch (_) {}
  }

  Future<void> _saveRecentSearch(
    String trackingNumber,
    String? phone, [
    String? applicantName,
  ]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = _recentSearches
          .where((s) => s['trackingNumber'] != trackingNumber)
          .toList();
      final updated = [
        {
          'trackingNumber': trackingNumber,
          'phone': phone ?? '',
          'applicantName': (applicantName != null && applicantName.isNotEmpty)
              ? applicantName
              : 'Applicant',
          'date': DateTime.now().formattedDate(),
        },
        ...existing,
      ].take(5).toList();

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Clear History?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(context.tr("clear_search_history_confirm")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr("cancel")),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
            ),
            child: Text(context.tr("delete")),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_prefKeyRecent);
        if (mounted) {
          setState(() {
            _recentSearches.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr("history_cleared")),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (_) {}
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      final raw = data.text!.trim();
      final normalized = TrackingNumberHelper.normalize(raw);

      setState(() {
        _searchMode = TrackingSearchMode.direct;
        _directTrackingController.text = normalized;
        _directTrackingController.selection = TextSelection.fromPosition(
          TextPosition(offset: normalized.length),
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pasted "$normalized"'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getEffectiveTrackingNumber() {
    if (_searchMode == TrackingSearchMode.byDistrict) {
      final remaining = _remainingDigitsController.text.trim();
      return TrackingNumberHelper.normalize(
        remaining,
        defaultDistrictCode: _selectedDistrictCode,
      );
    } else {
      final direct = _directTrackingController.text.trim();
      return TrackingNumberHelper.normalize(direct);
    }
  }

  Future<void> _performPhoneTrack() async {
    if (_cooldownSeconds > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("error_rate_limited")),
          backgroundColor: AppColors.accentGold,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final rawPhone = _phoneController.text.trim();
    final validation = PhoneUtils.validate(rawPhone);
    if (!validation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validation.reason ?? context.tr("error_invalid_input")),
          backgroundColor: AppColors.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final cleanPhone = validation.normalized!;

    setState(() {
      _isLoadingPhone = true;
    });

    _startCooldown();

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final apps = await _appRepo.trackApplicationsByPhone(
        phone: cleanPhone,
        deviceId: deviceId,
      );

      if (mounted) {
        setState(() {
          _phoneResults = apps;
          _hasSearchedPhone = true;
          _isLoadingPhone = false;
        });
      }
    } on ApplicationException catch (ae) {
      if (mounted) {
        setState(() {
          _isLoadingPhone = false;
        });
        String msg = context.tr("error_try_again");
        if (ae.code == 'RATE_LIMITED') {
          msg = context.tr("error_rate_limited");
        } else if (ae.code == 'INVALID_INPUT') {
          msg = context.tr("error_invalid_input");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingPhone = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr("error_try_again")),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openTrackedApplication(String trackingNum, [String? phone]) async {
    setState(() => _isLoading = true);
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final result = await _appRepo.trackApplication(
        trackingNumber: trackingNum,
        phoneNumber: (phone != null && phone.isNotEmpty) ? phone : null,
        deviceId: deviceId,
      );

      setState(() => _isLoading = false);

      if (result != null) {
        _saveRecentSearch(trackingNum, phone, result.applicantFullName);
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
    } on ApplicationException catch (ae) {
      setState(() => _isLoading = false);
      if (mounted) {
        String msg = context.tr("error_try_again");
        if (ae.code == 'RATE_LIMITED') {
          msg = ae.message.isNotEmpty ? ae.message : context.tr("error_rate_limited");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.accentGold,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (_) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorDialog(
          "Unable to load application details. Please check your connection and try again.",
        );
      }
    }
  }

  Future<void> _performTrack() async {
    if (_cooldownSeconds > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("error_rate_limited")),
          backgroundColor: AppColors.accentGold,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final trackingNum = _getEffectiveTrackingNumber();
    final isDirectMode = _searchMode == TrackingSearchMode.direct;
    final phone = isDirectMode ? '' : _phoneController.text.trim();

    if (trackingNum.isEmpty || trackingNum.endsWith('-')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter complete Application Number"),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _startCooldown();

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final result = await _appRepo.trackApplication(
        trackingNumber: trackingNum,
        phoneNumber: isDirectMode ? null : (phone.isNotEmpty ? phone : null),
        deviceId: deviceId,
      );

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        _saveRecentSearch(trackingNum, isDirectMode ? null : phone, result.applicantFullName);

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
          _showNotFoundDialog(trackingNum, isDirectMode ? null : phone);
        }
      }
    } on ApplicationException catch (ae) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        String msg = context.tr("error_try_again");
        if (ae.code == 'RATE_LIMITED') {
          msg = ae.message.isNotEmpty ? ae.message : context.tr("error_rate_limited");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.accentGold,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showErrorDialog(
          "Unable to reach server. Please check your network connection and try again.",
        );
      }
    }
  }

  void _showNotFoundDialog(String trackingNum, [String? phone]) {
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
              "No matching legal aid application was found with the provided details:",
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
                  if (phone != null && phone.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Phone: $phone",
                      style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12.5),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              (phone != null && phone.trim().isNotEmpty)
                  ? "• Please double-check your tracking ID or registered mobile number.\n• If you recently submitted, allow a few moments for indexing.\n• Dial Sikkim SLSA Helpline at 15100 for live support."
                  : "• Please double-check your tracking ID format (e.g. SK-GTK-26-00034).\n• If you recently submitted, allow a few moments for indexing.\n• You can also search using your registered mobile number in the 'By Phone' tab.\n• Dial Sikkim SLSA Helpline at 15100 for live support.",
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
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
        content: Text(message, style: const TextStyle(fontSize: 13, height: 1.4)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
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
      body: RefreshIndicator(
        onRefresh: () async {
          if (_searchMode == TrackingSearchMode.byPhone && _hasSearchedPhone) {
            await _performPhoneTrack();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(18, 14, 18, 48 + bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mode Switcher (By Phone, By District, Direct)
                _buildModeSwitcher(isDark),
                const SizedBox(height: 16),

                if (_searchMode == TrackingSearchMode.byPhone) ...[
                  // Phone Mode: Single input + track button
                  _buildPhoneOnlyTrackCard(isDark),
                  const SizedBox(height: 16),
                  _buildPhoneSubmitButton(),
                  const SizedBox(height: 20),

                  // Results / Empty State
                  if (_isLoadingPhone)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_hasSearchedPhone && _phoneResults.isEmpty)
                    _buildPhoneEmptyState(isDark)
                  else if (_phoneResults.isNotEmpty)
                    _buildPhoneResultsList(isDark),
                ] else ...[
                  // Main Search Input Card (District or Direct)
                  _buildMainSearchCard(isDark),
                  const SizedBox(height: 14),

                  // Mobile Number Card (only shown for By District mode; removed for Direct ID)
                  if (_searchMode == TrackingSearchMode.byDistrict) ...[
                    _buildPhoneCard(isDark),
                    const SizedBox(height: 20),
                  ] else ...[
                    const SizedBox(height: 6),
                  ],

                  // Track Action Button
                  _buildSubmitButton(),
                  const SizedBox(height: 24),
                ],

                // Recent Searches Section
                if (_recentSearches.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildRecentSearchesHeader(),
                  const SizedBox(height: 8),
                  ..._recentSearches.map(
                    (item) => _buildRecentSearchTile(item, isDark),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Mode Switcher ────────────────────────────────────────────────
  Widget _buildModeSwitcher(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              label: "By Phone",
              icon: Icons.phone_android_rounded,
              isSelected: _searchMode == TrackingSearchMode.byPhone,
              onTap: () {
                setState(() => _searchMode = TrackingSearchMode.byPhone);
              },
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _buildModeTab(
              label: "By District",
              icon: Icons.domain_rounded,
              isSelected: _searchMode == TrackingSearchMode.byDistrict,
              onTap: () {
                setState(() => _searchMode = TrackingSearchMode.byDistrict);
              },
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _buildModeTab(
              label: "Direct ID",
              icon: Icons.search_rounded,
              isSelected: _searchMode == TrackingSearchMode.direct,
              onTap: () {
                setState(() => _searchMode = TrackingSearchMode.direct);
              },
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? _violet : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (isDark ? Colors.white : _violet)
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : _violet)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Phone-Only Search Card ───────────────────────────────────────
  Widget _buildPhoneOnlyTrackCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _violet.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.phone_android_rounded, size: 18, color: _violet),
              ),
              const SizedBox(width: 10),
              Text(
                context.tr("track_with_phone"),
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [IndianPhoneNumberFormatter()],
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (_) => _performPhoneTrack(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: "10-digit registered number",
              prefixIcon: const Icon(Icons.phone_outlined),
              prefixText: _phoneController.text.isNotEmpty ? "+91 " : null,
              prefixStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.primaryDark,
              ),
              suffixIcon: _phoneController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        setState(() {
                          _phoneController.clear();
                          _hasSearchedPhone = false;
                          _phoneResults.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 6),
          Text(
            "Track all your legal aid and call-request inquiries in one place",
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneSubmitButton() {
    final isBlocked = _isLoadingPhone || _cooldownSeconds > 0;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isBlocked ? null : _performPhoneTrack,
        style: ElevatedButton.styleFrom(
          backgroundColor: _violet,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        child: _isLoadingPhone
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
                    _cooldownSeconds > 0
                        ? "Please wait ${_cooldownSeconds}s..."
                        : context.tr("track_my_applications"),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPhoneEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 36, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 14),
          Text(
            context.tr("no_applications_found_phone"),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
          ),
          const SizedBox(height: 6),
          Text(
            "Double-check your mobile number or apply freshly for legal aid.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneResultsList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Found ${_phoneResults.length} ${_phoneResults.length == 1 ? 'Application' : 'Applications'}",
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
            Text(
              "Pull down to refresh",
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._phoneResults.map((app) => _buildPhoneApplicationCard(app, isDark)),
      ],
    );
  }

  Widget _buildPhoneApplicationCard(LegalAidApplication app, bool isDark) {
    final cleanPhone = PhoneUtils.normalize(_phoneController.text);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openTrackedApplication(app.trackingNumber, cleanPhone),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      app.trackingNumber.isNotEmpty ? app.trackingNumber : 'Pending No.',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: app.status),
                ],
              ),
              const SizedBox(height: 8),

              // Category / Case Type or Details Pending banner
              if (app.isDetailsPending) ...[
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.accentGold),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        context.tr("details_pending_notice"),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  "${app.categoryName ?? 'Legal Aid'} • ${app.caseTypeName ?? 'General Dispute'}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Submitted: ${app.createdAt.split('T')[0]}",
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (app.applicantFullName != null && app.applicantFullName!.isNotEmpty)
                    Text(
                      app.applicantFullName!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                ],
              ),

              // Quick callback line
              if (app.isQuickMode) ...[
                const SizedBox(height: 10),
                _buildCallbackLine(app.callbackStatus, isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallbackLine(String callbackStatus, bool isDark) {
    final norm = callbackStatus.toUpperCase();
    String text;
    IconData icon;
    Color color;

    switch (norm) {
      case 'CALLBACK_PENDING':
      case 'PENDING_CALL':
        text = context.tr("callback_waiting");
        icon = Icons.phone_in_talk_rounded;
        color = const Color(0xFF0F9D78);
        break;
      case 'CALLBACK_ATTEMPTED':
      case 'CALL_ATTEMPTED':
        text = context.tr("callback_attempted");
        icon = Icons.phone_missed_rounded;
        color = const Color(0xFFD97706);
        break;
      case 'CALLBACK_COMPLETED':
      case 'DETAILS_COLLECTED':
        text = context.tr("callback_details_collected");
        icon = Icons.check_circle_outline_rounded;
        color = AppColors.successGreen;
        break;
      case 'CALLBACK_UNREACHABLE':
      case 'UNREACHABLE':
        text = context.tr("callback_unreachable");
        icon = Icons.phone_disabled_rounded;
        color = AppColors.dangerRed;
        break;
      default:
        text = context.tr("callback_waiting");
        icon = Icons.phone_callback_rounded;
        color = const Color(0xFF0F9D78);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Existing District & Direct Mode Content ──────────────────────
  Widget _buildMainSearchCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: _searchMode == TrackingSearchMode.byDistrict
          ? _buildDistrictModeContent(isDark)
          : _buildDirectModeContent(isDark),
    );
  }

  Widget _buildDistrictModeContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _violet.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_on_rounded, size: 16, color: _violet),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Select District",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _useDropdownForDistricts = !_useDropdownForDistricts;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Row(
                  children: [
                    Icon(
                      _useDropdownForDistricts
                          ? Icons.grid_view_rounded
                          : Icons.arrow_drop_down_circle_outlined,
                      size: 14,
                      color: _violet,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _useDropdownForDistricts ? "Show Cards" : "Dropdown",
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _violet,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_useDropdownForDistricts)
          _buildDistrictDropdown(isDark)
        else
          _buildDistrictCardsGrid(isDark),

        const SizedBox(height: 18),

        const Text(
          "Enter Remaining Digits:",
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _violet.withValues(alpha: isDark ? 0.35 : 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _violet.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 13, color: _violet),
                    const SizedBox(width: 4),
                    Text(
                      "SK-$_selectedDistrictCode-",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _violet,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: TextFormField(
                  controller: _remainingDigitsController,
                  inputFormatters: [RemainingDigitsFormatter()],
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: "26-00034",
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1.0,
                      color: isDark ? AppColors.placeholderDark : AppColors.placeholderLight,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter remaining digits";
                    }
                    return null;
                  },
                ),
              ),

              if (_remainingDigitsController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    setState(() {
                      _remainingDigitsController.clear();
                    });
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Accepts any form: 2600034, 26-00034, or 26 00034",
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondaryLight,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDistrictCardsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: TrackingNumberHelper.sikkimDistricts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (context, index) {
        final opt = TrackingNumberHelper.sikkimDistricts[index];
        final isSelected = _selectedDistrictCode == opt.code;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedDistrictCode = opt.code;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? _violet.withValues(alpha: isDark ? 0.35 : 0.14)
                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? _violet
                    : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  opt.name,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? Colors.white : _violet)
                        : (isDark ? Colors.white70 : AppColors.primaryDark),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "(${opt.code})",
                  style: TextStyle(
                    fontSize: 9.5,
                    color: isSelected
                        ? (isDark ? Colors.white70 : _violet)
                        : AppColors.textSecondaryLight,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDistrictDropdown(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDistrictCode,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? AppColors.iconDark : AppColors.iconLight,
          ),
          items: TrackingNumberHelper.sikkimDistricts.map((opt) {
            return DropdownMenuItem<String>(
              value: opt.code,
              child: Text(
                "${opt.name} (${opt.code})",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedDistrictCode = val;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildDirectModeContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _violet.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt_rounded, size: 16, color: _violet),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Instant Tracking Search",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            IconButton(
              tooltip: "Paste from Clipboard",
              icon: const Icon(Icons.content_paste_rounded, size: 18, color: _violet),
              onPressed: _pasteFromClipboard,
            ),
          ],
        ),
        const SizedBox(height: 10),

        TextFormField(
          controller: _directTrackingController,
          inputFormatters: [TrackingNumberFormatter()],
          textInputAction: TextInputAction.search,
          onFieldSubmitted: (_) => _performTrack(),
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            labelText: "Full Tracking ID *",
            hintText: "e.g. SK-GTK-26-00034",
            prefixIcon: Icon(
              Icons.confirmation_number_outlined,
              color: isDark ? AppColors.darkPrimary : _violet,
            ),
            suffixIcon: _directTrackingController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      setState(() {
                        _directTrackingController.clear();
                      });
                    },
                  )
                : null,
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return "Please enter your Application Number";
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            const Text(
              "Accepts: ",
              style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
            ),
            _buildSampleChip("skgtk2600034"),
            _buildSampleChip("sk-gtk-26-00034"),
            _buildSampleChip("sk gtk 26 00034"),
          ],
        ),
      ],
    );
  }

  Widget _buildSampleChip(String sample) {
    return InkWell(
      onTap: () {
        setState(() {
          _directTrackingController.text = TrackingNumberHelper.normalize(sample);
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _violet.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          sample,
          style: const TextStyle(
            fontSize: 10.5,
            color: _violet,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: _violet.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.phone_iphone_rounded, size: 16, color: _violet),
              ),
              const SizedBox(width: 8),
              const Text(
                "Registered Mobile Number *",
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (_) => _performTrack(),
            decoration: const InputDecoration(
              hintText: "10-digit registered number (e.g. 9876543210)",
              prefixIcon: Icon(Icons.phone_outlined),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return "Please enter registered phone number";
              }
              final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
              if (digits.length < 10) {
                return "Phone number must be at least 10 digits";
              }
              return null;
            },
          ),
          const SizedBox(height: 4),
          const Text(
            "Used to verify applicant identity for case details",
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
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
    );
  }

  // ── Recent Searches Header & Tiles ───────────────────────────────
  Widget _buildRecentSearchesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 18,
              color: AppColors.textSecondaryLight,
            ),
            SizedBox(width: 6),
            Text(
              "Recently Tracked Inquiries",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: _clearRecentSearches,
          icon: const Icon(Icons.delete_outline_rounded, size: 14),
          label: Text(context.tr("clear_search_history"), style: const TextStyle(fontSize: 12)),
        ),
      ],
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
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: ListTile(
          dense: true,
          leading: const Icon(
            Icons.saved_search_rounded,
            color: _violet,
          ),
          title: Text(
            tracking,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          subtitle: Text(
            phone.isNotEmpty ? "$name • $phone" : name,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondaryLight,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          onTap: () {
            setState(() {
              _searchMode = TrackingSearchMode.direct;
              _directTrackingController.text = tracking;
              _phoneController.text = phone;
            });
            _performTrack();
          },
        ),
      ),
    );
  }
}
