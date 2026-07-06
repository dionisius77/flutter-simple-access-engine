import 'dart:collection';

Map<String, List<String>> normalizePermissions(
  Map<dynamic, dynamic>? permissions,
) {
  final normalized = <String, List<String>>{};
  if (permissions == null) {
    return normalized;
  }

  for (final entry in permissions.entries) {
    final feature = _normalizeToken(entry.key);
    if (feature == null) {
      continue;
    }

    final rawActions = entry.value;
    if (rawActions is! Iterable) {
      continue;
    }

    final uniqueActions = LinkedHashSet<String>();
    for (final action in rawActions) {
      final normalizedAction = _normalizeToken(action);
      if (normalizedAction == null) {
        continue;
      }

      uniqueActions.add(normalizedAction);
    }

    if (uniqueActions.isNotEmpty) {
      normalized[feature] = List<String>.unmodifiable(uniqueActions);
    }
  }

  return Map<String, List<String>>.unmodifiable(normalized);
}

bool hasAccess(
  Map<String, List<String>> permissions,
  String feature,
  String action,
) {
  final normalizedFeature = _normalizeToken(feature);
  final normalizedAction = _normalizeToken(action);

  if (normalizedFeature == null || normalizedAction == null) {
    return false;
  }

  final featurePermissions = permissions[normalizedFeature];
  if (featurePermissions != null) {
    if (featurePermissions.contains(normalizedAction)) {
      return true;
    }

    if (featurePermissions.contains('*')) {
      return true;
    }
  }

  final globalPermissions = permissions['*'];
  return globalPermissions?.contains('*') ?? false;
}

String? _normalizeToken(Object? value) {
  if (value is! String) {
    return null;
  }

  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) {
    return null;
  }

  return normalized;
}
