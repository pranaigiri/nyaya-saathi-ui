import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/draft_provider.dart';
import '../../providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────
//  Gender option model
// ─────────────────────────────────────────────────────────
class _GenderOption {
  const _GenderOption({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String value;
  final String label;
  final IconData icon;
}

const List<_GenderOption> _genderOptions = [
  _GenderOption(value: 'Male', label: 'Male', icon: Icons.male_rounded),
  _GenderOption(value: 'Female', label: 'Female', icon: Icons.female_rounded),
  _GenderOption(
    value: 'Other',
    label: 'Other',
    icon: Icons.transgender_rounded,
  ),
];

// ─────────────────────────────────────────────────────────
//  District data
// ─────────────────────────────────────────────────────────
const List<Map<String, dynamic>> _districts = [
  {'id': 1, 'name': 'Gangtok (East Sikkim)'},
  {'id': 2, 'name': 'Namchi (South Sikkim)'},
  {'id': 3, 'name': 'Gyalshing (West Sikkim)'},
  {'id': 4, 'name': 'Mangan (North Sikkim)'},
  {'id': 5, 'name': 'Soreng'},
  {'id': 6, 'name': 'Pakyong'},
];

// ─────────────────────────────────────────────────────────
//  Main Widget
// ─────────────────────────────────────────────────────────
class Step2ApplicantDetailsScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2ApplicantDetailsScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step2ApplicantDetailsScreen> createState() =>
      _Step2ApplicantDetailsScreenState();
}

class _Step2ApplicantDetailsScreenState
    extends State<Step2ApplicantDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameController = TextEditingController();
  final _villageTownController = TextEditingController();
  final _phoneController = TextEditingController();

  // State
  String _gender = 'Male';
  int _districtId = 1;
  String _districtName = 'Gangtok (East Sikkim)';

  // DOB – stored as separate parts for the Cupertino wheel pickers
  late int _dobYear;
  late int _dobMonth;
  late int _dobDay;
  bool _dobSelected = false; // true once user confirms the picker

  // ── Cupertino scroll controllers ───────────────────
  late final FixedExtentScrollController _monthCtrl;
  late final FixedExtentScrollController _dayCtrl;
  late final FixedExtentScrollController _yearCtrl;

  // ── Static helper lists ──────────────────────────────
  static final List<int> _years = List<int>.generate(
    DateTime.now().year - 1919,
    (i) => 1920 + i,
  ).reversed.toList();

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<int> get _daysInMonth {
    final days = DateUtils.getDaysInMonth(_dobYear, _dobMonth);
    return List<int>.generate(days, (i) => i + 1);
  }

  // ── Derived DOB display string ───────────────────────
  String get _dobDisplay =>
      '$_dobYear-${_dobMonth.toString().padLeft(2, '0')}-${_dobDay.toString().padLeft(2, '0')}';

  // ─────────────────────────────────────────────────────
  //  Lifecycle
  // ─────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Default DOB anchor: 25 years ago
    final anchor = DateTime.now().subtract(const Duration(days: 365 * 25));
    _dobYear = anchor.year;
    _dobMonth = anchor.month;
    _dobDay = anchor.day;

    final draft = Provider.of<DraftProvider>(context, listen: false).draft;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (draft != null) {
      _fullNameController.text = draft.fullName;
      _gender = draft.gender;
      _villageTownController.text = draft.villageTown;
      _districtId = draft.districtId;
      _districtName = draft.districtName;
      _phoneController.text = draft.phone.isNotEmpty
          ? draft.phone
          : (!auth.userPhoneOrEmail.contains('@') ? auth.userPhoneOrEmail : '');

      // Parse existing DOB from draft
      if (draft.dob != null && draft.dob!.isNotEmpty) {
        final parsed = DateTime.tryParse(draft.dob!);
        if (parsed != null) {
          _dobYear = parsed.year;
          _dobMonth = parsed.month;
          _dobDay = parsed.day;
          _dobSelected = true;
        }
      }
    }

    _monthCtrl = FixedExtentScrollController(initialItem: _dobMonth - 1);
    _dayCtrl = FixedExtentScrollController(initialItem: _dobDay - 1);
    _yearCtrl = FixedExtentScrollController(
      initialItem: _years.indexOf(_dobYear).clamp(0, _years.length - 1),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _villageTownController.dispose();
    _phoneController.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────
  //  Save & advance
  // ─────────────────────────────────────────────────────
  void _saveAndNext() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<DraftProvider>(context, listen: false).updateApplicantDetails(
      fullName: _fullNameController.text.trim(),
      gender: _gender,
      dob: _dobSelected ? _dobDisplay : null,
      villageTown: _villageTownController.text.trim(),
      districtId: _districtId,
      districtName: _districtName,
      email: '',
      phone: _phoneController.text.trim(),
    );

    widget.onNext();
  }

  // ─────────────────────────────────────────────────────
  //  DOB Cupertino wheel picker – modal bottom sheet
  // ─────────────────────────────────────────────────────
  void _openDobModal() {
    int tempYear = _dobYear;
    int tempMonth = _dobMonth;
    int tempDay = _dobDay;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final labelColor = AppColors.primaryBlue;

    void clampTemp(StateSetter setModalState) {
      final maxDay = DateUtils.getDaysInMonth(tempYear, tempMonth);
      if (tempDay > maxDay) {
        tempDay = maxDay;
        _dayCtrl.jumpToItem(tempDay - 1);
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag handle ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── Title row ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cake_outlined,
                          color: AppColors.primaryBlue,
                          size: 22,
                        ),
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

                  // ── Column labels ───────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'MONTH',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: labelColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'DAY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: labelColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'YEAR',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: labelColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Wheel pickers (Optimized font sizes & itemExtent) ──
                  SizedBox(
                    height: 230,
                    child: Row(
                      children: [
                        // Month
                        Expanded(
                          flex: 4,
                          child: CupertinoPicker(
                            scrollController: _monthCtrl,
                            itemExtent: 48,
                            magnification: 1.15,
                            useMagnifier: true,
                            squeeze: 1.1,
                            diameterRatio: 1.3,
                            selectionOverlay:
                                const CupertinoPickerDefaultSelectionOverlay(
                                  capStartEdge: true,
                                  capEndEdge: false,
                                ),
                            onSelectedItemChanged: (idx) {
                              setModalState(() {
                                tempMonth = idx + 1;
                                clampTemp(setModalState);
                              });
                            },
                            children: _monthNames
                                .map(
                                  (m) => Center(
                                    child: Text(
                                      m,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        // Day
                        Expanded(
                          flex: 2,
                          child: CupertinoPicker(
                            scrollController: _dayCtrl,
                            itemExtent: 48,
                            magnification: 1.15,
                            useMagnifier: true,
                            squeeze: 1.1,
                            diameterRatio: 1.3,
                            selectionOverlay:
                                const CupertinoPickerDefaultSelectionOverlay(
                                  capStartEdge: false,
                                  capEndEdge: false,
                                ),
                            onSelectedItemChanged: (idx) {
                              setModalState(() => tempDay = idx + 1);
                            },
                            children: _daysInMonth
                                .map(
                                  (d) => Center(
                                    child: Text(
                                      '$d',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        // Year
                        Expanded(
                          flex: 3,
                          child: CupertinoPicker(
                            scrollController: _yearCtrl,
                            itemExtent: 48,
                            magnification: 1.15,
                            useMagnifier: true,
                            squeeze: 1.1,
                            diameterRatio: 1.3,
                            selectionOverlay:
                                const CupertinoPickerDefaultSelectionOverlay(
                                  capStartEdge: false,
                                  capEndEdge: true,
                                ),
                            onSelectedItemChanged: (idx) {
                              setModalState(() {
                                tempYear = _years[idx];
                                clampTemp(setModalState);
                              });
                            },
                            children: _years
                                .map(
                                  (y) => Center(
                                    child: Text(
                                      '$y',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // ── Action buttons ──────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      14,
                      16,
                      14 + MediaQuery.of(ctx).padding.bottom,
                    ),
                    child: Row(
                      children: [
                        // Cancel
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Confirm
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _dobYear = tempYear;
                                _dobMonth = tempMonth;
                                _dobDay = tempDay;
                                _dobSelected = true;
                              });
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
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

  // ─────────────────────────────────────────────────────
  //  Section label helper
  // ─────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.primaryBlue,
      ),
    ),
  );

  // ─────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mq = MediaQuery.of(context);
    final bottomPad = mq.viewInsets.bottom + mq.padding.bottom + 24;
    final primaryTxt = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondTxt = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryTxt,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fill in the applicant\'s personal details accurately.',
              style: TextStyle(fontSize: 13, color: secondTxt),
            ),
            const SizedBox(height: 24),

            // ── Full Name ─────────────────────────────────
            _sectionLabel('APPLICANT NAME'),
            TextFormField(
              controller: _fullNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Enter full name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Full name is required'
                  : null,
            ),
            const SizedBox(height: 20),

            // ── Gender Pill Selector ──────────────────────
            _sectionLabel('GENDER'),
            _GenderPillSelector(
              selected: _gender,
              isDark: isDark,
              onChanged: (val) => setState(() => _gender = val),
            ),
            const SizedBox(height: 20),

            // ── Date of Birth ─────────────────────────────
            _sectionLabel('DATE OF BIRTH'),
            _DobTriggerButton(
              dobDisplay: _dobSelected ? _dobDisplay : null,
              isDark: isDark,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              primaryTxt: primaryTxt,
              secondTxt: secondTxt,
              onTap: _openDobModal,
            ),
            const SizedBox(height: 20),

            // ── Location ──────────────────────────────────
            _sectionLabel('LOCATION'),
            TextFormField(
              controller: _villageTownController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Village / Town / Ward',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Village/town is required'
                  : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: _districtId,
              decoration: const InputDecoration(
                hintText: 'Select district',
                prefixIcon: Icon(Icons.map_outlined),
              ),
              items: _districts
                  .map(
                    (d) => DropdownMenuItem<int>(
                      value: d['id'] as int,
                      child: Text(d['name'] as String),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _districtId = val;
                    _districtName =
                        _districts.firstWhere((d) => d['id'] == val)['name']
                            as String;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // ── Contact ───────────────────────────────────
            _sectionLabel('CONTACT'),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                hintText: '10-digit mobile number',
                prefixIcon: Icon(Icons.phone_outlined),
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Phone number is required';
                }
                if (v.trim().length < 10) {
                  return 'Enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // ── Submit ────────────────────────────────────
            SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveAndNext,
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: const Text(
                  'Next: Case Type',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Gender Pill Selector
// ─────────────────────────────────────────────────────────
class _GenderPillSelector extends StatelessWidget {
  const _GenderPillSelector({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  final String selected;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _genderOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final opt = entry.value;
        final isLast = index == _genderOptions.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8),
            child: _GenderPill(
              option: opt,
              isActive: opt.value == selected,
              isDark: isDark,
              onTap: () => onChanged(opt.value),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GenderPill extends StatelessWidget {
  const _GenderPill({
    required this.option,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final _GenderOption option;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveBorder = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;
    final inactiveText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final activeBg = isDark ? AppColors.darkSurface : Colors.white;

    final borderColor = isActive ? AppColors.primaryBlue : inactiveBorder;
    final foregroundColor = isActive ? AppColors.primaryBlue : inactiveText;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(option.icon, size: 17),
        label: Text(
          option.label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: isActive
              ? AppColors.primaryBlue.withValues(alpha: 0.08)
              : activeBg,
          side: BorderSide(color: borderColor, width: isActive ? 2.0 : 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  DOB Trigger Button
// ─────────────────────────────────────────────────────────
class _DobTriggerButton extends StatelessWidget {
  const _DobTriggerButton({
    required this.dobDisplay,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.primaryTxt,
    required this.secondTxt,
    required this.onTap,
  });

  final String? dobDisplay;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;
  final Color primaryTxt;
  final Color secondTxt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = dobDisplay != null;

    return GestureDetector(
      onTap: onTap,
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
              color: hasValue ? AppColors.primaryBlue : secondTxt,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasValue ? dobDisplay! : 'Select date of birth',
                style: TextStyle(
                  fontSize: 14,
                  color: hasValue ? primaryTxt : secondTxt,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              hasValue
                  ? Icons.edit_calendar_outlined
                  : Icons.chevron_right_rounded,
              size: 20,
              color: hasValue ? AppColors.primaryBlue : secondTxt,
            ),
          ],
        ),
      ),
    );
  }
}
