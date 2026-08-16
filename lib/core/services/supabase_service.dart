import 'package:flutter/material.dart';

/// Utility class for Supabase-related helpers.
/// All mock data has been removed – data now comes from Supabase via repositories.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Icon Resolver Helper – maps icon_url or icon_name strings to Flutter IconData
  static IconData getIconData(String? iconName) {
    if (iconName == null || iconName.isEmpty) return Icons.gavel_outlined;
    switch (iconName.toLowerCase()) {
      case 'payments':
      case 'account_balance_wallet':
        return Icons.account_balance_wallet_outlined;
      case 'female':
      case 'woman':
        return Icons.female_outlined;
      case 'groups':
      case 'people':
        return Icons.groups_outlined;
      case 'accessible':
      case 'wheelchair':
        return Icons.accessible_outlined;
      case 'warning':
      case 'storm':
        return Icons.warning_amber_rounded;
      case 'home':
      case 'family_restroom':
        return Icons.family_restroom_outlined;
      case 'landscape':
      case 'location_city':
        return Icons.landscape_outlined;
      case 'card_giftcard':
      case 'history_edu':
        return Icons.history_edu_outlined;
      case 'shield':
      case 'gavel':
        return Icons.gavel_outlined;
      case 'work':
      case 'badge':
        return Icons.work_outline;
      case 'shopping_bag':
      case 'store':
        return Icons.storefront_outlined;
      case 'male':
        return Icons.male_rounded;
      default:
        return Icons.gavel_outlined;
    }
  }
}
