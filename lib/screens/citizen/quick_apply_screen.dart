import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/device_id_service.dart';
import '../../core/services/sim_service.dart';
import '../../core/utils/phone_number_formatter.dart';
import '../../core/utils/phone_utils.dart';
import '../../data/models/district.dart';
import '../../data/repositories/application_repository.dart';
import '../../providers/apply_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../apply_flow/application_success_screen.dart';
import '../../widgets/rate_limit_dialog.dart';
import '../../widgets/language_switcher_button.dart';

/// Simplified Quick Apply / Callback request screen.
///
/// Designed for maximum accessibility for elderly and first-time smartphone citizens:
/// 1. Automatically suggests available SIM / account phone numbers natively.
/// 2. If suggestions are available, citizen can select with 1 tap.
/// 3. Always provides a clean manual mobile number entry field with "+91 " prefix.
/// 4. Optional fields (Name, District, Note) are neatly tucked in an expandable section.
/// 5. Strictly prevents duplicate active callbacks and displays accurate queue estimates.
class QuickApplyScreen extends StatefulWidget {
  const QuickApplyScreen({super.key});

  @override
  State<QuickApplyScreen> createState() => _QuickApplyScreenState();
}

class _QuickApplyScreenState extends State<QuickApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _honeypotController = TextEditingController();

  final ApplicationRepository _repository = ApplicationRepository();
  final DateTime _screenOpenedAt = DateTime.now();

  String? _selectedDistrictId;
  bool _isSubmitting = false;
  List<District> _districts = [];
  bool _isLoadingDistricts = false;

  // SIM / phone suggestions state
  List<SuggestedPhoneNumber> _suggestions = [];
  SuggestedPhoneNumber? _selectedSuggestion;
  bool _showOptionalDetails = false;

  @override
  void initState() {
    super.initState();
    _initSuggestionsAndProfile();
    _loadDistricts();
  }

  Future<void> _initSuggestionsAndProfile() async {
    String? profilePhone;
    String? profileName;
    String? profileDistrictId;

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        final profile = auth.profile;
        if (profile != null) {
          profilePhone = profile.phoneNumber;
          if (profile.fullName.isNotEmpty) {
            profileName = profile.fullName;
          }
          if (profile.districtId != null && profile.districtId!.isNotEmpty) {
            profileDistrictId = profile.districtId;
          }
        }
      }
    } catch (_) {}

    if (profileName != null && profileName.isNotEmpty) {
      _nameController.text = profileName;
    }
    if (profileDistrictId != null) {
      _selectedDistrictId = profileDistrictId;
    }

    if (profilePhone != null && profilePhone.isNotEmpty) {
      final clean = PhoneUtils.normalize(profilePhone);
      if (clean.isNotEmpty) {
        _phoneController.text = clean;
      }
    }

    // Query native SIMs and profile suggestions
    final detected = await SimService.getSuggestedPhoneNumbers(
      profilePhone: profilePhone,
    );

    if (mounted) {
      setState(() {
        _suggestions = detected;
        if (detected.isNotEmpty && _phoneController.text.isEmpty) {
          _selectedSuggestion = detected.first;
          _phoneController.text = _selectedSuggestion!.number;
        } else if (detected.isNotEmpty) {
          // If controller was prefilled, select matching suggestion if any
          final match = detected.where((s) => s.number == _phoneController.text);
          if (match.isNotEmpty) {
            _selectedSuggestion = match.first;
          }
        }
      });
    }
  }

  Future<void> _loadDistricts() async {
    setState(() => _isLoadingDistricts = true);
    try {
      final applyData = Provider.of<ApplyDataProvider>(context, listen: false);
      final dists = await applyData.getDistricts();
      if (mounted) {
        setState(() {
          _districts = dists;
          _isLoadingDistricts = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingDistricts = false);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _noteController.dispose();
    _honeypotController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit({
    String? captchaToken,
    String? captchaSolution,
  }) async {
    if (_isSubmitting) return;

    // Check honeypot field (hidden from legitimate users)
    if (_honeypotController.text.isNotEmpty) {
      // Silently discard bot submission
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rawPhone = _phoneController.text.trim();
    final cleanPhone = PhoneUtils.normalize(rawPhone);

    setState(() => _isSubmitting = true);

    try {
      // Server enforces MIN_ELAPSED_MS_QUICK (default 3000ms).
      // Ensure elapsed time meets the threshold to protect users who submit rapidly.
      final elapsedSoFar = DateTime.now().difference(_screenOpenedAt).inMilliseconds;
      if (elapsedSoFar < 3100) {
        await Future.delayed(Duration(milliseconds: 3100 - elapsedSoFar));
      }

      final elapsedMs = DateTime.now().difference(_screenOpenedAt).inMilliseconds;
      final deviceId = await DeviceIdService.getDeviceId();

      final result = await _repository.submitQuickApplication(
        phone: cleanPhone,
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        districtId: _selectedDistrictId,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        deviceId: deviceId,
        honeypot: _honeypotController.text,
        clientElapsedMs: elapsedMs,
        captchaToken: captchaToken,
        captchaSolution: captchaSolution,
      );

      if (!mounted) return;

      if (result.isDuplicate) {
        // Show intelligent duplicate queue dialog
        _showAlreadyQueuedDialog(result, cleanPhone);
      } else {
        // Navigate to success confirmation with calculated estimated callback time
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ApplicationSuccessScreen(
              applicationNumber: result.trackingNumber,
              isQuickMode: true,
              phoneNumber: cleanPhone,
              estimatedWaitTime: result.estimatedWaitText,
            ),
          ),
        );
      }
    } on ApplicationException catch (ae) {
      if (mounted) {
        if (ae.isCaptchaRequired) {
          _showCaptchaDialog(ae.captchaData);
        } else if (ae.code == 'RATE_LIMITED') {
          showRateLimitDialog(
            context: context,
            retryAfterMinutes: ae.retryAfterMinutes,
            phoneNumber: cleanPhone,
          );
        } else {
          String msg = context.tr("error_try_again");
          if (ae.code == 'INVALID_INPUT') {
            msg = context.tr("error_invalid_input");
          }
          _showErrorSnackBar(msg);
        }
      }
    } catch (_) {
      if (mounted) {
        _showErrorSnackBar(context.tr("error_try_again"));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showCaptchaDialog(Map<String, dynamic>? captchaData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = captchaData?['question']?.toString() ?? '5 + 3 = ?';
    final token = captchaData?['token']?.toString() ?? '';
    final answerCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('security_verification_title'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('security_verification_desc'),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: answerCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: context.tr('enter_answer'),
                    prefixIcon: const Icon(Icons.calculate_outlined),
                    filled: true,
                    fillColor: isDark ? AppColors.darkBg : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return context.tr('captcha_empty_error');
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                context.tr('action_cancel'),
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  final ans = answerCtrl.text.trim();
                  Navigator.pop(dialogCtx);
                  _handleSubmit(
                    captchaToken: token,
                    captchaSolution: ans,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(context.tr('verify_and_submit')),
            ),
          ],
        );
      },
    );
  }

  void _showAlreadyQueuedDialog(QuickApplyResult result, String phone) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final waitText = result.estimatedWaitText ?? context.tr('estimated_callback_fallback');

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warningOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: AppColors.warningOrange,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('already_queued_title'),
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('already_queued_message'),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              // Queue estimate box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F9D78).withValues(alpha: isDark ? 0.2 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0F9D78).withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF0F9D78)),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('estimated_callback_label'),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F9D78),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      waitText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                    if (result.queuePosition != null && result.totalPending != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        context
                            .tr('queue_position_text')
                            .replaceAll('{pos}', result.queuePosition.toString())
                            .replaceAll('{total}', result.totalPending.toString()),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Tracking ID pill
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tracking ID:",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    Text(
                      result.trackingNumber,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9D78),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  context.tr('action_okay'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.dangerRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSuggestedNumberChips(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.sim_card_outlined, size: 18, color: Color(0xFF0F9D78)),
            const SizedBox(width: 8),
            Text(
              context.tr('suggested_number_title'),
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions.map((suggestion) {
            final isSelected = _selectedSuggestion == suggestion &&
                _phoneController.text == suggestion.number;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedSuggestion = suggestion;
                  _phoneController.text = suggestion.number;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0F9D78)
                        : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected
                      ? const Color(0xFF0F9D78).withValues(alpha: isDark ? 0.2 : 0.1)
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.phone_android_rounded,
                      size: 16,
                      color: isSelected ? const Color(0xFF0F9D78) : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          suggestion.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          suggestion.displayFormatted,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr("request_callback_title"),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          LanguageSwitcherButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 40 + bottomInset),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F9D78), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F9D78).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone_callback_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr("quick_apply_title"),
                            style: const TextStyle(
                              fontSize: 17.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            context.tr("request_callback_subtitle"),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.92),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Hidden honeypot field (kept out of assistive technologies)
              Visibility(
                visible: false,
                maintainState: true,
                child: ExcludeSemantics(
                  child: TextField(
                    controller: _honeypotController,
                    decoration: const InputDecoration(labelText: "Leave Empty"),
                  ),
                ),
              ),

              // Suggested Phone Numbers Chips (if available from native SIM or account)
              if (_suggestions.isNotEmpty)
                _buildSuggestedNumberChips(isDark),

              // Required: Phone Number Field
              Text(
                "${context.tr("phone")} *",
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [IndianPhoneNumberFormatter()],
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: "10-digit mobile number",
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  prefixText: "+91 ",
                  prefixStyle: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primaryDark,
                  ),
                  suffixIcon: _phoneController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            setState(() {
                              _phoneController.clear();
                              _selectedSuggestion = null;
                            });
                          },
                        )
                      : null,
                ),
                validator: (val) {
                  final result = PhoneUtils.validate(val);
                  if (!result.isValid) {
                    return result.reason ?? "Please enter a valid mobile number";
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    final match = _suggestions.where((s) => s.number == PhoneUtils.normalize(val));
                    _selectedSuggestion = match.isNotEmpty ? match.first : null;
                  });
                },
              ),
              const SizedBox(height: 6),
              Text(
                "Indian mobile number (starts with 6, 7, 8, or 9)",
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 20),

              // Optional Expandable Details Section (Custom disclosure card)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _showOptionalDetails = !_showOptionalDetails),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.tune_rounded, color: Color(0xFF0F9D78), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                context.tr("add_more_details_optional"),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            Icon(
                              _showOptionalDetails ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                              color: isDark ? Colors.white60 : Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showOptionalDetails)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              height: 1,
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                            const SizedBox(height: 14),

                            // Optional: Full Name
                            Text(
                              "${context.tr("full_name")} (Optional)",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              maxLength: 100,
                              style: TextStyle(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                              decoration: const InputDecoration(
                                hintText: "e.g. Tenzing Norbu",
                                prefixIcon: Icon(Icons.person_outline_rounded),
                                counterText: "",
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Optional: District Dropdown
                            Text(
                              "${context.tr("district")} (Optional)",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDistrictId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                hintText: _isLoadingDistricts ? "Loading districts..." : "Select your district",
                                prefixIcon: const Icon(Icons.location_on_outlined),
                              ),
                              items: _districts.map((d) {
                                return DropdownMenuItem<String>(
                                  value: d.id,
                                  child: Text(
                                    d.districtName,
                                    style: TextStyle(
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedDistrictId = val;
                                });
                              },
                            ),
                            const SizedBox(height: 14),

                            // Optional: Brief Note
                            Text(
                              context.tr("quick_apply_note_label"),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _noteController,
                              maxLines: 3,
                              maxLength: 1000,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                hintText: "Briefly mention what legal aid or assistance you require...",
                                alignLabelWithHint: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SLSA Callback Notice Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: Color(0xFF0F9D78),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr("quick_apply_notice"),
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Prominent Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F9D78),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.tr("quick_apply_submitting"),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone_callback_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              context.tr("request_callback_title"),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
