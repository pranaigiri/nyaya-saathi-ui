import 'package:flutter/material.dart';
import '../utils/app_icon_resolver.dart';

/// Utility class for Supabase-related helpers.
/// All mock data has been removed – data now comes from Supabase via repositories.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Icon Resolver Helper – delegates to AppIconResolver
  static IconData getIconData(String? iconName) {
    return AppIconResolver.resolve(iconName);
  }
}
