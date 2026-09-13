import 'package:flutter/material.dart';

/// Centralized cross-platform icon resolver for the Nyaya Saathi Flutter application.
///
/// Decodes the platform-independent `library:name` canonical format:
/// - `tabler:<name>`   -> Tabler icons
/// - `material:<name>` -> Material Symbols / Material Icons
/// - `lucide:<name>`   -> Lucide icons
/// - `pi pi-<name>`    -> Legacy PrimeIcons (backward compatibility)
///
/// Ensures graceful fallback so unknown, invalid, or null identifiers
/// never crash the application or produce broken visual elements.
class AppIconResolver {
  const AppIconResolver._();

  /// Default fallback icon when no valid mapping or keyword match is found.
  static const IconData defaultFallback = Icons.gavel_rounded;

  /// Resolves an icon string into a Flutter [IconData].
  static IconData resolve(String? rawValue, {IconData fallback = defaultFallback}) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return fallback;
    }

    final val = rawValue.trim();

    // 1. Check for legacy PrimeIcons prefix (e.g. 'pi pi-users')
    if (val.startsWith('pi pi-') || val.startsWith('pi-')) {
      final cleanName = val.replaceFirst('pi pi-', '').replaceFirst('pi-', '').trim().toLowerCase();
      final mapped = _primeIconMap[cleanName];
      if (mapped != null) return mapped;
      return _keywordFallback(cleanName) ?? fallback;
    }

    // 2. Check for library prefix: `library:name`
    final colonIdx = val.indexOf(':');
    if (colonIdx > 0 && colonIdx < val.length - 1) {
      final library = val.substring(0, colonIdx).trim().toLowerCase();
      final iconName = val.substring(colonIdx + 1).trim().toLowerCase();

      switch (library) {
        case 'tabler':
          final mapped = _tablerMap[iconName];
          if (mapped != null) return mapped;
          return _keywordFallback(iconName) ?? fallback;

        case 'material':
        case 'material-symbols':
          final mapped = _materialMap[iconName];
          if (mapped != null) return mapped;
          return _keywordFallback(iconName) ?? fallback;

        case 'lucide':
          final mapped = _lucideMap[iconName];
          if (mapped != null) return mapped;
          return _keywordFallback(iconName) ?? fallback;

        case 'iconify':
          // Legacy nested format e.g. iconify:mdi:scale-balance
          return _keywordFallback(iconName) ?? fallback;

        default:
          return _keywordFallback(iconName) ?? fallback;
      }
    }

    // 3. Bare icon name (e.g., legacy keywords 'payments', 'female', 'groups')
    final lower = val.toLowerCase();
    final tablerDirect = _tablerMap[lower];
    if (tablerDirect != null) return tablerDirect;

    final materialDirect = _materialMap[lower];
    if (materialDirect != null) return materialDirect;

    return _keywordFallback(lower) ?? fallback;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Tabler Icon Dictionary
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, IconData> _tablerMap = {
    'gavel': Icons.gavel_rounded,
    'shield': Icons.shield_rounded,
    'shield-check': Icons.verified_user_rounded,
    'users': Icons.groups_rounded,
    'user': Icons.person_rounded,
    'user-edit': Icons.manage_accounts_rounded,
    'heart': Icons.favorite_rounded,
    'gender-female': Icons.female_rounded,
    'gender-male': Icons.male_rounded,
    'home': Icons.home_rounded,
    'building': Icons.apartment_rounded,
    'building-factory': Icons.factory_rounded,
    'briefcase': Icons.work_rounded,
    'book': Icons.menu_book_rounded,
    'school': Icons.school_rounded,
    'wallet': Icons.account_balance_wallet_rounded,
    'cash': Icons.payments_rounded,
    'credit-card': Icons.credit_card_rounded,
    'receipt': Icons.receipt_long_rounded,
    'shopping-cart': Icons.shopping_cart_rounded,
    'tag': Icons.local_offer_rounded,
    'tags': Icons.style_rounded,
    'car': Icons.directions_car_rounded,
    'truck': Icons.local_shipping_rounded,
    'plane': Icons.flight_rounded,
    'map': Icons.map_rounded,
    'map-pin': Icons.location_on_rounded,
    'globe': Icons.public_rounded,
    'compass': Icons.explore_rounded,
    'flag': Icons.flag_rounded,
    'file': Icons.description_rounded,
    'file-text': Icons.article_rounded,
    'file-time': Icons.pending_actions_rounded,
    'file-pencil': Icons.edit_document,
    'file-type-pdf': Icons.picture_as_pdf_rounded,
    'folder': Icons.folder_rounded,
    'folder-open': Icons.folder_open_rounded,
    'copy': Icons.content_copy_rounded,
    'paperclip': Icons.attach_file_rounded,
    'link': Icons.link_rounded,
    'mail': Icons.mail_rounded,
    'phone': Icons.phone_rounded,
    'device-mobile': Icons.smartphone_rounded,
    'device-desktop': Icons.desktop_windows_rounded,
    'device-tablet': Icons.tablet_mac_rounded,
    'camera': Icons.camera_alt_rounded,
    'photo': Icons.photo_rounded,
    'video': Icons.videocam_rounded,
    'microphone': Icons.mic_rounded,
    'printer': Icons.print_rounded,
    'download': Icons.download_rounded,
    'upload': Icons.upload_rounded,
    'inbox': Icons.inbox_rounded,
    'send': Icons.send_rounded,
    'calendar': Icons.calendar_today_rounded,
    'clock': Icons.schedule_rounded,
    'history': Icons.history_rounded,
    'circle-check': Icons.check_circle_rounded,
    'circle-x': Icons.cancel_rounded,
    'alert-circle': Icons.warning_rounded,
    'info-circle': Icons.info_rounded,
    'help-circle': Icons.help_outline_rounded,
    'star': Icons.star_rounded,
    'thumb-up': Icons.thumb_up_rounded,
    'thumb-down': Icons.thumb_down_rounded,
    'bolt': Icons.bolt_rounded,
    'sun': Icons.wb_sunny_rounded,
    'moon': Icons.nightlight_round,
    'cloud': Icons.cloud_rounded,
    'leaf': Icons.eco_rounded,
    'settings': Icons.settings_rounded,
    'tool': Icons.build_rounded,
    'hammer': Icons.handyman_rounded,
    'lock': Icons.lock_rounded,
    'lock-open': Icons.lock_open_rounded,
    'key': Icons.key_rounded,
    'eye': Icons.visibility_rounded,
    'eye-off': Icons.visibility_off_rounded,
    'bell': Icons.notifications_rounded,
    'sitemap': Icons.account_tree_rounded,
    'share': Icons.share_rounded,
    'chart-bar': Icons.bar_chart_rounded,
    'chart-line': Icons.show_chart_rounded,
    'chart-pie': Icons.pie_chart_rounded,
    'database': Icons.storage_rounded,
    'server': Icons.dns_rounded,
    'code': Icons.code_rounded,
    'list': Icons.format_list_bulleted_rounded,
    'table': Icons.table_chart_rounded,
    'layout-columns': Icons.view_column_rounded,
    'filter': Icons.filter_list_rounded,
    'search': Icons.search_rounded,
    'crown': Icons.military_tech_rounded,
    'bookmark': Icons.bookmark_rounded,
    'box': Icons.inventory_2_rounded,
    'pencil': Icons.edit_rounded,
    'trash': Icons.delete_outline_rounded,
    'plus': Icons.add_rounded,
    'refresh': Icons.refresh_rounded,
    'dots': Icons.more_horiz_rounded,
    'messages': Icons.chat_bubble_outline_rounded,
    'list-check': Icons.fact_check_rounded,
    'layout-grid': Icons.grid_view_rounded,
    'scale': Icons.balance_rounded,
    'coin-rupee': Icons.currency_rupee_rounded,
    'certificate': Icons.card_membership_rounded,
    'disabled': Icons.accessible_rounded,
  };

  // ─────────────────────────────────────────────────────────────────────────
  //  Material Symbols / Icons Dictionary
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, IconData> _materialMap = {
    'school': Icons.school_rounded,
    'home': Icons.home_rounded,
    'forest-outline-rounded': Icons.park_rounded,
    'flood-outline': Icons.tsunami_rounded,
    'woman-2-rounded': Icons.woman_rounded,
    'child-hat': Icons.child_care_rounded,
    'landscape': Icons.landscape_rounded,
    'heart-broken-outline': Icons.heart_broken_rounded,
    'elderly-woman-rounded': Icons.elderly_woman_rounded,
    'man': Icons.man_rounded,
    'woman': Icons.woman_rounded,
    'balance': Icons.balance_rounded,
    'gavel': Icons.gavel_rounded,
    'shield': Icons.shield_rounded,
    'person': Icons.person_rounded,
    'people': Icons.people_rounded,
    'work': Icons.work_rounded,
    'account_balance_wallet': Icons.account_balance_wallet_rounded,
    'accessible': Icons.accessible_rounded,
    'wheelchair': Icons.accessible_rounded,
    'warning': Icons.warning_amber_rounded,
    'family_restroom': Icons.family_restroom_rounded,
    'storefront': Icons.storefront_rounded,
  };

  // ─────────────────────────────────────────────────────────────────────────
  //  Lucide Icon Dictionary
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, IconData> _lucideMap = {
    'building-2': Icons.apartment_rounded,
    'receipt-indian-rupee': Icons.currency_rupee_rounded,
    'pc-case': Icons.devices_rounded,
    'scale': Icons.balance_rounded,
    'file-text': Icons.article_rounded,
    'users': Icons.groups_rounded,
    'briefcase': Icons.work_rounded,
    'car': Icons.directions_car_rounded,
  };

  // ─────────────────────────────────────────────────────────────────────────
  //  Legacy PrimeIcons Dictionary
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, IconData> _primeIconMap = {
    'gavel': Icons.gavel_rounded,
    'shield': Icons.shield_rounded,
    'users': Icons.groups_rounded,
    'user': Icons.person_rounded,
    'heart': Icons.favorite_rounded,
    'female': Icons.female_rounded,
    'home': Icons.home_rounded,
    'building': Icons.apartment_rounded,
    'briefcase': Icons.work_rounded,
    'book': Icons.menu_book_rounded,
    'graduation-cap': Icons.school_rounded,
    'wallet': Icons.account_balance_wallet_rounded,
    'money-bill': Icons.payments_rounded,
    'credit-card': Icons.credit_card_rounded,
    'receipt': Icons.receipt_long_rounded,
    'shopping-cart': Icons.shopping_cart_rounded,
    'tag': Icons.local_offer_rounded,
    'tags': Icons.style_rounded,
    'car': Icons.directions_car_rounded,
    'map': Icons.map_rounded,
    'map-marker': Icons.location_on_rounded,
    'file': Icons.description_rounded,
    'file-edit': Icons.edit_document,
    'file-pdf': Icons.picture_as_pdf_rounded,
    'comments': Icons.chat_bubble_outline_rounded,
    'history': Icons.history_rounded,
    'clock': Icons.schedule_rounded,
    'calendar': Icons.calendar_today_rounded,
    'bell': Icons.notifications_rounded,
    'search': Icons.search_rounded,
    'filter': Icons.filter_list_rounded,
    'cog': Icons.settings_rounded,
    'lock': Icons.lock_rounded,
    'check-circle': Icons.check_circle_rounded,
    'times-circle': Icons.cancel_rounded,
    'exclamation-circle': Icons.warning_rounded,
    'info-circle': Icons.info_rounded,
    'question-circle': Icons.help_outline_rounded,
    'image': Icons.image_rounded,
  };

  // ─────────────────────────────────────────────────────────────────────────
  //  Keyword Fallback (Semantic matching on strings without direct hit)
  // ─────────────────────────────────────────────────────────────────────────
  static IconData? _keywordFallback(String name) {
    if (name.contains('female') || name.contains('woman') || name.contains('girl')) {
      return Icons.female_rounded;
    }
    if (name.contains('child') || name.contains('custody') || name.contains('kid')) {
      return Icons.child_care_rounded;
    }
    if (name.contains('family') || name.contains('marriage') || name.contains('divorce')) {
      return Icons.family_restroom_rounded;
    }
    if (name.contains('rupee') || name.contains('money') || name.contains('cash') || name.contains('wallet') || name.contains('pay')) {
      return Icons.currency_rupee_rounded;
    }
    if (name.contains('worker') || name.contains('labour') || name.contains('work') || name.contains('factory')) {
      return Icons.work_rounded;
    }
    if (name.contains('disab') || name.contains('wheelchair') || name.contains('accessible')) {
      return Icons.accessible_rounded;
    }
    if (name.contains('disaster') || name.contains('flood') || name.contains('storm')) {
      return Icons.warning_amber_rounded;
    }
    if (name.contains('police') || name.contains('crime') || name.contains('criminal') || name.contains('shield')) {
      return Icons.shield_rounded;
    }
    if (name.contains('vehicle') || name.contains('accident') || name.contains('car') || name.contains('motor')) {
      return Icons.directions_car_rounded;
    }
    if (name.contains('land') || name.contains('property') || name.contains('house') || name.contains('home')) {
      return Icons.home_rounded;
    }
    if (name.contains('certificate') || name.contains('document') || name.contains('file') || name.contains('notice')) {
      return Icons.description_rounded;
    }
    if (name.contains('group') || name.contains('people') || name.contains('users')) {
      return Icons.groups_rounded;
    }
    return null;
  }
}
