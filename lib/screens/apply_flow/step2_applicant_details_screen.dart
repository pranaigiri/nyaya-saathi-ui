import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/draft_provider.dart';
import '../../providers/auth_provider.dart';

class Step2ApplicantDetailsScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2ApplicantDetailsScreen({super.key, required this.onNext, required this.onBack});

  @override
  State<Step2ApplicantDetailsScreen> createState() => _Step2ApplicantDetailsScreenState();
}

class _Step2ApplicantDetailsScreenState extends State<Step2ApplicantDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  String _gender = 'Male';
  final _dobController = TextEditingController();
  final _villageTownController = TextEditingController();
  int _districtId = 1;
  String _districtName = 'Gangtok (East Sikkim)';
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<Map<String, dynamic>> _districts = [
    {'id': 1, 'name': 'Gangtok (East Sikkim)'},
    {'id': 2, 'name': 'Namchi (South Sikkim)'},
    {'id': 3, 'name': 'Gyalshing (West Sikkim)'},
    {'id': 4, 'name': 'Mangan (North Sikkim)'},
    {'id': 5, 'name': 'Soreng'},
    {'id': 6, 'name': 'Pakyong'},
  ];

  @override
  void initState() {
    super.initState();
    final draft = Provider.of<DraftProvider>(context, listen: false).draft;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (draft != null) {
      _fullNameController.text = draft.fullName;
      _gender = draft.gender;
      _dobController.text = draft.dob ?? '';
      _villageTownController.text = draft.villageTown;
      _districtId = draft.districtId;
      _districtName = draft.districtName;
      _emailController.text = draft.email.isNotEmpty ? draft.email : (auth.userPhoneOrEmail.contains('@') ? auth.userPhoneOrEmail : '');
      _phoneController.text = draft.phone.isNotEmpty ? draft.phone : (!auth.userPhoneOrEmail.contains('@') ? auth.userPhoneOrEmail : '');
    }
  }

  Future<void> _selectDateOfBirth() async {
    DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 25));
    if (_dobController.text.isNotEmpty) {
      final parsed = DateTime.tryParse(_dobController.text);
      if (parsed != null) initial = parsed;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final monthStr = picked.month.toString().padLeft(2, '0');
        final dayStr = picked.day.toString().padLeft(2, '0');
        _dobController.text = "${picked.year}-$monthStr-$dayStr";
      });
    }
  }

  void _saveAndNext() {
    if (!_formKey.currentState!.validate()) return;

    Provider.of<DraftProvider>(context, listen: false).updateApplicantDetails(
      fullName: _fullNameController.text,
      gender: _gender,
      dob: _dobController.text.isNotEmpty ? _dobController.text : null,
      villageTown: _villageTownController.text,
      districtId: _districtId,
      districtName: _districtName,
      email: _emailController.text,
      phone: _phoneController.text,
    );

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewInsets.bottom > 0 ? mq.viewInsets.bottom : mq.padding.bottom;

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
        children: [
          const FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text("Step 2: Applicant Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          const Text("Fill in your personal details accurately.", style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 20),

          // Personal Details
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(labelText: "Applicant Full Name *", prefixIcon: Icon(Icons.person_outline)),
            validator: (v) => v == null || v.trim().isEmpty ? "Enter full name" : null,
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: const InputDecoration(labelText: "Gender *"),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text("Male")),
                    DropdownMenuItem(value: 'Female', child: Text("Female")),
                    DropdownMenuItem(value: 'Other', child: Text("Other")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _gender = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDateOfBirth,
                  decoration: const InputDecoration(
                    labelText: "Date of Birth *",
                    hintText: "Select DOB",
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _villageTownController,
            decoration: const InputDecoration(labelText: "Village / Town / Ward *", prefixIcon: Icon(Icons.location_city_outlined)),
            validator: (v) => v == null || v.trim().isEmpty ? "Enter village/town" : null,
          ),
          const SizedBox(height: 14),

          DropdownButtonFormField<int>(
            initialValue: _districtId,
            decoration: const InputDecoration(labelText: "District *", prefixIcon: Icon(Icons.map_outlined)),
            items: _districts.map((d) => DropdownMenuItem<int>(value: d['id'] as int, child: Text(d['name'] as String))).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _districtId = val;
                  _districtName = _districts.firstWhere((d) => d['id'] == val)['name'] as String;
                });
              }
            },
          ),
          const SizedBox(height: 14),

          // SEPARATE ROWS FOR PHONE AND EMAIL TO PREVENT CLIPPING
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Phone Number *",
              hintText: "10-digit mobile number",
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (v) => v == null || v.trim().length < 10 ? "Enter valid phone number" : null,
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email Address (Optional)",
              hintText: "e.g. applicant@domain.com",
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAndNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text("Next: Case Type →", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
