import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import 'tabs/home_tab.dart';
import 'tabs/my_applications_tab.dart';
import 'tabs/notifications_tab.dart';
import 'tabs/chat_tab.dart';
import 'profile_screen.dart';

class CitizenDashboardShell extends StatefulWidget {
  const CitizenDashboardShell({super.key});

  @override
  State<CitizenDashboardShell> createState() => _CitizenDashboardShellState();
}

class _CitizenDashboardShellState extends State<CitizenDashboardShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    MyApplicationsTab(),
    NotificationsTab(),
    ChatTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.gavel_rounded, color: AppColors.primaryBlue, size: 20),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr("app_title"),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    "by Sikkim State Legal Services Authority",
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondaryLight,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard_rounded),
            label: context.tr("tab_dashboard"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.folder_open_outlined),
            activeIcon: const Icon(Icons.folder_rounded),
            label: context.tr("tab_applications"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_outlined),
            activeIcon: const Icon(Icons.notifications_rounded),
            label: context.tr("tab_notifications"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_outlined),
            activeIcon: const Icon(Icons.chat_rounded),
            label: context.tr("tab_chat"),
          ),
        ],
      ),
    );
  }
}
