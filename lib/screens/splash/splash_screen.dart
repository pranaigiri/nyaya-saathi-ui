import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../providers/language_provider.dart';
import '../../providers/draft_provider.dart';
import '../../providers/auth_provider.dart';
import '../citizen/unauth_home_screen.dart';
import '../citizen/citizen_dashboard_shell.dart';
import '../onboarding/language_selection_modal.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _contentFade;
  late final Animation<double> _contentSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // App logo animation.
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.50, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOutBack),
      ),
    );

    // Text & Content animation.
    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOut),
    );

    _contentSlide = Tween<double>(begin: 14, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.85, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNext();
    });
  }

  Future<void> _navigateToNext() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final draftProvider = Provider.of<DraftProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Run all initialization in parallel
    final results = await Future.wait([
      langProvider.init(),
      draftProvider.loadDraft(),
      authProvider.restoreSession(),
      Future.delayed(const Duration(milliseconds: 2500)),
    ]);

    if (!mounted) return;

    final sessionResult = results[2] as String;

    // Handle language first launch
    if (langProvider.isFirstLaunch) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const LanguageSelectionModal(),
      );
      if (!mounted) return;
    }

    if (!mounted) return;

    // Route based on session status
    if (sessionResult == 'citizen') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CitizenDashboardShell()),
      );
      NotificationService.instance.checkAndConsumePendingNavigation();
    } else {
      if (sessionResult == 'non_citizen') {
        await authProvider.signOut(silent: true);
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UnauthHomeScreen()),
      );
      NotificationService.instance.checkAndConsumePendingNavigation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    // Theme-based colors matching app palette
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final circleOverlayColor = isDark 
        ? AppColors.primaryBlue.withValues(alpha: 0.15) 
        : AppColors.primaryBlue.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ----------------------------------------------------------
            // SUBTLE BACKGROUND DECORATION MATCHING SYSTEM THEME
            // ----------------------------------------------------------
            Positioned(
              top: -size.width * 0.35,
              right: -size.width * 0.30,
              child: Container(
                width: size.width * 0.85,
                height: size.width * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleOverlayColor,
                ),
              ),
            ),

            Positioned(
              bottom: -size.width * 0.40,
              left: -size.width * 0.30,
              child: Container(
                width: size.width * 0.90,
                height: size.width * 0.90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGold.withValues(alpha: isDark ? 0.05 : 0.04),
                ),
              ),
            ),

            // ----------------------------------------------------------
            // MAIN CONTENT
            // ----------------------------------------------------------
            Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ==================================================
                      // APP LOGO
                      // ==================================================
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: isDark ? 0.3 : 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              width: 104,
                              height: 104,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.balance_rounded,
                                  size: 64,
                                  color: AppColors.primaryBlue,
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // APP NAME - ENGLISH
                      // ==================================================
                      AnimatedBuilder(
                        animation: _contentSlide,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _contentSlide.value),
                            child: FadeTransition(
                              opacity: _contentFade,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          'Nyaya Saathi',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 32,
                            height: 1.15,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ==================================================
                      // APP NAME - NEPALI
                      // ==================================================
                      FadeTransition(
                        opacity: _contentFade,
                        child: Text(
                          'न्याय साथी',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            color: AppColors.accentGold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // GOLD DIVIDER
                      // ==================================================
                      FadeTransition(
                        opacity: _contentFade,
                        child: Container(
                          width: 44,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // INITIATIVE LABEL
                      // ==================================================
                      FadeTransition(
                        opacity: _contentFade,
                        child: Text(
                          'AN INITIATIVE OF',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ==================================================
                      // SIKKIM SLSA LOGO
                      // ==================================================
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Image.asset(
                            'assets/images/sikkim_slsa_logo.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox(
                                width: 48,
                                height: 48,
                                child: Icon(
                                  Icons.account_balance_rounded,
                                  size: 30,
                                  color: AppColors.primaryBlue,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ==================================================
                      // SLSA NAME - ENGLISH
                      // ==================================================
                      FadeTransition(
                        opacity: _contentFade,
                        child: Text(
                          'Sikkim State Legal Services Authority',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ==================================================
                      // SLSA NAME - NEPALI
                      // ==================================================
                      FadeTransition(
                        opacity: _contentFade,
                        child: Text(
                          'सिक्किम राज्य कानूनी सेवा प्राधिकरण',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12.5,
                            height: 1.4,
                            color: secondaryTextColor,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ----------------------------------------------------------
            // LOADING INDICATOR
            // ----------------------------------------------------------
            Positioned(
              left: 0,
              right: 0,
              bottom: 34,
              child: FadeTransition(
                opacity: _contentFade,
                child: Column(
                  children: [
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accentGold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Loading...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        color: secondaryTextColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
