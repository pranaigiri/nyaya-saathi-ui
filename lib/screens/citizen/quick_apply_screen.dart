import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/device_id_service.dart';
import '../../core/utils/phone_number_formatter.dart';
import '../../core/utils/phone_utils.dart';
import '../../data/models/district.dart';
import '../../data/repositories/application_repository.dart';
import '../../providers/apply_data_provider.dart';
import '../../providers/auth_provider.dart';
import '../apply_flow/application_success_screen.dart';
import '../../widgets/rate_limit_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
    _loadDistricts();
  }

  void _prefillFromProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.isAuthenticated) {
          final profile = auth.profile;
          if (profile != null) {
            if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) {
              final normalized = PhoneUtils.normalize(profile.phoneNumber);
              if (normalized.isNotEmpty) {
                _phoneController.text = normalized;
              }
            }
            if (profile.fullName.isNotEmpty) {
              _nameController.text = profile.fullName;
            }
            if (profile.districtId != null && profile.districtId!.isNotEmpty) {
              setState(() {
                _selectedDistrictId = profile.districtId;
              });
            }
          }
        }
      } catch (_) {}
    });
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

  Future<void> _handleSubmit() async {
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
      // Ensure elapsed time meets the threshold to protect users who paste quickly.
      final elapsedSoFar = DateTime.now().difference(_screenOpenedAt).inMilliseconds;
      if (elapsedSoFar < 3100) {
        await Future.delayed(Duration(milliseconds: 3100 - elapsedSoFar));
      }

      final elapsedMs = DateTime.now().difference(_screenOpenedAt).inMilliseconds;
      final deviceId = await DeviceIdService.getDeviceId();

      final trackingNumber = await _repository.submitQuickApplication(
        phone: cleanPhone,
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        districtId: _selectedDistrictId,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        deviceId: deviceId,
        honeypot: _honeypotController.text,
        clientElapsedMs: elapsedMs,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ApplicationSuccessScreen(
              applicationNumber: trackingNumber,
              isQuickMode: true,
              phoneNumber: cleanPhone,
            ),
          ),
        );
      }
    } on ApplicationException catch (ae) {
      if (mounted) {
        if (ae.code == 'RATE_LIMITED') {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr("quick_apply_title"),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            context.tr("quick_apply_subtitle"),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: "10-digit mobile number",
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  prefixText: _phoneController.text.isNotEmpty ? "+91 " : null,
                  prefixStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primaryDark,
                  ),
                  suffixIcon: _phoneController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            setState(() {
                              _phoneController.clear();
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
                onChanged: (_) => setState(() {}),
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

              // Optional: Full Name
              Text(
                "${context.tr("full_name")} (Optional)",
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 20),

              // Optional: District Dropdown
              Text(
                "${context.tr("district")} (Optional)",
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 20),

              // Optional: Brief Note
              Text(
                context.tr("quick_apply_note_label"),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                maxLength: 1000,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: "Briefly mention what legal aid or assistance you require...",
                  alignLabelWithHint: true,
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

              // Submit Button
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
                              context.tr("quick_apply_submit_btn"),
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
