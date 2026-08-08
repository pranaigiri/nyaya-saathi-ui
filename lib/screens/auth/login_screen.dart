import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../citizen/citizen_dashboard_shell.dart';
import '../advocate/advocate_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identityController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isAdvocateRole = false;
  bool _otpSent = false;
  bool _isLoading = false;

  void _sendOtp() {
    if (_identityController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpSent = true;
        });
      }
    });
  }

  void _verifyLogin() {
    if (_otpController.text.trim().isEmpty) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_isAdvocateRole) {
      authProvider.loginAsAdvocate(_identityController.text.trim());
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdvocateDashboardScreen()),
        (route) => false,
      );
    } else {
      authProvider.loginAsCitizen(_identityController.text.trim());
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CitizenDashboardShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register / Login"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primaryBlue,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Welcome to Nyaya Saathi",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                "Sign in with your phone number or email via OTP",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
              ),
            ),
            const SizedBox(height: 28),

            // Role selector
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Citizen Portal"),
                    selected: !_isAdvocateRole,
                    onSelected: (val) => setState(() => _isAdvocateRole = false),
                    selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Advocate Portal"),
                    selected: _isAdvocateRole,
                    onSelected: (val) => setState(() => _isAdvocateRole = true),
                    selectedColor: AppColors.accentGold.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _identityController,
              decoration: InputDecoration(
                labelText: _isAdvocateRole ? "Advocate Phone / Email / Bar ID *" : "Citizen Phone Number / Email *",
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            if (_otpSent) ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: "Enter 6-digit OTP Code *",
                  hintText: "123456",
                  prefixIcon: Icon(Icons.pin_outlined),
                ),
              ),
              const SizedBox(height: 8),
              const Text("Demo OTP: Enter 123456", style: TextStyle(fontSize: 11, color: AppColors.accentGold, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_otpSent ? _verifyLogin : _sendOtp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAdvocateRole ? AppColors.accentGold : AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_otpSent ? "Verify & Login" : "Send OTP Code", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
