import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../../models/notification_model.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationStyle {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _NotificationStyle({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}

class _NotificationsTabState extends State<NotificationsTab> {
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _notifications = [];
        });
      }
      return;
    }

    try {
      final res = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _notifications = (res as List)
              .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
              .toList();
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load notifications';
        });
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notification.id);

      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = NotificationModel(
              id: notification.id,
              title: notification.title,
              body: notification.body,
              isRead: true,
              createdAt: notification.createdAt,
              applicationId: notification.applicationId,
            );
          }
        });
      }
    } catch (_) {
      // Ignore update error
    }
  }

  Future<void> _markAllAsRead() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      await _fetchNotifications();
    } catch (_) {
      // Ignore
    }
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return DateFormat('dd MMM, yyyy').format(dt);
      }
    } catch (_) {
      return '';
    }
  }

  _NotificationStyle _getNotificationStyle(NotificationModel notification, bool isDark) {
    final text = '${notification.title} ${notification.body}'.toUpperCase();

    if (text.contains('RESOLVED') || text.contains('APPROVED') || text.contains('ACCEPTED')) {
      return _NotificationStyle(
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF10B981),
        backgroundColor: const Color(0xFF10B981).withValues(alpha: isDark ? 0.22 : 0.12),
      );
    } else if (text.contains('REJECTED') || text.contains('DECLINED') || text.contains('CANCELLED')) {
      return _NotificationStyle(
        icon: Icons.cancel_rounded,
        color: const Color(0xFFEF4444),
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.22 : 0.12),
      );
    } else if (text.contains('ADVOCATE') || text.contains('ASSIGNED') || text.contains('LAWYER')) {
      return _NotificationStyle(
        icon: Icons.gavel_rounded,
        color: const Color(0xFF8B5CF6),
        backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.22 : 0.12),
      );
    } else if (text.contains('REVIEW') || text.contains('PENDING') || text.contains('PROCESSING')) {
      return _NotificationStyle(
        icon: Icons.hourglass_top_rounded,
        color: const Color(0xFFF59E0B),
        backgroundColor: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.22 : 0.12),
      );
    } else if (text.contains('SUBMITTED') || text.contains('RECEIVED') || text.contains('NEW APPLICATION')) {
      return _NotificationStyle(
        icon: Icons.send_rounded,
        color: const Color(0xFF0284C7),
        backgroundColor: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.22 : 0.12),
      );
    } else if (text.contains('WITHDRAWN')) {
      return _NotificationStyle(
        icon: Icons.remove_circle_rounded,
        color: const Color(0xFF6B7280),
        backgroundColor: const Color(0xFF6B7280).withValues(alpha: isDark ? 0.22 : 0.12),
      );
    }

    // Fallback for all other statuses and general notifications
    return _NotificationStyle(
      icon: Icons.notifications_active_rounded,
      color: AppColors.primaryBlue,
      backgroundColor: AppColors.primaryBlue.withValues(alpha: isDark ? 0.22 : 0.12),
    );
  }

  String? _getEffectiveApplicationId(NotificationModel notification) {
    if (notification.applicationId != null && notification.applicationId!.trim().isNotEmpty) {
      return notification.applicationId!.trim();
    }
    // Search for tracking number pattern (e.g. SK-20260816-001 or LA-xxx or UUID)
    final text = '${notification.title} ${notification.body}';
    final match = RegExp(r'(?:SK|LA|APP)-[A-Za-z0-9-]+|[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}').firstMatch(text);
    return match?.group(0);
  }

  void _onNotificationTapped(NotificationModel notification) {
    _markAsRead(notification);
    final targetId = _getEffectiveApplicationId(notification);
    if (targetId != null && targetId.isNotEmpty) {
      NotificationService.instance.navigateToApplication(targetId);
    } else {
      _showNotificationDetailDialog(notification);
    }
  }

  void _showNotificationDetailDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: AppColors.primaryBlue, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(notification.createdAt),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 12),
            Text(
              notification.body,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildContent(isDark);
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.dangerRed),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _fetchNotifications();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 48,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "No Notifications",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Updates regarding your legal aid applications and advocate assignments will appear here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _notifications.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Sleek Header Action Strip
            return Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4, left: 4, right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$unreadCount New",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (unreadCount > 0)
                    TextButton.icon(
                      onPressed: _markAllAsRead,
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Mark all read', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                ],
              ),
            );
          }

          final notification = _notifications[index - 1];
          final isUnread = !notification.isRead;
          final style = _getNotificationStyle(notification, isDark);
          final hasApp = _getEffectiveApplicationId(notification) != null;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: isUnread ? 1.5 : 0,
              color: isUnread
                  ? (isDark ? AppColors.primaryBlue.withValues(alpha: 0.15) : const Color(0xFFF0F6FF))
                  : (isDark ? AppColors.darkSurface : Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isUnread
                      ? AppColors.primaryBlue.withValues(alpha: 0.3)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _onNotificationTapped(notification),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: style.backgroundColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: style.color.withValues(alpha: isDark ? 0.45 : 0.28),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          style.icon,
                          size: 21,
                          color: style.color,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatDate(notification.createdAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.body,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                                height: 1.35,
                              ),
                            ),
                            if (hasApp) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    'Tap to view application details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isUnread)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
