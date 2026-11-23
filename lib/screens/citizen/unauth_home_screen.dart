import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/phone_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/draft_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/draft_resumption_card.dart';
import '../../widgets/eligibility_check_modal.dart';
import '../../widgets/language_switcher_button.dart';
import '../../widgets/progressive_fade.dart';
import '../apply_flow/apply_wizard_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../onboarding/language_selection_modal.dart';
import 'citizen_dashboard_shell.dart';
import 'quick_apply_screen.dart';
import 'tracking_screen.dart';

/// Redesigned citizen home screen for Nyaya Saathi.
///
/// Combines the clear, elder-friendly 4-section information architecture
/// (Section 1: Fill form, Section 2: Quick apply / Talk to someone, Section 3: Eligibility, Section 4: Tracking)
/// with the authentic visual design language of Nyaya Saathi:
/// - Previous circular emblem with ambient glow shadow and language switcher
/// - Subtle ambient background shapes for visual depth and warmth
/// - Established brand typography (Outfit for headings, Inter for body)
/// - Themed gradients, card elevations, and balanced color distribution in both Light & Dark modes
/// - Generous 28-32dp section gaps for enhanced cognitive clarity
class UnauthHomeScreen extends StatefulWidget {
  const UnauthHomeScreen({super.key});

  @override
  State<UnauthHomeScreen> createState() => _UnauthHomeScreenState();
}

class _UnauthHomeScreenState extends State<UnauthHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunchLanguagePrompt();
    });
  }

  void _checkFirstLaunchLanguagePrompt() {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    if (langProvider.isFirstLaunch && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const LanguageSelectionModal(),
      );
    }
  }

  void _triggerVoiceScreenReadout(BuildContext context) {
    final announcement = context.tr(
      'home_audio_screen_announcement',
      fallback:
          'Welcome to Nyaya Saathi, free legal aid. Tap Apply online yourself to fill the form in 10 minutes. Or tap the green button to call 15100. Or tap Ask us to call you.',
    );

    // Announce to accessibility engine (TalkBack / VoiceOver)
    try {
      final view = View.of(context);
      SemanticsService.sendAnnouncement(view, announcement, TextDirection.ltr);
    } catch (_) {
      // Fallback for older engine targets
      // ignore: deprecated_member_use
      SemanticsService.announce(announcement, TextDirection.ltr);
    }

    _showAudioGuidanceDialog(context, announcement);
  }

  void _showAudioGuidanceDialog(BuildContext context, String narrationText) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppColors.darkSurface : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: dialogBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.primaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr(
                              'home_listen_button',
                              fallback: 'Listen',
                            ),
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.primaryDark,
                            ),
                          ),
                          Text(
                            context.tr(
                              'app_subtitle',
                              fallback: 'Sikkim State Legal Services Authority',
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Text(
                    narrationText,
                    style: GoogleFonts.inter(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(bottomSheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.tr('action_okay', fallback: 'Okay'),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-redirect if already logged in
    bool isAuth = false;
    try {
      isAuth = authProvider.isAuthenticated;
    } catch (_) {
      isAuth = false;
    }
    if (isAuth) {
      return const CitizenDashboardShell();
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR: LISTEN AUDIO PILL & PREVIOUS LANGUAGE SWITCHER
            // Kept strictly outside & above ProgressiveFade so buttons remain crisp,
            // never obscured by the top gradient shader/fade mask.
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 4),
              child: _buildTopUtilityRow(context, isDark),
            ),

            // Scrollable Content
            Expanded(
              child: ProgressiveFade(
                height: 40,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    8,
                    22,
                    44 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // PREVIOUS LOGO EMBLEM WITH AMBIENT GLOW & APP TITLE
                      _buildBrandHeader(context, isDark),
                      const SizedBox(height: 28),

                      // DRAFT RESUMPTION CARD (if draft exists on device)
                      if (draftProvider.draft != null) ...[
                        const DraftResumptionCard(showDiscardButton: true),
                        const SizedBox(height: 28),
                      ],

                      // ---------------------------------------------------------
                      // 1. FILL THE FORM YOURSELF (5-step form fill section)
                      // ---------------------------------------------------------
                      _buildFillFormSection(context, isDark, draftProvider),
                      const SizedBox(height: 30),

                      // ---------------------------------------------------------
                      // 2. QUICK APPLY / TALK TO AN OFFICER
                      // ---------------------------------------------------------
                      _buildQuickApplySection(context, isDark),
                      const SizedBox(height: 28),

                      // ---------------------------------------------------------
                      // SECTION C: NOT SURE? ("Do I qualify?" quiet strip)
                      // ---------------------------------------------------------
                      _buildSectionC(context, isDark),
                      const SizedBox(height: 18),

                      // ---------------------------------------------------------
                      // SECTION D: ALREADY APPLIED? ("Check my application")
                      // ---------------------------------------------------------
                      _buildSectionD(context, isDark),
                      const SizedBox(height: 32),

                      // ---------------------------------------------------------
                      // FOOTER: REGISTER / SIGN IN
                      // ---------------------------------------------------------
                      _buildFooter(context, isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP BAR: LISTEN BUTTON + PREVIOUS LANGUAGE SWITCHER
  // ===========================================================================
  Widget _buildTopUtilityRow(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // "Listen" Speaker Button (Styled consistently with the app's action pills)
        Semantics(
          button: true,
          label: 'Listen to screen guidance',
          child: Material(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => _triggerVoiceScreenReadout(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.03,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.volume_up_rounded,
                      size: 18,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.tr('home_listen_button', fallback: 'Listen'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Previous Language Switcher Button (Preserves exact previous placement & style)
        const LanguageSwitcherButton(),
      ],
    );
  }

  // ===========================================================================
  // PREVIOUS LOGO EMBLEM WITH AMBIENT GLOW & APP TITLE
  // ===========================================================================
  Widget _buildBrandHeader(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Top Header Emblem with previous blue shadow glow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.22),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              cacheWidth: 288,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.gavel_rounded,
                size: 56,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // App Title in Outfit font
        Text(
          context.tr('app_title', fallback: 'Nyaya Saathi'),
          style: GoogleFonts.outfit(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.primaryDark,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle in Accent Gold
        Text(
          context.tr(
            'app_subtitle',
            fallback: 'Sikkim State Legal Services Authority',
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.accentGold,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 1. FILL THE FORM YOURSELF (5-step form fill section)
  // ===========================================================================
  Widget _buildFillFormSection(
    BuildContext context,
    bool isDark,
    DraftProvider draftProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(
                      'home_fill_form_title',
                      fallback: 'Fill the form yourself',
                    ),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    context.tr(
                      'home_fill_form_subtitle',
                      fallback:
                          'Takes about 10 minutes. You can save and continue later.',
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Action: Apply Online Yourself (Sapphire Blue Gradient Button)
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, Color(0xFF1E40AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.30),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (draftProvider.draft == null) {
                  draftProvider.startNewDraft();
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApplyWizardScreen()),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_add,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr(
                              'home_apply_online_title',
                              fallback: 'Apply online yourself',
                            ),
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr(
                              'home_apply_online_badge',
                              fallback: '5 short steps • No account needed',
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.90),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. QUICK APPLY / TALK TO AN OFFICER (Helpline & Callback)
  // ===========================================================================
  Widget _buildQuickApplySection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Color(0xFF059669),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(
                      'home_talk_to_someone_title',
                      fallback: 'Talk to an officer',
                    ),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    context.tr(
                      'home_talk_to_someone_subtitle',
                      fallback: 'Fastest way. An officer will help you.',
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF059669,
                ).withValues(alpha: isDark ? 0.25 : 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF059669).withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                context.tr(
                  'home_free_service_badge',
                  fallback: 'Free service • No fee',
                ),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF047857),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Action 1: Call Button (15100) - Most prominent element on screen
        _buildCallHelplineCard(context),
        const SizedBox(height: 12),

        // Action 2: Ask us to call you (Callback) - Visibly secondary
        _buildRequestCallbackCard(context, isDark),
      ],
    );
  }

  /// Action 1: Call Helpline Card (Solid Emerald Gradient with 15100 badge)
  Widget _buildCallHelplineCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF047857).withValues(alpha: 0.30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final success = await PhoneUtils.dialNalsaHelpline();
            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.tr(
                      'quick_apply_dial_error',
                      fallback:
                          'Could not open dialer. Please dial 15100 directly.',
                    ),
                  ),
                  backgroundColor: AppColors.dangerRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // White circle icon badge
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),

                // Button Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          'home_call_help_title',
                          fallback: 'Call for free legal help',
                        ),
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(
                          'call_nalsa_subtitle',
                          fallback: 'Free legal aid helpline • Call now',
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Readable "15100" Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, size: 14, color: Color(0xFF047857)),
                      SizedBox(width: 4),
                      Text(
                        '15100',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Action 2: Ask Us to Call You (Callback Card - Secondary Card Style)
  Widget _buildRequestCallbackCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuickApplyScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Circular icon in brand blue tint
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_callback_rounded,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Card text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          'home_ask_callback_title',
                          fallback: 'Ask us to call you',
                        ),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(
                          'home_ask_callback_subtitle',
                          fallback: 'An officer will call your phone',
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF94A3B8),
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // ===========================================================================
  // SECTION C: NOT SURE? (Quiet full-width strip)
  // ===========================================================================
  Widget _buildSectionC(BuildContext context, bool isDark) {
    const tealAccent = Color(0xFF0F9D78);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('home_not_sure_title', fallback: 'Not sure?'),
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark
                ? Colors.white70
                : AppColors.primaryDark.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 8),

        // Quiet outlined card matching earlier eligibility style
        InkWell(
          onTap: () => EligibilityCheckModal.show(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tealAccent, width: 1.4),
              color: tealAccent.withValues(alpha: isDark ? 0.12 : 0.05),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.fact_check_rounded,
                  color: tealAccent,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          'home_do_i_qualify_title',
                          fallback: 'Do I qualify?',
                        ),
                        style: GoogleFonts.outfit(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF34D399) : tealAccent,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        context.tr(
                          'home_do_i_qualify_subtitle',
                          fallback: 'Check in 1 minute if you qualify',
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: tealAccent,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SECTION D: ALREADY APPLIED? (Secondary action row)
  // ===========================================================================
  Widget _buildSectionD(BuildContext context, bool isDark) {
    const purpleAccent = Color(0xFF6750C8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(
            'home_already_applied_title',
            fallback: 'Already applied?',
          ),
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark
                ? Colors.white70
                : AppColors.primaryDark.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 8),

        // Quiet tracking card matching earlier track card
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TrackingScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: purpleAccent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: purpleAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          'home_check_my_app_title',
                          fallback: 'Check my application',
                        ),
                        style: GoogleFonts.outfit(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        context.tr(
                          'home_check_my_app_subtitle',
                          fallback: 'Enter application number & date of birth',
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF94A3B8),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // FOOTER: REGISTER / SIGN IN (Matches previous screen styling)
  // ===========================================================================
  Widget _buildFooter(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: Text(
                    context.tr('register', fallback: 'Register'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: Text(
                    context.tr('sign_in', fallback: 'Sign In'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.tr(
              'home_account_benefit',
              fallback: 'Create an account to see all your cases',
            ),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
