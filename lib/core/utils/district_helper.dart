import '../../data/local/districts.dart';

class DistrictHelper {
  static final Map<String, String> _knownDistrictMap = {
    // UUIDs to District Names
    '162e0db6-feb9-44ea-9476-483c844f4956': 'Gangtok',
    '7c7faa9f-4cbb-450d-9046-15ef51430cd9': 'Namchi',
    '18bcf408-b669-4e7d-b52c-d3b0a9b7c89d': 'Mangan',
    'd434b194-4038-4342-b475-0f1ef7b44ae4': 'Gyalshing',
    '771eac9c-c0b1-4b1b-acfa-658163c4a82f': 'Pakyong',
    '2a8f7698-6ff5-48bf-a3c3-eea8a65109c6': 'Soreng',

    // District Codes to Names
    'GANGTOK': 'Gangtok',
    'GTK': 'Gangtok',
    'NAMCHI': 'Namchi',
    'NAM': 'Namchi',
    'NCH': 'Namchi',
    'MANGAN': 'Mangan',
    'MGN': 'Mangan',
    'GYALSHING': 'Gyalshing',
    'GYL': 'Gyalshing',
    'PAKYONG': 'Pakyong',
    'PKY': 'Pakyong',
    'SORENG': 'Soreng',
    'SRG': 'Soreng',

    // Lowercase variants
    'gangtok': 'Gangtok',
    'namchi': 'Namchi',
    'mangan': 'Mangan',
    'gyalshing': 'Gyalshing',
    'pakyong': 'Pakyong',
    'soreng': 'Soreng',
  };

  /// UUID regex check
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Resolves any district ID, code, or UUID into a clean readable Sikkim district name.
  static String resolveDistrictName(String? rawDistrictIdOrCode, [String? joinedDistrictName]) {
    // 1. If joined district name exists and is not a UUID, return it
    if (joinedDistrictName != null && joinedDistrictName.trim().isNotEmpty) {
      final trimmed = joinedDistrictName.trim();
      if (!_uuidRegex.hasMatch(trimmed)) {
        return _formatCapitalized(trimmed);
      }
    }

    if (rawDistrictIdOrCode == null || rawDistrictIdOrCode.trim().isEmpty) {
      return 'Sikkim (General)';
    }

    final key = rawDistrictIdOrCode.trim();

    // 2. Direct map lookup (covers UUIDs & standard codes)
    if (_knownDistrictMap.containsKey(key)) {
      return _knownDistrictMap[key]!;
    }
    if (_knownDistrictMap.containsKey(key.toUpperCase())) {
      return _knownDistrictMap[key.toUpperCase()]!;
    }
    if (_knownDistrictMap.containsKey(key.toLowerCase())) {
      return _knownDistrictMap[key.toLowerCase()]!;
    }

    // 3. Check localDistricts constant list
    for (final d in localDistricts) {
      if (d.id.toLowerCase() == key.toLowerCase() ||
          d.districtCode.toLowerCase() == key.toLowerCase() ||
          d.districtName.toLowerCase() == key.toLowerCase()) {
        return d.districtName;
      }
    }

    // 4. If it's a UUID that wasn't found in map, fallback gracefully instead of displaying raw UUID
    if (_uuidRegex.hasMatch(key)) {
      return 'Sikkim';
    }

    // 5. If it's already a clean string name, format with capitalization
    return _formatCapitalized(key);
  }

  static String _formatCapitalized(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
