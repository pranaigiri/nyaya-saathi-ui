import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/date_extensions.dart';
import '../../core/utils/tracking_number_formatter.dart';
import '../../data/repositories/application_repository.dart';
import '../../providers/auth_provider.dart';
import 'application_detail_screen.dart';

enum TrackingSearchMode { byDistrict, direct }

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

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

  TrackingSearchMode _searchMode = TrackingSearchMode.byDistrict;
  String _selectedDistrictCode = 'GTK';
  bool _useDropdownForDistricts = false;
  bool _isLoading = false;
  List<Map<String, String>> _recentSearches = [];

  static const Color _violet = Color(0xFF6750C8);
  static const String _prefKeyRecent = 'recent_case_tracking_list';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _prefillUserPhone();
  }

  void _prefillUserPhone() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final auth = context.read<AuthProvider?>();
        final phone = auth?.profile?.phoneNumber ?? auth?.currentUser?.phone;
        if (phone != null && phone.trim().isNotEmpty && _phoneController.text.isEmpty) {
          final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
          final clean = digitsOnly.length > 10 ? digitsOnly.substring(digitsOnly.length - 10) : digitsOnly;
          setState(() {
            _phoneController.text = clean;
          });
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _remainingDigitsController.dispose();
    _directTrackingController.dispose();
    _phoneController.dispose();
    super.dispose();
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
    String phone,
    String applicantName,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = _recentSearches
          .where((s) => s['trackingNumber'] != trackingNumber)
          .toList();
      final updated = [
        {
          'trackingNumber': trackingNumber,
          'phone': phone,
          'applicantName': applicantName,
          'date': DateTime.now().formattedDate(),
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

  void _showNotFoundDialog(String trackingNum, String phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(
              Icons.search_off_rounded,
              color: AppColors.dangerRed,
              size: 28,
            ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Phone: $phone",
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "• Please double-check your tracking ID or registered mobile number.\n• If you recently submitted, allow a few moments for indexing.\n• Dial Sikkim SLSA Helpline at 15100 for live support.",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
            Text(
              "Connection Error",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _performTrack() async {
    if (!_formKey.currentState!.validate()) return;

    final trackingNum = _getEffectiveTrackingNumber();
    final phone = _phoneController.text.trim();

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

    try {
      final result = await _appRepo.trackApplication(
        trackingNumber: trackingNum,
        phoneNumber: phone,
      );

      setState(() {
        _isLoading = false;
      });

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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(18, 14, 18, 48 + bottomInset),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search Mode Switcher (Sleek Segmented Tabs) ──
              _buildModeSwitcher(isDark),
              const SizedBox(height: 16),

              // ── Main Search Input Card ──
              _buildMainSearchCard(isDark),
              const SizedBox(height: 14),

              // ── Mobile Number Card ──
              _buildPhoneCard(isDark),
              const SizedBox(height: 20),

              // ── Track Action Button ──
              _buildSubmitButton(),
              const SizedBox(height: 24),

              // ── Recent Searches Section ──
              if (_recentSearches.isNotEmpty) ...[
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
    );
  }

  // ── Segmented Mode Switcher ──────────────────────────────────────
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
              label: "By District",
              icon: Icons.domain_rounded,
              isSelected: _searchMode == TrackingSearchMode.byDistrict,
              onTap: () {
                setState(() {
                  _searchMode = TrackingSearchMode.byDistrict;
                });
              },
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _buildModeTab(
              label: "Direct Search",
              icon: Icons.search_rounded,
              isSelected: _searchMode == TrackingSearchMode.direct,
              onTap: () {
                setState(() {
                  _searchMode = TrackingSearchMode.direct;
                });
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
              size: 17,
              color: isSelected
                  ? (isDark ? Colors.white : _violet)
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : _violet)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main Search Card ─────────────────────────────────────────────
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _searchMode == TrackingSearchMode.byDistrict
          ? _buildDistrictModeContent(isDark)
          : _buildDirectModeContent(isDark),
    );
  }

  // ── Mode 1: District Selection + Fixed Prefix Remaining Digits ───
  Widget _buildDistrictModeContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // District Header & View Toggle (Cards vs Dropdown)
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
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

        // District Selection: Either 6 Cards or Dropdown
        if (_useDropdownForDistricts)
          _buildDistrictDropdown(isDark)
        else
          _buildDistrictCardsGrid(isDark),

        const SizedBox(height: 18),

        // Section: Fixed Prefix + Remaining Digits Input
        const Text(
          "Enter Remaining Digits:",
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),

        // High-contrast Fixed Prefix Input Container
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
              // Non-editable Fixed Prefix Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _violet.withValues(alpha: isDark ? 0.35 : 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _violet.withValues(alpha: 0.4),
                  ),
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

              // Editable Remaining Digits Field
              Expanded(
                child: TextFormField(
                  controller: _remainingDigitsController,
                  inputFormatters: [RemainingDigitsFormatter()],
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                  decoration: const InputDecoration(
                    hintText: "26-00034",
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
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

  // ── 6 Sikkim District Cards Grid ─────────────────────────────────
  Widget _buildDistrictCardsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: TrackingNumberHelper.sikkimDistricts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.75,
      ),
      itemBuilder: (context, index) {
        final dist = TrackingNumberHelper.sikkimDistricts[index];
        final isSelected = dist.matches(_selectedDistrictCode);

        return InkWell(
          onTap: () {
            setState(() {
              _selectedDistrictCode = dist.code;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? _violet.withValues(alpha: isDark ? 0.28 : 0.12)
                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(12),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        dist.name,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? _violet
                              : (isDark ? Colors.white : AppColors.primaryDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 3),
                      const Icon(Icons.check_circle_rounded, size: 12, color: _violet),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _violet
                        : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    dist.code,
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
        );
      },
    );
  }

  // ── District Dropdown Alternative ────────────────────────────────
  Widget _buildDistrictDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDistrictCode,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: _violet),
          items: TrackingNumberHelper.sikkimDistricts.map((dist) {
            return DropdownMenuItem<String>(
              value: dist.code,
              child: Text(
                "${dist.name} (${dist.code})",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
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

  // ── Mode 2: Direct Search with Smart Auto-Hyphenation ────────────
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

        // Text Field for Direct Tracking Search
        TextFormField(
          controller: _directTrackingController,
          inputFormatters: [TrackingNumberFormatter()],
          textInputAction: TextInputAction.next,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
          decoration: InputDecoration(
            labelText: "Full Tracking ID *",
            hintText: "e.g. SK-GTK-26-00034",
            prefixIcon: const Icon(Icons.confirmation_number_outlined, color: _violet),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return "Please enter Tracking ID";
            }
            return null;
          },
        ),
        const SizedBox(height: 8),

        // Helpful Format Suggestions
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

  // ── Phone Number Card ────────────────────────────────────────────
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

  // ── Submit Action Button ─────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _performTrack,
        style: ElevatedButton.styleFrom(
          backgroundColor: _violet,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.tr("track_now"),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
        TextButton(
          onPressed: _clearRecentSearches,
          child: const Text("Clear", style: TextStyle(fontSize: 12)),
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
            "$name • $phone",
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
