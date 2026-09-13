extension StringX on String? {
  bool get isUsable {
    return this != null && this!.trim().isNotEmpty && this!.trim().toLowerCase() != 'null';
  }

  String orPlaceholder([String placeholder = '-']) {
    if (!isUsable) return placeholder;
    return this!;
  }
}
