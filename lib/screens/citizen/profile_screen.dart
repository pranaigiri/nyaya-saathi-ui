import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/apply_data_provider.dart';
import '../../data/models/district.dart';
import '../../data/models/gender_option.dart';
import '../splash/splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _villageTownController;

  // Selected State
  String _gender = 'Male';
  String? _dob;
  String? _districtId;

  // DOB Wheel Picker State
  late int _dobYear;
  late int _dobMonth;
  late int _dobDay;
  bool _dobSelected = false;

  late final FixedExtentScrollController _monthCtrl;
  late final FixedExtentScrollController _dayCtrl;
  late final FixedExtentScrollController _yearCtrl;

  late Future<List<District>> _districtsFuture;
  late Future<List<GenderOption>> _genderOptionsFuture;

  bool _isSaving = false;
  bool _isInitialized = false;

  static final List<int> _years = List<int>.generate(
    DateTime.now().year - 1919,
    (i) => 1920 + i,
  ).reversed.toList();

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _villageTownController = TextEditingController();

    // Default DOB anchor: 25 years ago
    final anchor = DateTime.now().subtract(const Duration(days: 365 * 25));
    _dobYear = anchor.year;
    _dobMonth = anchor.month;
    _dobDay = anchor.day;

    _monthCtrl = FixedExtentScrollController(initialItem: _dobMonth - 1);
    _dayCtrl = FixedExtentScrollController(initialItem: _dobDay - 1);
    _yearCtrl = FixedExtentScrollController(
      initialItem: _years.indexOf(_dobYear).clamp(0, _years.length - 1),
    );

    _fullNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _villageTownController.addListener(_onFieldChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final applyDataProvider = Provider.of<ApplyDataProvider>(context, listen: false);
      _districtsFuture = applyDataProvider.getDistricts();
      _genderOptionsFuture = applyDataProvider.getGenderOptions();

      final profile = authProvider.profile;
      if (profile != null) {
        _fullNameController.text = profile.fullName;
        _emailController.text = profile.email ?? authProvider.userEmail;
        _phoneController.text = profile.phoneNumber ?? '';
        _villageTownController.text = profile.villageOrTown ?? '';
        _districtId = profile.districtId;

        if (profile.gender != null && profile.gender!.trim().isNotEmpty) {
          final g = profile.gender!.trim();
          _gender = g[0].toUpperCase() + (g.length > 1 ? g.substring(1).toLowerCase() : '');
        }

        if (profile.dob != null && profile.dob!.isNotEmpty) {
          final parsed = DateTime.tryParse(profile.dob!);
          if (parsed != null) {
            _dobYear = parsed.year;
            _dobMonth = parsed.month;
            _dobDay = parsed.day;
            _dob = profile.dob;
            _dobSelected = true;
          }
        }
      } else {
        _fullNameController.text = authProvider.userName;
        _emailController.text = authProvider.userEmail;
      }
      _isInitialized = true;
    }
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _villageTownController.removeListener(_onFieldChanged);

    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _villageTownController.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  //  7 Required Profile Fields & Percentage Calculation
  // ─────────────────────────────────────────────────────────
  bool get _hasFullName => _fullNameController.text.trim().isNotEmpty;
  bool get _hasEmail =>
      _emailController.text.trim().isNotEmpty &&
      _emailController.text.contains('@') &&
      _emailController.text.contains('.');
  bool get _hasPhone => _phoneController.text.trim().length >= 10;
  bool get _hasGender => _gender.trim().isNotEmpty;
  bool get _hasDob => _dobSelected && _dob != null && _dob!.isNotEmpty;
  bool get _hasVillageTown => _villageTownController.text.trim().isNotEmpty;
  bool get _hasDistrict => _districtId != null && _districtId!.isNotEmpty;

  int get _completedFieldsCount {
    int count = 0;
    if (_hasFullName) count++;
    if (_hasEmail) count++;
    if (_hasPhone) count++;
    if (_hasGender) count++;
    if (_hasDob) count++;
    if (_hasVillageTown) count++;
    if (_hasDistrict) count++;
    return count;
  }

  int get _completionPercentage => ((_completedFieldsCount / 7.0) * 100).round();

  String get _dobDisplay =>
      '$_dobYear-${_dobMonth.toString().padLeft(2, '0')}-${_dobDay.toString().padLeft(2, '0')}';

  // ─────────────────────────────────────────────────────────
  //  Save Profile Changes
  // ─────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the highlighted fields before saving.'),
          backgroundColor: AppColors.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.updateProfile(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      gender: _gender,
      dob: _dobSelected ? _dobDisplay : null,
      villageOrTown: _villageTownController.text.trim().isNotEmpty ? _villageTownController.text.trim() : null,
      districtId: _districtId,
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Profile updated successfully!')),
            ],
          ),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to update profile. Please try again.'),
          backgroundColor: AppColors.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  //  DOB Picker Modal
  // ─────────────────────────────────────────────────────────
  void _openDobModal() {
    int tempYear = _dobYear;
    int tempMonth = _dobMonth;
    int tempDay = _dobDay;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final maxDay = DateUtils.getDaysInMonth(tempYear, tempMonth);
            final daysInMonth = List<int>.generate(maxDay, (i) => i + 1);

            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.cake_outlined, color: AppColors.primaryBlue, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Select Date of Birth',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                    child: Row(
                      children: const [
                        Expanded(flex: 4, child: Text('MONTH', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryBlue))),
                        Expanded(flex: 2, child: Text('DAY', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryBlue))),
                        Expanded(flex: 3, child: Text('YEAR', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryBlue))),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 220,
                    child: Row(
                      children: [
                        // Month
                        Expanded(
                          flex: 4,
                          child: CupertinoPicker(
                            scrollController: _monthCtrl,
                            itemExtent: 44,
                            magnification: 1.15,
                            useMagnifier: true,
                            squeeze: 1.1,
                            onSelectedItemChanged: (idx) {
                              setModalState(() {
                                tempMonth = idx + 1;
                                final dMax = DateUtils.getDaysInMonth(tempYear, tempMonth);
                                if (tempDay > dMax) {
                                  tempDay = dMax;
                                  _dayCtrl.jumpToItem(tempDay - 1);
                                }
                              });
                            },
                            children: _monthNames
                                .map((m) => Center(child: Text(m, style: TextStyle(fontSize: 17, color: textColor, fontWeight: FontWeight.w600))))
                                .toList(),
                          ),
                        ),
                        // Day
                        Expanded(
                          flex: 2,
                          child: CupertinoPicker(
                            scrollController: _dayCtrl,
                            itemExtent: 44,
                            magnification: 1.15,
                            useMagnifier: true,
                            squeeze: 1.1,
                            onSelectedItemChanged: (idx) => setModalState(() => tempDay = idx + 1),
                            children: daysInMonth
                                .map((d) => Center(child: Text('$d', style: TextStyle(fontSize: 17, color: textColor, fontWeight: FontWeight.w600))))
                                .toList(),
                          ),
                        ),
                        // Year
                        Expanded(
                          flex: 3,
                          child: CupertinoPicker(
                            scrollController: _yearCtrl,
                            itemExtent: 44,
                            magnification: 1.15,
                            useMagnifier: true,
                            squeeze: 1.1,
                            onSelectedItemChanged: (idx) {
                              setModalState(() {
                                tempYear = _years[idx];
                                final dMax = DateUtils.getDaysInMonth(tempYear, tempMonth);
                                if (tempDay > dMax) {
                                  tempDay = dMax;
                                  _dayCtrl.jumpToItem(tempDay - 1);
                                }
                              });
                            },
                            children: _years
                                .map((y) => Center(child: Text('$y', style: TextStyle(fontSize: 17, color: textColor, fontWeight: FontWeight.w600))))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(ctx).padding.bottom),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _dobYear = tempYear;
                                _dobMonth = tempMonth;
                                _dobDay = tempDay;
                                _dobSelected = true;
                                _dob = _dobDisplay;
                              });
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Confirm Date'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryTxt = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondTxt = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile & Settings"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Interactive Profile Completion Progress Card ──────
              _buildInteractiveCompletionCard(isDark),
              const SizedBox(height: 24),

              // ── Section Title: Personal Information ──────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "PERSONAL INFORMATION",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  Text(
                    "$_completedFieldsCount of 7 filled",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _completionPercentage == 100 ? AppColors.successGreen : AppColors.accentGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Form Container ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _buildFieldLabel("FULL NAME *", _hasFullName),
                    TextFormField(
                      controller: _fullNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: "Enter full name",
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        suffixIcon: _hasFullName
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20)
                            : null,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Full name is required" : null,
                    ),
                    const SizedBox(height: 18),

                    // Email Address
                    _buildFieldLabel("EMAIL ADDRESS *", _hasEmail),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "example@domain.com",
                        prefixIcon: const Icon(Icons.email_outlined),
                        suffixIcon: _hasEmail
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20)
                            : null,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Email address is required";
                        if (!v.contains('@') || !v.contains('.')) return "Enter a valid email address";
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Phone Number
                    _buildFieldLabel("PHONE NUMBER *", _hasPhone),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        hintText: "10-digit mobile number",
                        prefixIcon: const Icon(Icons.phone_outlined),
                        counterText: "",
                        suffixIcon: _hasPhone
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20)
                            : null,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Phone number is required";
                        if (v.trim().length < 10) return "Enter a valid 10-digit phone number";
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Gender Selection
                    _buildFieldLabel("GENDER *", _hasGender),
                    FutureBuilder<List<GenderOption>>(
                      future: _genderOptionsFuture,
                      builder: (context, snapshot) {
                        final options = snapshot.data ??
                            const [
                              GenderOption(label: 'Male', value: 'Male', iconName: 'male'),
                              GenderOption(label: 'Female', value: 'Female', iconName: 'female'),
                              GenderOption(label: 'Other', value: 'Other', iconName: 'groups'),
                            ];
                        return Row(
                          children: options.map((opt) {
                            final isSelected = opt.value.toLowerCase() == _gender.toLowerCase();
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() => _gender = opt.value);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isSelected
                                        ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                        : surfaceColor,
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primaryBlue : borderColor,
                                      width: isSelected ? 2.0 : 1.0,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Text(
                                    opt.label,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? AppColors.primaryBlue : secondTxt,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    // Date of Birth
                    _buildFieldLabel("DATE OF BIRTH *", _hasDob),
                    GestureDetector(
                      onTap: _openDobModal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 20,
                              color: _hasDob ? AppColors.primaryBlue : secondTxt,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _hasDob ? _dobDisplay : 'Select date of birth',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _hasDob ? primaryTxt : secondTxt,
                                  fontWeight: _hasDob ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (_hasDob)
                              const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20)
                            else
                              Icon(Icons.chevron_right_rounded, color: secondTxt, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Village / Town
                    _buildFieldLabel("VILLAGE / TOWN / WARD *", _hasVillageTown),
                    TextFormField(
                      controller: _villageTownController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: "Enter village or town name",
                        prefixIcon: const Icon(Icons.location_city_outlined),
                        suffixIcon: _hasVillageTown
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20)
                            : null,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Village or town is required" : null,
                    ),
                    const SizedBox(height: 18),

                    // District
                    _buildFieldLabel("DISTRICT *", _hasDistrict),
                    FutureBuilder<List<District>>(
                      future: _districtsFuture,
                      builder: (context, snapshot) {
                        final districts = snapshot.data ?? const <District>[];
                        final hasMatch = districts.any((d) => d.id == _districtId);
                        final selectedValue = hasMatch ? _districtId : null;

                        return DropdownButtonFormField<String>(
                          initialValue: selectedValue,
                          decoration: InputDecoration(
                            hintText: 'Select district',
                            prefixIcon: const Icon(Icons.map_outlined),
                            suffixIcon: _hasDistrict
                                ? const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20),
                                  )
                                : null,
                          ),
                          items: districts
                              .map(
                                (d) => DropdownMenuItem<String>(
                                  value: d.id,
                                  child: Text(d.districtName),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _districtId = val);
                            }
                          },
                          validator: (v) => (v == null || v.isEmpty) ? 'Please select a district' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Update Profile Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save_rounded, size: 20),
                        label: Text(
                          _isSaving ? "Saving..." : "Save Profile Details",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Application Isolation Reassurance Notice ───────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_user_outlined, color: AppColors.primaryBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Note: Updating your profile only affects future applications. Your previously submitted and ongoing applications retain their original submitted details.",
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Section Title: App Preferences ───────────────────
              const Text(
                "APP PREFERENCES",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentGold),
              ),
              const SizedBox(height: 10),

              // Language Selector
              _buildPreferenceTile(
                context,
                icon: Icons.language,
                title: "App Language",
                trailing: DropdownButton<String>(
                  value: langProvider.locale.languageCode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text("English")),
                    DropdownMenuItem(value: 'ne', child: Text("नेपाली")),
                  ],
                  onChanged: (val) {
                    if (val != null) langProvider.setLanguage(val);
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Theme Selector
              _buildPreferenceTile(
                context,
                icon: Icons.brightness_6,
                title: "App Theme",
                trailing: DropdownButton<ThemeMode>(
                  value: themeProvider.themeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                    DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
                  ],
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setThemeMode(mode);
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Font Scale Selector
              _buildPreferenceTile(
                context,
                icon: Icons.format_size,
                title: "Text Font Size",
                trailing: DropdownButton<AppFontScale>(
                  value: themeProvider.fontScale,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: AppFontScale.small, child: Text("Small")),
                    DropdownMenuItem(value: AppFontScale.medium, child: Text("Medium")),
                    DropdownMenuItem(value: AppFontScale.large, child: Text("Large")),
                  ],
                  onChanged: (scale) {
                    if (scale != null) themeProvider.setFontScale(scale);
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await authProvider.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppColors.dangerRed),
                  label: const Text("Logout", style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.dangerRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text, bool isFilled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  Interactive Profile Completion Card
  // ─────────────────────────────────────────────────────────
  Widget _buildInteractiveCompletionCard(bool isDark) {
    final pct = _completionPercentage;
    final isComplete = pct == 100;
    final progressColor = isComplete
        ? AppColors.successGreen
        : (pct >= 50 ? AppColors.primaryBlue : const Color(0xFFF97316));

    final missingFields = <String>[];
    if (!_hasFullName) missingFields.add("Full Name");
    if (!_hasEmail) missingFields.add("Email");
    if (!_hasPhone) missingFields.add("Phone");
    if (!_hasGender) missingFields.add("Gender");
    if (!_hasDob) missingFields.add("DOB");
    if (!_hasVillageTown) missingFields.add("Village/Town");
    if (!_hasDistrict) missingFields.add("District");

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isComplete
              ? AppColors.successGreen.withValues(alpha: 0.4)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isComplete ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: progressColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Circular Animated Progress Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: CircularProgressIndicator(
                      value: pct / 100.0,
                      strokeWidth: 6,
                      backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  Text(
                    "$pct%",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isComplete ? "Profile 100% Complete" : "Profile Completion",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isComplete) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: AppColors.successGreen, size: 18),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isComplete
                          ? "Ready for 1-Click Auto-Fill when applying for legal aid."
                          : "$_completedFieldsCount of 7 details completed.",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Animated Linear Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              tween: Tween<double>(begin: 0, end: pct / 100.0),
              builder: (context, val, _) => LinearProgressIndicator(
                value: val,
                minHeight: 6,
                backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 7-Field Checklist Badges
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildFieldChip("Name", _hasFullName),
              _buildFieldChip("Email", _hasEmail),
              _buildFieldChip("Phone", _hasPhone),
              _buildFieldChip("Gender", _hasGender),
              _buildFieldChip("DOB", _hasDob),
              _buildFieldChip("Village", _hasVillageTown),
              _buildFieldChip("District", _hasDistrict),
            ],
          ),

          if (missingFields.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              "Missing: ${missingFields.join(', ')}",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.accentGold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldChip(String label, bool isDone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.successGreen.withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDone
              ? AppColors.successGreen.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 12,
            color: isDone ? AppColors.successGreen : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
              color: isDone ? AppColors.successGreen : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceTile(BuildContext context, {required IconData icon, required String title, required Widget trailing}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          trailing,
        ],
      ),
    );
  }
}
